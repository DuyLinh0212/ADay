import 'package:aday/application/aday_controller.dart';
import 'package:aday/application/goal_draft.dart';
import 'package:aday/domain/models/aday_snapshot.dart';
import 'package:aday/domain/models/goal.dart';
import 'package:aday/domain/models/task_item.dart';
import 'package:aday/domain/repositories/aday_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRepository implements ADayRepository {
  ADaySnapshot value = const ADaySnapshot();

  @override
  Future<ADaySnapshot> load() async => value;

  @override
  Future<void> save(ADaySnapshot snapshot) async {
    value = snapshot;
  }
}

void main() {
  final now = DateTime(2026, 9, 7, 10);

  test(
    'creates a daily goal and completes it when every task is done',
    () async {
      final repository = _MemoryRepository();
      final controller = ADayController(
        repository: repository,
        clock: () => now,
      );
      await controller.initialize();

      final goal = await controller.createGoal(
        GoalDraft(
          title: 'Đọc sách 30 phút',
          kind: GoalKind.daily,
          startDate: now,
          tasks: const [TaskDraft(title: 'Đọc 20 trang')],
        ),
      );
      await controller.setTaskCompleted(
        goalId: goal.id,
        taskId: goal.tasks.single.id,
        completed: true,
      );

      expect(controller.goals.single.status, GoalStatus.completed);
      expect(controller.goals.single.completionRate, 1);
      expect(repository.value.events.length, 2);
    },
  );

  test('rejects an end time before the start time', () async {
    final controller = ADayController(
      repository: _MemoryRepository(),
      clock: () => now,
    );
    await controller.initialize();

    expect(
      () => controller.createGoal(
        GoalDraft(
          title: 'Họp nhóm',
          kind: GoalKind.daily,
          startDate: now,
          tasks: const [
            TaskDraft(title: 'Họp', startMinute: 600, endMinute: 540),
          ],
        ),
      ),
      throwsA(isA<ADayValidationException>()),
    );
  });

  test('creates an independent task on the selected day', () async {
    final controller = ADayController(
      repository: _MemoryRepository(),
      clock: () => now,
    );
    await controller.initialize();

    await controller.createQuickTask(
      title: 'Gọi cho mẹ',
      note: 'Sau giờ làm',
      category: 'Gia đình',
      scheduledDate: DateTime(2026, 9, 9, 18),
    );

    final goal = controller.goals.single;
    final task = goal.tasks.single;
    expect(goal.title, 'Gọi cho mẹ');
    expect(goal.category, 'Gia đình');
    expect(task.note, 'Sau giờ làm');
    expect(task.scheduledDate, DateTime(2026, 9, 9));
  });

  test('never stores recurring settings on a long-term goal', () async {
    final controller = ADayController(
      repository: _MemoryRepository(),
      clock: () => now,
    );
    await controller.initialize();

    final goal = await controller.createGoal(
      GoalDraft(
        title: 'Hoàn thành chứng chỉ',
        kind: GoalKind.longTerm,
        startDate: now,
        repeatDaily: true,
      ),
    );

    expect(goal.repeatDaily, isFalse);
  });

  test(
    'carries an unfinished task to tomorrow and records provenance',
    () async {
      final controller = ADayController(
        repository: _MemoryRepository(),
        clock: () => now,
      );
      await controller.initialize();
      final goal = await controller.createGoal(
        GoalDraft(
          title: 'Học Flutter',
          kind: GoalKind.daily,
          startDate: now,
          tasks: const [TaskDraft(title: 'Học một giờ')],
        ),
      );

      await controller.carryTaskToTomorrow(
        goalId: goal.id,
        taskId: goal.tasks.single.id,
      );

      final carried = controller.goals.single.tasks.single;
      expect(carried.scheduledDate, DateTime(2026, 9, 8));
      expect(carried.carriedFromDate, DateTime(2026, 9, 7));
    },
  );

  test(
    'projects daily recurring goal onto future days in goalsForDay and tasksForDay',
    () async {
      final controller = ADayController(
        repository: _MemoryRepository(),
        clock: () => now,
      );
      await controller.initialize();

      await controller.createGoal(
        GoalDraft(
          title: 'Tập thể dục mỗi ngày',
          kind: GoalKind.daily,
          startDate: now,
          repeatDaily: true,
          tasks: const [TaskDraft(title: 'Chạy bộ 30 phút')],
        ),
      );

      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));

      final tomorrowGoals = controller.goalsForDay(tomorrow);
      expect(tomorrowGoals.length, 1);
      expect(tomorrowGoals.first.title, 'Tập thể dục mỗi ngày');

      final tomorrowTasks = controller.tasksForDay(tomorrow);
      expect(tomorrowTasks.length, 1);
      expect(tomorrowTasks.first.title, 'Chạy bộ 30 phút');

      final nextWeekTasks = controller.tasksForDay(nextWeek);
      expect(nextWeekTasks.length, 1);
      expect(nextWeekTasks.first.title, 'Chạy bộ 30 phút');

      // Completing a task on a future recurring day persists it properly
      await controller.setTaskCompleted(
        goalId: tomorrowGoals.first.id,
        taskId: tomorrowTasks.first.id,
        completed: true,
      );

      final updatedTomorrowTasks = controller.tasksForDay(tomorrow);
      expect(updatedTomorrowTasks.first.status, TaskStatus.completed);
    },
  );
}
