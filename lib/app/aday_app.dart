import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/aday_controller.dart';
import '../application/settings_service.dart';
import '../core/theme/aday_colors.dart';
import '../core/theme/aday_spacing.dart';
import '../core/theme/aday_theme.dart';
import '../domain/models/goal.dart' as domain;
import '../domain/models/task_item.dart';
import '../presentation/adapters/aday_view_mapper.dart';
import '../presentation/models/task_view_item.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/create_goal/create_goal.dart';
import '../presentation/screens/goal_detail/goal_detail.dart';
import '../presentation/screens/home/home.dart';
import '../presentation/screens/statistics/statistics.dart';
import '../presentation/screens/tomorrow_plan/tomorrow_plan.dart';
import '../presentation/widgets/aday_bottom_nav.dart';
import '../presentation/widgets/aday_logo_header.dart';

class ADayApp extends StatelessWidget {
  const ADayApp({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final ADayController controller;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ADay',
    debugShowCheckedModeBanner: false,
    theme: ADayTheme.light(),
    home: ADayShell(controller: controller, settingsService: settingsService),
  );
}

class ADayShell extends StatefulWidget {
  const ADayShell({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final ADayController controller;
  final SettingsService settingsService;

  @override
  State<ADayShell> createState() => _ADayShellState();
}

class _ADayShellState extends State<ADayShell> {
  int _tabIndex = 0;
  late DateTime _calendarMonth;
  late DateTime _selectedDay;
  StatisticsPeriod _statisticsPeriod = StatisticsPeriod.month;
  bool _askedForNotifications = false;

  ADayController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _calendarMonth = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _configureReminder());
  }

