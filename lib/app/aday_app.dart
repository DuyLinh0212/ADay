import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/aday_controller.dart';
import '../application/avatar_service.dart';
import '../application/google_drive_backup_service.dart';
import '../application/settings_service.dart';
import '../core/theme/aday_theme.dart';
import '../domain/models/goal.dart' as domain;
import '../domain/models/task_item.dart';
import '../presentation/adapters/aday_view_mapper.dart';
import '../presentation/models/task_view_item.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/create_goal/create_goal.dart';
import '../presentation/screens/goal_detail/goal_detail.dart';
import '../presentation/screens/home/home.dart';
import '../presentation/screens/profile/profile.dart';
import '../presentation/screens/statistics/statistics.dart';
import '../presentation/screens/tomorrow_plan/tomorrow_plan.dart';
import '../presentation/screens/settings/personalization_screens.dart';
import '../presentation/screens/tasks/task_list_screen.dart';
import '../platform/home_widget_bridge.dart';

class ADayApp extends StatelessWidget {
  const ADayApp({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final ADayController controller;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MaterialApp(
      title: 'ADay',
      debugShowCheckedModeBanner: false,
      theme: ADayTheme.forThemeId(controller.settings.themeId),
      home: ADayShell(controller: controller, settingsService: settingsService),
    ),
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
  late final GoogleDriveBackupService _driveBackupService;
  late final AvatarService _avatarService;

  ADayController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _driveBackupService = GoogleDriveBackupService();
    _avatarService = AvatarService();
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
      greetingQuote: _quoteForToday(),
      longTermGoal: ADayViewMapper.longTermSummary(controller),
      showEveningReminder: controller.settings.dailyReviewEnabled,
      reminderMessage:
          'Lúc ${ADayViewMapper.minuteLabel(controller.settings.dailyReviewMinute)}, ADay sẽ nhắc bạn cập nhật tiến độ và tạo kế hoạch cho ngày mai.',
      hasUnreadNotifications: _shouldReviewToday(),
      avatarInitials: _initials(controller.settings.displayName),
      avatarImage: _avatarImage,
      bottomNavIndex: _tabIndex,
      onToggleTask: _toggleHomeTask,
      onTaskTap: (task) => _openGoal(task.goalId),
      onAddTodayTask: () => _openCreateGoal(startDate: today),
      onViewAllTodayTasks: () => _openTaskList(today),
      onCreateGoalTap: () => _openCreateGoal(startDate: today),
      onCreateLongTermGoal: () =>
          _openCreateGoal(startDate: today, goalType: CreateGoalType.longTerm),
      onViewLongTermGoalAction: () =>
          _openGoal(controller.longTermGoals.firstOrNull?.id),
      onViewAllLongTermGoals: _openLongTermGoals,
      onReminderAction: _openTomorrowPlan,
      onNotificationTap: _openTomorrowPlan,
      onGreetingQuoteTap: _openQuotes,
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
        _calendarMonth = DateTime(
          _calendarMonth.year,
          _calendarMonth.month - 1,
        );
      }),
      onNextMonth: () => setState(() {
        _calendarMonth = DateTime(
          _calendarMonth.year,
          _calendarMonth.month + 1,
        );
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
      onCreateGoalTap: () => _openCreateGoal(startDate: DateTime.now()),
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
    onCreateGoalTap: () => _openCreateGoal(startDate: DateTime.now()),
    onNavTap: _selectTab,
  );

  Widget _buildProfile() {
    final profileData = ADayViewMapper.profile(controller, DateTime.now());
    return ProfileScreen(
      data: profileData,
      bottomNavIndex: _tabIndex,
      hasUnreadNotifications: _shouldReviewToday(),
      driveAccountEmail: controller.settings.driveAccountEmail,
      avatarPath: controller.settings.avatarPath,
      onLogoTap: () => _selectTab(0),
      onNotificationTap: _openTomorrowPlan,
      onAvatarTap: () => _selectTab(3),
      onEditAvatar: _editAvatar,
      onEditDisplayName: _editDisplayName,
      onEditEmail: _editEmail,
      onSecurityTap: () =>
          _showMessage('Bảo mật tài khoản đang ở mức an toàn cao.'),
      onToggleReminderBefore22: _toggleDailyReminder,
      onChangeReminderTime: _changeReminderTime,
      onToggleDailyNotification: (enabled) async {
        if (enabled) {
          await _toggleDailyReminder(true);
        } else {
          await _guard(widget.settingsService.disableDailyReview);
        }
      },
      onLanguageTap: () => _showMessage('Ngôn ngữ hiện tại: Tiếng Việt'),
      onThemeTap: _openThemePicker,
      onWidgetTap: _openWidgetSetup,
      onDriveBackupTap: _openDriveBackup,
      onHelpCenterTap: () => _showMessage(
        'Trung tâm hỗ trợ ADay luôn sẵn sàng đồng hành cùng bạn!',
      ),
      onTermsTap: () =>
          _showMessage('Điều khoản & Chính sách quyền riêng tư ADay.'),
      onLogoutTap: _confirmLogout,
      onCreateGoalTap: () => _openCreateGoal(startDate: DateTime.now()),
      onNavTap: _selectTab,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản ADay không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF0525E),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _showMessage('Đã đăng xuất thành công.');
    }
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
      await _syncHomeWidget();
    });
  }

  String _quoteForToday() {
    final quotes = controller.settings.dailyQuotes;
    if (quotes.isEmpty) return '“Những kế hoạch nhỏ tạo nên ngày mai lớn hơn.”';
    final now = DateTime.now();
    final dayIndex = now.difference(DateTime(now.year)).inDays;
    return '“${quotes[(now.year * 366 + dayIndex) % quotes.length]}”';
  }

  Future<void> _openQuotes() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => QuotesScreen(
        quotes: controller.settings.dailyQuotes,
        onAdd: (quote) => _guard(() => controller.addDailyQuote(quote)),
        onRemove: (quote) => _guard(() => controller.removeDailyQuote(quote)),
      ),
    ),
  );

  Future<void> _openThemePicker() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ThemePickerScreen(
        selectedId: controller.settings.themeId,
        onSelected: (id) => _guard(() async {
          await controller.updateSettings(
            controller.settings.copyWith(themeId: id),
          );
          await HomeWidgetBridge.setLauncherIcon(id);
          await _syncHomeWidget();
        }),
      ),
    ),
  );

  Future<void> _openWidgetSetup() {
    final now = DateTime.now();
    final tasks = ADayViewMapper.homeTasks(controller, now);
    final progress = ADayViewMapper.homeProgress(controller, now);
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WidgetSetupScreen(
          themeId: controller.settings.themeId,
          todayTasks: tasks,
          completedCount: progress.completedCount,
          totalCount: progress.totalCount,
          completionPercent: progress.percentageInt,
          onApplyTheme: (newThemeId) async {
            await controller.updateSettings(
              controller.settings.copyWith(themeId: newThemeId),
            );
            await HomeWidgetBridge.setLauncherIcon(newThemeId);
            await _syncHomeWidget();
          },
          onAddWidget: () async {
            await _syncHomeWidget();
            return HomeWidgetBridge.requestPin();
          },
        ),
      ),
    );
  }

  Future<void> _openDriveBackup() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => DriveBackupScreen(
        accountEmail: controller.settings.driveAccountEmail,
        lastBackupAt: controller.settings.driveLastBackupAt,
        onBackup: _backupToDrive,
      ),
    ),
  );

  Future<void> _backupToDrive() async {
    await _guard(() async {
      final result = await _driveBackupService.backup(controller.snapshot);
      await controller.updateSettings(
        controller.settings.copyWith(
          driveAccountEmail: result.email,
          driveLastBackupAt: result.backedUpAt,
        ),
      );
      _showMessage('Đã sao lưu dữ liệu vào Google Drive.');
    });
  }

  Future<void> _syncHomeWidget() {
    final now = DateTime.now();
    final tasks = ADayViewMapper.homeTasks(controller, now);
    final completed = tasks.where((task) => task.isCompleted).length;
    final remaining = tasks.where((task) => !task.isCompleted).length;
    final total = completed + remaining;
    final percent = total > 0 ? (completed * 100) ~/ total : 0;
    final dateLabel =
        'Hôm nay, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';

    final t1 = tasks.isNotEmpty ? tasks[0] : null;
    final t2 = tasks.length > 1 ? tasks[1] : null;
    final t3 = tasks.length > 2 ? tasks[2] : null;

    return HomeWidgetBridge.update(
      themeId: controller.settings.themeId,
      taskCount: remaining,
      completedCount: completed,
      percent: percent,
      dateLabel: dateLabel,
      task1Title: t1?.title,
      task1Done: t1?.isCompleted,
      task1Time: t1?.isAllDay == true ? 'Cả ngày' : t1?.timeLabel,
      task2Title: t2?.title,
      task2Done: t2?.isCompleted,
      task2Time: t2?.isAllDay == true ? 'Cả ngày' : t2?.timeLabel,
      task3Title: t3?.title,
      task3Done: t3?.isCompleted,
      task3Time: t3?.isAllDay == true ? 'Cả ngày' : t3?.timeLabel,
    );
  }

  Future<void> _openTaskList(DateTime day) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AnimatedBuilder(
          animation: controller,
          builder: (_, _) => TaskListScreen(
            title: _isSameDay(day, DateTime.now())
                ? 'Nhiệm vụ hôm nay'
                : 'Nhiệm vụ đã chọn',
            tasks: ADayViewMapper.homeTasks(controller, day),
            onToggleTask: _toggleHomeTask,
            onTaskTap: (task) => _openGoal(task.goalId),
          ),
        ),
      ),
    );
  }

  Future<void> _openLongTermGoals() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AnimatedBuilder(
          animation: controller,
          builder: (_, _) => TaskListScreen(
            title: 'Mục tiêu dài hạn',
            tasks: controller.longTermGoals
                .map(TaskViewItem.fromGoal)
                .toList(growable: false),
            onToggleTask: _toggleHomeTask,
            onTaskTap: (goal) => _openGoal(goal.goalId),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _openCreateTask(DateTime scheduledDate) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(
          onSubmit: (title, note, category) async {
            await _guard<void>(
              () => controller.createQuickTask(
                title: title,
                note: note,
                category: category,
                scheduledDate: scheduledDate,
              ),
            );
          },
        ),
      ),
    );
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
                  repeatDaily:
                      updated.goalType == CreateGoalType.daily &&
                      updated.isRepeating,
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

  Future<void> _editEmail() async {
    final editor = TextEditingController(text: controller.settings.email);
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Email tài khoản'),
        content: TextField(
          controller: editor,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Nhập địa chỉ email',
            labelText: 'Email',
          ),
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
    if (email != null && email.isNotEmpty && email.contains('@')) {
      await _guard(
        () => controller.updateSettings(
          controller.settings.copyWith(email: email),
        ),
      );
      _showMessage('Đã cập nhật email thành công.');
    } else if (email != null && email.isNotEmpty) {
      _showMessage('Địa chỉ email không hợp lệ.');
    }
  }

  ImageProvider? get _avatarImage {
    final path = controller.settings.avatarPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) return null;
    return FileImage(File(path));
  }

  Future<void> _editAvatar() async {
    await _guard(() async {
      final path = await _avatarService.chooseAndStore();
      if (path == null) return;
      await controller.updateSettings(
        controller.settings.copyWith(avatarPath: path),
      );
    });
  }

  Future<void> _toggleDailyReminder(bool enabled) async {
    await _guard(() async {
      if (enabled) {
        final allowed = await widget.settingsService.enableDailyReview(
          minuteOfDay: controller.settings.dailyReviewMinute,
        );
        if (!allowed) {
          _showMessage('Bạn chưa cấp quyền thông báo cho ADay.');
        } else {
          await widget.settingsService.showTestNotification();
          _showMessage('Đã lên lịch và gửi một thông báo thử.');
        }
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
