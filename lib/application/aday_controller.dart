import 'package:flutter/foundation.dart';

import '../domain/models/activity_event.dart';
import '../domain/models/aday_snapshot.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/goal.dart';
import '../domain/models/task_item.dart';
import '../domain/repositories/aday_repository.dart';
import 'goal_draft.dart';

typedef Clock = DateTime Function();

class ADayValidationException implements Exception {
  const ADayValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ADayController extends ChangeNotifier {
  ADayController({required ADayRepository repository, Clock? clock})
    : _repository = repository,
      _clock = clock ?? DateTime.now;

  final ADayRepository _repository;
  final Clock _clock;
  ADaySnapshot _snapshot = const ADaySnapshot();
  bool _isLoading = false;
  String? _errorMessage;
  int _idSequence = 0;

  ADaySnapshot get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Goal> get goals => List.unmodifiable(_snapshot.goals);
  AppSettings get settings => _snapshot.settings;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _snapshot = await _repository.load();
      _errorMessage = null;
      await ensureRecurringGoalsFor(_dateOnly(_clock()));
    } catch (error) {
      _errorMessage = 'Không thể đọc dữ liệu ADay: $error';
    } finally {
      _setLoading(false);
    }
  }

  List<Goal> goalsForDay(DateTime day) {
    final target = _dateOnly(day);
    return _snapshot.goals
        .where((goal) {
          if (goal.status == GoalStatus.cancelled) return false;
          if (goal.kind == GoalKind.daily &&
              _isSameDay(goal.startDate, target)) {
            return true;
          }
          return goal.tasks.any(
            (task) => _isSameDay(task.scheduledDate, target),
          );
        })
        .toList(growable: false);
  }

  List<Goal> get longTermGoals => _snapshot.goals
      .where(
        (goal) =>
            goal.kind == GoalKind.longTerm && goal.status == GoalStatus.active,
      )
      .toList(growable: false);

  List<TaskItem> tasksForDay(DateTime day) {
    final target = _dateOnly(day);
    return _snapshot.goals
        .where((goal) => goal.status != GoalStatus.cancelled)
        .expand((goal) => goal.tasks)
        .where((task) => _isSameDay(task.scheduledDate, target))
        .toList(growable: false);
  }

  Future<Goal> createGoal(GoalDraft draft) async {
    _validateGoalDraft(draft);
    final now = _clock();
    final goalId = _newId('goal', now);
    final tasks = draft.tasks
        .map((task) {
          return TaskItem(
            id: _newId('task', now),
            title: task.title.trim(),
            note: task.note.trim(),
            scheduledDate: _dateOnly(draft.startDate),
            startMinute: task.startMinute,
            endMinute: task.endMinute,
          );
        })
        .toList(growable: false);
    final goal = Goal(
      id: goalId,
      title: draft.title.trim(),
      description: draft.description.trim(),
      category: draft.category.trim().isEmpty ? 'Khác' : draft.category.trim(),
      kind: draft.kind,
      priority: draft.priority,
      startDate: _dateOnly(draft.startDate),
      deadline: draft.deadline == null ? null : _dateOnly(draft.deadline!),
      reminderEnabled: draft.reminderEnabled,
      reminderMinute: draft.reminderEnabled ? draft.reminderMinute : null,
      repeatDaily: draft.kind == GoalKind.daily && draft.repeatDaily,
      tasks: tasks,
      createdAt: now,
      updatedAt: now,
    );
    await _commit(
      _snapshot.copyWith(
        goals: [..._snapshot.goals, goal],
        events: [
          ..._snapshot.events,
          _event(ActivityType.goalCreated, now, goalId: goal.id),
        ],
      ),
    );
    return goal;
  }

  Future<void> updateGoal(Goal goal) async {
    if (goal.title.trim().isEmpty) {
      throw const ADayValidationException(
        'Tiêu đề mục tiêu không được để trống.',
      );
    }
    final index = _goalIndex(goal.id);
    final goals = [..._snapshot.goals];
    goals[index] = goal.copyWith(updatedAt: _clock());
    await _commit(_snapshot.copyWith(goals: goals));
  }

  Future<void> setTaskCompleted({
    required String goalId,
    required String taskId,
    required bool completed,
  }) async {
    final now = _clock();
    final index = _goalIndex(goalId);
    final goal = _snapshot.goals[index];
    final taskIndex = goal.tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex < 0) {
      throw ADayValidationException('Không tìm thấy nhiệm vụ $taskId.');
    }
    final tasks = [...goal.tasks];
    tasks[taskIndex] = tasks[taskIndex].copyWith(
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      completedAt: completed ? now : null,
      clearCompletedAt: !completed,
    );
    final allDone =
        tasks.isNotEmpty &&
        tasks.every((task) => task.status == TaskStatus.completed);
    final updatedGoal = goal.copyWith(
      tasks: tasks,
      status: allDone ? GoalStatus.completed : GoalStatus.active,
      completedAt: allDone ? now : null,
      clearCompletedAt: !allDone,
      updatedAt: now,
    );
    final goals = [..._snapshot.goals]..[index] = updatedGoal;
    final type = completed
        ? ActivityType.taskCompleted
        : ActivityType.taskReopened;
    await _commit(
      _snapshot.copyWith(
        goals: goals,
        events: [
          ..._snapshot.events,
          _event(type, now, goalId: goalId, taskId: taskId),
        ],
      ),
    );
  }

  Future<void> completeGoal(String goalId) async {
    final now = _clock();
    await _changeGoalStatus(
      goalId: goalId,
      status: GoalStatus.completed,
      eventType: ActivityType.goalCompleted,
      completedAt: now,
    );
  }

  Future<void> postponeGoal({
    required String goalId,
    required DateTime until,
    required String reason,
  }) async {
    if (!_dateOnly(until).isAfter(_dateOnly(_clock()))) {
      throw const ADayValidationException('Ngày hoãn phải sau hôm nay.');
    }
    if (reason.trim().isEmpty) {
      throw const ADayValidationException('Hãy chọn lý do tạm hoãn.');
    }
    await _changeGoalStatus(
      goalId: goalId,
      status: GoalStatus.postponed,
      eventType: ActivityType.goalPostponed,
      reason: reason.trim(),
      postponedUntil: _dateOnly(until),
    );
  }

  Future<void> cancelGoal({
    required String goalId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw const ADayValidationException('Hãy chọn lý do hủy mục tiêu.');
    }
    await _changeGoalStatus(
      goalId: goalId,
      status: GoalStatus.cancelled,
      eventType: ActivityType.goalCancelled,
      reason: reason.trim(),
    );
  }

  Future<void> carryTaskToTomorrow({
    required String goalId,
    required String taskId,
  }) async {
    final now = _clock();
    final index = _goalIndex(goalId);
    final goal = _snapshot.goals[index];
    final taskIndex = goal.tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex < 0) {
      throw ADayValidationException('Không tìm thấy nhiệm vụ $taskId.');
    }
    final original = goal.tasks[taskIndex];
    final tomorrow = _dateOnly(now).add(const Duration(days: 1));
    final tasks = [...goal.tasks];
    tasks[taskIndex] = original.copyWith(
      scheduledDate: tomorrow,
      status: TaskStatus.pending,
      carriedFromDate: _dateOnly(original.scheduledDate),
      clearCompletedAt: true,
    );
    final goals = [..._snapshot.goals]
      ..[index] = goal.copyWith(tasks: tasks, updatedAt: now);
    await _commit(
      _snapshot.copyWith(
        goals: goals,
        events: [
          ..._snapshot.events,
          _event(
            ActivityType.taskCarriedForward,
            now,
            goalId: goalId,
            taskId: taskId,
            metadata: {'toDate': tomorrow.toIso8601String()},
          ),
        ],
      ),
    );
  }

  Future<void> removeTask({
    required String goalId,
    required String taskId,
  }) async {
    final now = _clock();
    final index = _goalIndex(goalId);
    final goal = _snapshot.goals[index];
    final tasks = goal.tasks
        .where((task) => task.id != taskId)
        .toList(growable: false);
    if (tasks.length == goal.tasks.length) {
      throw ADayValidationException('Không tìm thấy nhiệm vụ $taskId.');
    }
    final goals = [..._snapshot.goals]
      ..[index] = goal.copyWith(tasks: tasks, updatedAt: now);
    await _commit(_snapshot.copyWith(goals: goals));
  }

  Future<void> completeDailyReview() async {
    final now = _clock();
    final alreadyLogged = _snapshot.events.any(
      (event) =>
          event.type == ActivityType.dailyReviewCompleted &&
          _isSameDay(event.occurredAt, now),
    );
    if (alreadyLogged) return;
    await _commit(
      _snapshot.copyWith(
        events: [
          ..._snapshot.events,
          _event(ActivityType.dailyReviewCompleted, now),
        ],
      ),
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    if (settings.dailyReviewMinute < 0 || settings.dailyReviewMinute >= 1440) {
      throw const ADayValidationException('Giờ nhắc phải nằm trong một ngày.');
    }
    await _commit(_snapshot.copyWith(settings: settings));
  }

  Future<void> ensureRecurringGoalsFor(DateTime day) async {
    final target = _dateOnly(day);
    final recurring = _snapshot.goals.where(
      (goal) => goal.repeatDaily && goal.status != GoalStatus.cancelled,
    );
    final additions = <Goal>[];
    final processedRoots = <String>{};
    final now = _clock();
    for (final source in recurring) {
      final rootId = source.recurrenceSourceId ?? source.id;
      if (!processedRoots.add(rootId)) continue;
      final exists = _snapshot.goals.any(
        (goal) =>
            (goal.id == rootId || goal.recurrenceSourceId == rootId) &&
            _isSameDay(goal.startDate, target),
      );
      if (exists || target.isBefore(_dateOnly(source.startDate))) continue;
      additions.add(
        source.copyWith(
          id: _newId('goal', now),
          startDate: target,
          status: GoalStatus.active,
          tasks: source.tasks
              .map(
                (task) => task.copyWith(
                  id: _newId('task', now),
                  scheduledDate: target,
                  status: TaskStatus.pending,
                  clearCompletedAt: true,
                ),
              )
              .toList(growable: false),
          createdAt: now,
          updatedAt: now,
          clearCompletedAt: true,
          clearPostponedUntil: true,
          clearStatusReason: true,
          recurrenceSourceId: rootId,
        ),
      );
    }
    if (additions.isNotEmpty) {
      await _commit(
        _snapshot.copyWith(goals: [..._snapshot.goals, ...additions]),
      );
    }
  }

  Future<void> _changeGoalStatus({
    required String goalId,
    required GoalStatus status,
    required ActivityType eventType,
    String? reason,
    DateTime? completedAt,
    DateTime? postponedUntil,
  }) async {
    final now = _clock();
    final index = _goalIndex(goalId);
    final goal = _snapshot.goals[index];
    final tasks = status == GoalStatus.completed
        ? goal.tasks
              .map(
                (task) => task.copyWith(
                  status: TaskStatus.completed,
                  completedAt: task.completedAt ?? now,
                ),
              )
              .toList(growable: false)
        : goal.tasks;
    final updated = goal.copyWith(
      status: status,
      tasks: tasks,
      completedAt: completedAt,
      clearCompletedAt: completedAt == null,
      postponedUntil: postponedUntil,
      clearPostponedUntil: postponedUntil == null,
      statusReason: reason,
      clearStatusReason: reason == null,
      updatedAt: now,
    );
    final goals = [..._snapshot.goals]..[index] = updated;
    await _commit(
      _snapshot.copyWith(
        goals: goals,
        events: [
          ..._snapshot.events,
          _event(eventType, now, goalId: goalId, reason: reason),
        ],
      ),
    );
  }

  Future<void> _commit(ADaySnapshot next) async {
    _setLoading(true);
    try {
      await _repository.save(next);
      _snapshot = next;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Không thể lưu thay đổi: $error';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  int _goalIndex(String goalId) {
    final index = _snapshot.goals.indexWhere((goal) => goal.id == goalId);
    if (index < 0) {
      throw ADayValidationException('Không tìm thấy mục tiêu $goalId.');
    }
    return index;
  }

  void _validateGoalDraft(GoalDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw const ADayValidationException(
        'Tiêu đề mục tiêu không được để trống.',
      );
    }
    if (draft.title.trim().length > 100) {
      throw const ADayValidationException('Tiêu đề tối đa 100 ký tự.');
    }
    if (draft.description.length > 300) {
      throw const ADayValidationException('Mô tả tối đa 300 ký tự.');
    }
    if (draft.deadline != null &&
        _dateOnly(draft.deadline!).isBefore(_dateOnly(draft.startDate))) {
      throw const ADayValidationException(
        'Thời hạn không thể trước ngày bắt đầu.',
      );
    }
    if (draft.reminderEnabled && draft.reminderMinute == null) {
      throw const ADayValidationException('Hãy chọn thời gian nhắc nhở.');
    }
    for (final task in draft.tasks) {
      if (task.title.trim().isEmpty) {
        throw const ADayValidationException(
          'Tên nhiệm vụ không được để trống.',
        );
      }
      if (task.startMinute != null &&
          (task.startMinute! < 0 || task.startMinute! >= 1440)) {
        throw const ADayValidationException(
          'Giờ bắt đầu nhiệm vụ không hợp lệ.',
        );
      }
      if (task.endMinute != null &&
          (task.startMinute == null || task.endMinute! <= task.startMinute!)) {
        throw const ADayValidationException(
          'Giờ kết thúc phải sau giờ bắt đầu.',
        );
      }
    }
  }

  ActivityEvent _event(
    ActivityType type,
    DateTime now, {
    String? goalId,
    String? taskId,
    String? reason,
    Map<String, String> metadata = const {},
  }) {
    return ActivityEvent(
      id: _newId('event', now),
      type: type,
      occurredAt: now,
      goalId: goalId,
      taskId: taskId,
      reason: reason,
      metadata: metadata,
    );
  }

  String _newId(String prefix, DateTime now) =>
      '$prefix-${now.microsecondsSinceEpoch}-${_idSequence++}';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