  Future<void> _configureReminder() async {
    if (_askedForNotifications || kIsWeb) return;
    _askedForNotifications = true;
    try {
      if (controller.settings.dailyReviewEnabled &&
          !controller.settings.notificationsAllowed) {
        await widget.settingsService.enableDailyReview(
          minuteOfDay: controller.settings.dailyReviewMinute,
        );
      } else {
        await widget.settingsService.restoreSchedule();
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Chưa thể bật thông báo. Bạn có thể thử lại trong Hồ sơ.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      if (controller.isLoading && controller.goals.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return switch (_tabIndex) {
        0 => _buildHome(),
        1 => _buildCalendar(),
        2 => _buildStatistics(),
        _ => _buildProfile(),
      };
    },
  );

  Widget _buildHome() {
    final today = DateTime.now();
    return HomeScreen(
      greeting: 'Xin chào, ${controller.settings.displayName}!',
      progressData: ADayViewMapper.homeProgress(controller, today),
      todayTasks: ADayViewMapper.homeTasks(controller, today),
      longTermGoal: ADayViewMapper.longTermSummary(controller),
      showEveningReminder: controller.settings.dailyReviewEnabled,
      reminderMessage:
          'Lúc ${ADayViewMapper.minuteLabel(controller.settings.dailyReviewMinute)}, ADay sẽ nhắc bạn cập nhật tiến độ và tạo kế hoạch cho ngày mai.',
      hasUnreadNotifications: _shouldReviewToday(),
      avatarInitials: _initials(controller.settings.displayName),
      bottomNavIndex: _tabIndex,
      onToggleTask: _toggleHomeTask,
      onTaskTap: (task) => _openGoal(task.goalId),
      onAddTodayTask: () => _openCreateGoal(startDate: today),
      onViewAllTodayTasks: () => _openCreateGoal(startDate: today),
      onCreateLongTermGoal: () =>
          _openCreateGoal(startDate: today, goalType: CreateGoalType.longTerm),
      onViewLongTermGoalAction: () =>
          _openGoal(controller.longTermGoals.firstOrNull?.id),
      onViewAllLongTermGoals: () =>
          _openGoal(controller.longTermGoals.firstOrNull?.id),
      onReminderAction: _openTomorrowPlan,
      onNotificationTap: _openTomorrowPlan,
      onAvatarTap: () => setState(() => _tabIndex = 3),
      onNavTap: _selectTab,
    );
  }

  Widget _buildCalendar() {
    final statsViewData = ADayViewMapper.statistics(
      controller: controller,
      month: _calendarMonth,
      selectedDay: _selectedDay,
      period: _statisticsPeriod,
    );
    final selectedDayTasks = ADayViewMapper.homeTasks(controller, _selectedDay);

    return CalendarScreen(
      calendarData: statsViewData.calendar,
      selectedDay: _selectedDay,
      tasks: selectedDayTasks,
      bottomNavIndex: _tabIndex,
      hasUnreadNotifications: _shouldReviewToday(),
      avatarInitials: _initials(controller.settings.displayName),
      onLogoTap: () => _selectTab(0),
      onNotificationTap: _openTomorrowPlan,
      onAvatarTap: () => setState(() => _tabIndex = 3),
      onPrevMonth: () => setState(() {
        _calendarMonth =
            DateTime(_calendarMonth.year, _calendarMonth.month - 1);
      }),
      onNextMonth: () => setState(() {
        _calendarMonth =
            DateTime(_calendarMonth.year, _calendarMonth.month + 1);
      }),
      onTodayTap: () => setState(() {
        final now = DateTime.now();
        _selectedDay = DateTime(now.year, now.month, now.day);
        _calendarMonth = DateTime(now.year, now.month);
      }),
      onDayTap: (day) => setState(() => _selectedDay = day.date),
      onTodaySummaryTap: () {
        if (selectedDayTasks.isNotEmpty) {
          _openGoal(selectedDayTasks.first.goalId);
        }
      },
      onToggleTask: _toggleHomeTask,
      onTaskTap: (task) => _openGoal(task.goalId),
      onAddTask: () => _openCreateGoal(startDate: _selectedDay),
      onNavTap: _selectTab,
    );
  }

  Widget _buildStatistics() => StatisticsScreen(
    data: ADayViewMapper.statistics(
      controller: controller,
      month: _calendarMonth,
      selectedDay: _selectedDay,
      period: _statisticsPeriod,
    ),
    bottomNavIndex: _tabIndex,
    hasUnreadNotifications: _shouldReviewToday(),
    avatarInitials: _initials(controller.settings.displayName),
    onLogoTap: () => _selectTab(0),
    onNotificationTap: _openTomorrowPlan,
    onAvatarTap: () => setState(() => _tabIndex = 3),
    onPeriodChanged: (period) => setState(() => _statisticsPeriod = period),
    onNavTap: _selectTab,
  );

  Widget _buildProfile() {
    final settings = controller.settings;
    return Scaffold(
      backgroundColor: ADayColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ADayHeaderBar(
              avatarInitials: _initials(settings.displayName),
              hasUnreadNotifications: _shouldReviewToday(),
              onLogoTap: () => _selectTab(0),
              onNotificationTap: _openTomorrowPlan,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(ADaySpacing.md),
                children: [
                  Text(
                    'Hồ sơ & Nhắc nhở',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ADayColors.brandNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: ADaySpacing.xs),
                  const Text(
                    'Điều chỉnh cách ADay đồng hành cùng bạn mỗi ngày.',
                  ),
                  const SizedBox(height: ADaySpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(ADaySpacing.md),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: ADayColors.actionBlueTint,
                              child: Icon(
                                Icons.person_rounded,
                                color: ADayColors.actionBlue,
                              ),
                            ),
                            title: Text(settings.displayName),
                            subtitle: const Text('Người dùng ADay'),
                            trailing: IconButton(
                              tooltip: 'Đổi tên',
                              onPressed: _editDisplayName,
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                          const Divider(),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Nhắc tổng kết mỗi ngày'),
                            subtitle: Text(
                              'Nhắc lúc ${ADayViewMapper.minuteLabel(settings.dailyReviewMinute)}',
                            ),
                            value:
                                settings.dailyReviewEnabled &&
                                settings.notificationsAllowed,
                            onChanged: _toggleDailyReminder,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            enabled: settings.dailyReviewEnabled,
                            leading: const Icon(Icons.schedule_rounded),
                            title: const Text('Giờ nhắc'),
                            trailing: Text(
                              ADayViewMapper.minuteLabel(
                                settings.dailyReviewMinute,
                              ),
                            ),
                            onTap: _changeReminderTime,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: ADaySpacing.md),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.nightlight_round,
                        color: ADayColors.sunriseGold,
                      ),
                      title: const Text('Lập kế hoạch ngày mai'),
                      subtitle: const Text(
                        'Xử lý việc chưa xong và chuẩn bị lịch ngày mai.',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _openTomorrowPlan,
                    ),
                  ),
                ],
              ),
            ),
            ADayBottomNav(currentIndex: _tabIndex, onTap: _selectTab),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) => setState(() {
    _tabIndex = index;
  });

  Future<void> _toggleHomeTask(TaskViewItem item, bool completed) async {
    final goalId = item.goalId;
    final goal = goalId == null ? null : _goalById(goalId);
    if (goalId == null || goal == null) return;
    await _guard(() async {
      if (goal.tasks.any((task) => task.id == item.id)) {
        await controller.setTaskCompleted(
          goalId: goalId,
          taskId: item.id,
          completed: completed,
        );
      } else if (completed) {
        await controller.completeGoal(goalId);
      } else {
        await controller.updateGoal(
          goal.copyWith(
            status: domain.GoalStatus.active,
            clearCompletedAt: true,
          ),
        );
      }
    });
  }

  Future<void> _openCreateGoal({
    required DateTime startDate,
    CreateGoalType goalType = CreateGoalType.daily,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => CreateGoalScreen(
          initialValue: CreateGoalFormValue(
            goalType: goalType,
            title: '',
            category: 'Học tập',
            startDate: startDate,
            isRepeating: false,
          ),
          onBackTap: () => Navigator.of(routeContext).pop(),
          onSubmit: (value) async {
            final result = await _guard(
              () => controller.createGoal(ADayViewMapper.toGoalDraft(value)),
            );
            if (result != null && routeContext.mounted) {
              Navigator.of(routeContext).pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _openGoal(String? goalId) async {
    if (goalId == null || _goalById(goalId) == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => AnimatedBuilder(
          animation: controller,
          builder: (_, _) {
            final goal = _goalById(goalId);
            if (goal == null) return const SizedBox.shrink();
            return GoalDetailScreen(
              data: ADayViewMapper.goalDetail(goal),
              onBackTap: () => Navigator.of(routeContext).pop(),
              onToggleTask: (taskId, completed) => _guard(
                () => controller.setTaskCompleted(
                  goalId: goalId,
                  taskId: taskId,
                  completed: completed,
                ),
              ),
              onNoteUpdate: (note) {
                if (note != goal.note) {
                  _guard(
                    () => controller.updateGoal(goal.copyWith(note: note)),
                  );
                }
              },
              onEdit: () => _editGoal(goal),
              onComplete: () => _guard(() => controller.completeGoal(goalId)),
              onPostpone: (reason) => _guard(
                () => controller.postponeGoal(
                  goalId: goalId,
                  until: DateTime.now().add(const Duration(days: 1)),
                  reason: reason,
                ),
              ),
              onCancel: (reason) => _guard(
                () => controller.cancelGoal(goalId: goalId, reason: reason),
              ),
              onUpdateProgress: () => _showMessage('Tiến độ đã được lưu.'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editGoal(domain.Goal goal) async {
    final value = CreateGoalFormValue(
      goalType: goal.kind == domain.GoalKind.daily
          ? CreateGoalType.daily
          : CreateGoalType.longTerm,
      title: goal.title,
      description: goal.description,
      category: goal.category,
      priority: switch (goal.priority) {
        domain.GoalPriority.low => GoalPriority.low,
        domain.GoalPriority.medium => GoalPriority.medium,
        domain.GoalPriority.high => GoalPriority.high,
      },
      startDate: goal.startDate,
      endDate: goal.deadline,
      hasReminder: goal.reminderEnabled,
      reminderMinute: goal.reminderMinute,
      isRepeating: goal.repeatDaily,
      tasks: goal.tasks
          .map(
            (task) => CreateGoalTaskItem(
              id: task.id,
              title: task.title,
              isAllDay: task.isAllDay,
              startMinute: task.startMinute,
              endMinute: task.endMinute,
            ),
          )
          .toList(growable: false),
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => CreateGoalScreen(
          initialValue: value,
          onBackTap: () => Navigator.of(routeContext).pop(),
          onSubmit: (updated) async {
            final tasks = updated.tasks
                .asMap()
                .entries
                .map((entry) {
                  final item = entry.value;
                  TaskItem? old;
                  for (final existing in goal.tasks) {
                    if (existing.id == item.id) {
                      old = existing;
                      break;
                    }
                  }
                  if (old != null) {
                    return old.copyWith(
                      title: item.title,
                      scheduledDate: updated.startDate,
                      startMinute: item.startMinute,
                      endMinute: item.endMinute,
                      clearTime: item.isAllDay,
                    );
                  }
                  return TaskItem(
                    id: 'task-${DateTime.now().microsecondsSinceEpoch}-${entry.key}',
                    title: item.title,
                    scheduledDate: updated.startDate,
                    startMinute: item.isAllDay ? null : item.startMinute,
                    endMinute: item.isAllDay ? null : item.endMinute,
                  );
                })
                .toList(growable: false);
            final result = await _guard(() async {
              await controller.updateGoal(
                goal.copyWith(
                  title: updated.title,
                  description: updated.description,
                  category: updated.category,
                  kind: updated.goalType == CreateGoalType.daily
                      ? domain.GoalKind.daily
                      : domain.GoalKind.longTerm,
                  priority: switch (updated.priority) {
                    GoalPriority.low => domain.GoalPriority.low,
                    GoalPriority.medium => domain.GoalPriority.medium,
                    GoalPriority.high => domain.GoalPriority.high,
                  },
                  startDate: updated.startDate,
                  deadline: updated.endDate,
                  clearDeadline: updated.endDate == null,
                  reminderEnabled: updated.hasReminder,
                  reminderMinute: updated.reminderMinute,
                  clearReminderMinute: !updated.hasReminder,
                  repeatDaily: updated.isRepeating,
                  tasks: tasks,
                ),
              );
              return true;
            });
            if (result == true && routeContext.mounted) {
              Navigator.of(routeContext).pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _openTomorrowPlan() async {
    final today = DateTime.now();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => AnimatedBuilder(
          animation: controller,
          builder: (_, _) => TomorrowPlanScreen(
            data: ADayViewMapper.tomorrowPlan(controller, today),
            onBackTap: () => Navigator.of(routeContext).pop(),
            onUnresolvedTaskActionChanged: _handleUnresolvedTask,
            onQuickAdd: () =>
                _openCreateGoal(startDate: today.add(const Duration(days: 1))),
            onAddTomorrowTask: () =>
                _openCreateGoal(startDate: today.add(const Duration(days: 1))),
            onRemoveTomorrowTask: _removeTomorrowTask,
            onToggleTomorrowTask: (taskId, completed) {
              final owner = _ownerOfTask(taskId);
              if (owner != null) {
                _guard(
                  () => controller.setTaskCompleted(
                    goalId: owner.id,
                    taskId: taskId,
                    completed: completed,
                  ),
                );
              }
            },
            onFinishPlan: () async {
              await _guard(controller.completeDailyReview);
              if (routeContext.mounted) Navigator.of(routeContext).pop();
            },
            onSkipPlan: () => Navigator.of(routeContext).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUnresolvedTask(
    String taskId,
    UnresolvedTaskAction action,
  ) async {
    final owner = _ownerOfTask(taskId) ?? _goalById(taskId);
    if (owner == null) return;
    await _guard(() async {
      final isTask = owner.tasks.any((task) => task.id == taskId);
      if (action == UnresolvedTaskAction.markCompleted) {
        if (isTask) {
          await controller.setTaskCompleted(
            goalId: owner.id,
            taskId: taskId,
            completed: true,
          );
        } else {
          await controller.completeGoal(owner.id);
        }
      } else if (isTask) {
        await controller.carryTaskToTomorrow(goalId: owner.id, taskId: taskId);
      } else {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        await controller.updateGoal(
          owner.copyWith(
            startDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
          ),
        );
      }
    });
  }

  Future<void> _removeTomorrowTask(String taskId) async {
    final owner = _ownerOfTask(taskId);
    if (owner != null) {
      await _guard(
        () => controller.removeTask(goalId: owner.id, taskId: taskId),
      );
    }
  }

  Future<void> _editDisplayName() async {
    final editor = TextEditingController(text: controller.settings.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tên hiển thị'),
        content: TextField(
          controller: editor,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: 'Tên của bạn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(editor.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    editor.dispose();
    if (name != null && name.isNotEmpty) {
      await _guard(
        () => controller.updateSettings(
          controller.settings.copyWith(displayName: name),
        ),
      );
    }
  }

  Future<void> _toggleDailyReminder(bool enabled) async {
    await _guard(() async {
      if (enabled) {
        final allowed = await widget.settingsService.enableDailyReview(
          minuteOfDay: controller.settings.dailyReviewMinute,
        );
        if (!allowed) _showMessage('Bạn chưa cấp quyền thông báo cho ADay.');
      } else {
        await widget.settingsService.disableDailyReview();
      }
    });
  }

  Future<void> _changeReminderTime() async {
    final current = controller.settings.dailyReviewMinute;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: 'Chọn giờ nhắc tổng kết',
      cancelText: 'Hủy',
      confirmText: 'Lưu',
    );
    if (selected != null) {
      await _guard(
        () => widget.settingsService.enableDailyReview(
          minuteOfDay: selected.hour * 60 + selected.minute,
        ),
      );
    }
  }

  domain.Goal? _goalById(String id) {
    for (final goal in controller.goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  domain.Goal? _ownerOfTask(String taskId) {
    for (final goal in controller.goals) {
      if (goal.tasks.any((task) => task.id == taskId)) return goal;
    }
    return null;
  }

  bool _shouldReviewToday() {
    final now = DateTime.now();
    return !controller.snapshot.events.any(
      (event) =>
          event.type.name == 'dailyReviewCompleted' &&
          event.occurredAt.year == now.year &&
          event.occurredAt.month == now.month &&
          event.occurredAt.day == now.day,
    );
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'A';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (mounted) _showMessage(error.toString());
      return null;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
