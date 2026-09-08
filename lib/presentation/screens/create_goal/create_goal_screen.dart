import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_button.dart';
import '../../widgets/mountain_sun_visual.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/status_time_chip.dart';
import 'create_goal_form_value.dart';

/// Screen for creating or editing a goal, strictly matching TaoMucTieu.png.
///
/// Features:
/// - Daily vs Long-term goal switcher
/// - Form fields: Title (with counter 0/100), Description (0/300)
/// - Category and Priority dropdown pickers
/// - Start date and optional End date pickers
/// - Reminder toggle with customizable reminder time picker
/// - Editable task list with time ranges and task addition sheet
/// - Repeat toggle
/// - Full Vietnamese validation
/// - Accessible touch targets (>= 44x44) and semantics
class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({
    super.key,
    this.initialValue,
    this.onSubmit,
    this.onBackTap,
    this.onHelpTap,
    this.categories = const [
      'Học tập',
      'Thể thao',
      'Công việc',
      'Sức khỏe',
      'Tài chính',
      'Sở thích',
      'Phát triển bản thân',
    ],
  });

  final CreateGoalFormValue? initialValue;
  final ValueChanged<CreateGoalFormValue>? onSubmit;
  final VoidCallback? onBackTap;
  final VoidCallback? onHelpTap;
  final List<String> categories;

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late CreateGoalType _goalType;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late GoalPriority _priority;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _hasReminder;
  late int _reminderMinute;
  late bool _isRepeating;
  late List<CreateGoalTaskItem> _tasks;

  String? _titleError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;

    _goalType = initial?.goalType ?? CreateGoalType.daily;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _category =
        initial?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first : 'Học tập');
    _priority = initial?.priority ?? GoalPriority.high;
    _startDate = initial?.startDate ?? DateTime.now();
    _endDate = initial?.endDate;
    _hasReminder = initial?.hasReminder ?? true;
    _reminderMinute = initial?.reminderMinute ?? (8 * 60); // 08:00
    _isRepeating =
        _goalType == CreateGoalType.daily && (initial?.isRepeating ?? true);

    _tasks = List.from(initial?.tasks ?? const <CreateGoalTaskItem>[]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Date/Time Formatting Helpers (Vietnamese) ---

  String _formatDateVietnamese(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day} thg ${date.month}, ${date.year}';
  }

  String _formatTimeMinute(int totalMinutes) {
    final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final m = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  IconData _categoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('học') || lower.contains('sách')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('thể thao') || lower.contains('tập')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('việc') || lower.contains('công')) {
      return Icons.work_outline_rounded;
    }
    if (lower.contains('sức khỏe')) {
      return Icons.health_and_safety_outlined;
    }
    if (lower.contains('tài chính')) {
      return Icons.account_balance_wallet_outlined;
    }
    return Icons.star_outline_rounded;
  }

  // --- Validation and Submit ---

  void _handleSubmit() {
    setState(() {
      _titleError = null;
      _dateError = null;
    });

    final trimmedTitle = _titleController.text.trim();
    bool hasError = false;

    if (trimmedTitle.isEmpty) {
      setState(() {
        _titleError = 'Vui lòng nhập tiêu đề mục tiêu';
      });
      hasError = true;
    } else if (trimmedTitle.length > 100) {
      setState(() {
        _titleError = 'Tiêu đề không được vượt quá 100 ký tự';
      });
      hasError = true;
    }

    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      final isSameDay =
          _endDate!.year == _startDate.year &&
          _endDate!.month == _startDate.month &&
          _endDate!.day == _startDate.day;
      if (!isSameDay) {
        setState(() {
          _dateError = 'Thời hạn kết thúc không thể trước ngày bắt đầu';
        });
        hasError = true;
      }
    }

    if (hasError) return;

    final result = CreateGoalFormValue(
      goalType: _goalType,
      title: trimmedTitle,
      description: _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      startDate: _startDate,
      endDate: _goalType == CreateGoalType.daily ? null : _endDate,
      hasReminder: _hasReminder,
      reminderMinute: _hasReminder ? _reminderMinute : null,
      isRepeating: _goalType == CreateGoalType.daily && _isRepeating,
      tasks: List.unmodifiable(_tasks),
    );

    widget.onSubmit?.call(result);
  }

  // --- Dialogs & Bottom Sheets ---

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Chọn ngày bắt đầu',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2035),
      helpText: 'Chọn ngày kết thúc',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final initialTime = TimeOfDay(
      hour: _reminderMinute ~/ 60,
      minute: _reminderMinute % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Chọn thời gian nhắc nhở',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() {
        _reminderMinute = picked.hour * 60 + picked.minute;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ADaySpacing.md,
              vertical: ADaySpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn danh mục',
                  style: ADayTypography.title.copyWith(fontSize: 18.0),
                ),
                const SizedBox(height: ADaySpacing.sm),
                ...widget.categories.map((cat) {
                  final isSelected = cat == _category;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _categoryIcon(cat),
                      color: isSelected
                          ? ADayColors.actionBlue
                          : ADayColors.brandNavy,
                    ),
                    title: Text(
                      cat,
                      style: ADayTypography.body.copyWith(
                        color: isSelected
                            ? ADayColors.actionBlue
                            : ADayColors.brandNavy,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: ADayColors.actionBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _category = cat;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mức độ ưu tiên',
                  style: ADayTypography.title.copyWith(fontSize: 18.0),
                ),
                const SizedBox(height: ADaySpacing.sm),
                ...GoalPriority.values.map((p) {
                  final isSelected = p == _priority;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(p.icon, color: p.color),
                    title: Text(
                      p.label,
                      style: ADayTypography.body.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: ADayColors.actionBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _priority = p;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    bool isAllDay = true;
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: ADaySpacing.md,
                right: ADaySpacing.md,
                top: ADaySpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + ADaySpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thêm nhiệm vụ nhỏ',
                        style: ADayTypography.title.copyWith(fontSize: 18.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: ADaySpacing.sm),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Đọc chương 1',
                      hintStyle: ADayTypography.body.copyWith(
                        color: ADayColors.mutedInk,
                      ),
                      filled: true,
                      fillColor: ADayColors.canvas,
                      contentPadding: ADaySpacing.paddingInput,
                      border: OutlineInputBorder(
                        borderRadius: ADaySpacing.controlRadius,
                        borderSide: BorderSide(color: ADayColors.dividerMist),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: ADaySpacing.controlRadius,
                        borderSide: BorderSide(color: ADayColors.dividerMist),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: ADaySpacing.controlRadius,
                        borderSide: BorderSide(
                          color: ADayColors.actionBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ADaySpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cả ngày', style: ADayTypography.label),
                      Switch.adaptive(
                        value: isAllDay,
                        activeTrackColor: ADayColors.actionBlue,
                        onChanged: (val) {
                          setModalState(() {
                            isAllDay = val;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!isAllDay) ...[
                    const SizedBox(height: ADaySpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startTime = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: ADayColors.coolSurface,
                                borderRadius: ADaySpacing.controlRadius,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bắt đầu: ${startTime.format(context)}',
                                    style: ADayTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ADayColors.brandNavy,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16.0,
                                    color: ADayColors.brandNavy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ADaySpacing.sm),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  endTime = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: ADayColors.coolSurface,
                                borderRadius: ADaySpacing.controlRadius,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kết thúc: ${endTime.format(context)}',
                                    style: ADayTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ADayColors.brandNavy,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16.0,
                                    color: ADayColors.brandNavy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: ADaySpacing.lg),
                  ADayButton.primary(
                    label: 'Thêm nhiệm vụ',
                    onPressed: () {
                      final text = titleController.text.trim();
                      if (text.isEmpty) return;
                      final newItem = CreateGoalTaskItem(
                        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                        title: text,
                        isAllDay: isAllDay,
                        startMinute: isAllDay
                            ? null
                            : (startTime.hour * 60 + startTime.minute),
                        endMinute: isAllDay
                            ? null
                            : (endTime.hour * 60 + endTime.minute),
                      );
                      setState(() {
                        _tasks.add(newItem);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ADayColors.canvas,
      appBar: AppBar(
        backgroundColor: ADayColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Semantics(
          label: 'Quay lại',
          button: true,
          child: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: ADayColors.brandNavy,
              size: 28.0,
            ),
            onPressed: widget.onBackTap ?? () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          'Tạo mục tiêu',
          style: ADayTypography.title.copyWith(fontSize: 18.0),
        ),
        centerTitle: true,
        actions: [
          Semantics(
            label: 'Xem hướng dẫn tạo mục tiêu',
            button: true,
            child: Padding(
              padding: const EdgeInsets.only(right: ADaySpacing.md),
              child: Center(
                child: InkWell(
                  onTap:
                      widget.onHelpTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hãy đặt mục tiêu rõ ràng và chia nhỏ nhiệm vụ để dễ dàng hoàn thành mỗi ngày!',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                  borderRadius: ADaySpacing.pillRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: ADayColors.coolSurface,
                      borderRadius: ADaySpacing.pillRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 15.0,
                          color: ADayColors.actionBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Hướng dẫn',
                          style: ADayTypography.caption.copyWith(
                            color: ADayColors.actionBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. Hero Card ---
                      _buildHeroCard(),

                      const SizedBox(height: ADaySpacing.md),

                      // --- 2. Title & Description Section ---
                      _buildFormDetailsSection(),

                      const SizedBox(height: ADaySpacing.md),

                      // --- 3. Category & Priority Row ---
                      _buildCategoryAndPriorityRow(),

                      const SizedBox(height: ADaySpacing.md),

                      // --- 4. Start & End Date Row ---
                      _buildDateSelectionRow(),

                      const SizedBox(height: ADaySpacing.md),

                      // --- 5. Reminder Section ---
                      _buildReminderSection(),

                      const SizedBox(height: ADaySpacing.md),

                      // --- 6. Task List Section ---
                      _buildTaskListSection(),

                      const SizedBox(height: ADaySpacing.md),

                      // Daily goals may recur. Long-term goals are one
                      // continuous objective and never expose this control.
                      if (_goalType == CreateGoalType.daily)
                        _buildRepeatSection(),

                      const SizedBox(height: ADaySpacing.lg),
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom Fixed Submit Button ---
            Container(
              padding: const EdgeInsets.all(ADaySpacing.md),
              decoration: BoxDecoration(
                color: ADayColors.surface,
                border: Border(
                  top: BorderSide(color: ADayColors.dividerMist, width: 1.0),
                ),
              ),
              child: ADayButton.primary(
                label: 'Lưu mục tiêu',
                height: 52.0,
                onPressed: _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background soft mountain & sun visual
          Positioned(
            right: 0,
            top: 0,
            width: 170.0,
            height: 90.0,
            child: const MountainSunVisual(
              height: 90.0,
              showFlag: true,
              showSunRays: true,
              sunPosition: Offset(0.75, 0.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu một mục tiêu mới',
                  style: ADayTypography.title.copyWith(fontSize: 19.0),
                ),
                const SizedBox(height: 4.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240.0),
                  child: Text(
                    'Kế hoạch hôm nay, một phiên bản tốt hơn của bạn ngày mai.',
                    style: ADayTypography.subhead.copyWith(
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: ADaySpacing.md),

                // Segmented Goal Type Selector
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: ADayColors.coolSurface,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    children: [
                      // Mục tiêu hằng ngày
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: _goalType == CreateGoalType.daily,
                          label: 'Chọn mục tiêu hằng ngày',
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _goalType = CreateGoalType.daily;
                                _endDate = null;
                                _dateError = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(10.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: _goalType == CreateGoalType.daily
                                    ? ADayColors.actionBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.light_mode_rounded,
                                    size: 16.0,
                                    color: _goalType == CreateGoalType.daily
                                        ? ADayColors.surface
                                        : ADayColors.brandNavy,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Flexible(
                                    child: Text(
                                      'Mục tiêu hằng ngày',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ADayTypography.label.copyWith(
                                        fontSize: 12.5,
                                        color: _goalType == CreateGoalType.daily
                                            ? ADayColors.surface
                                            : ADayColors.brandNavy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Mục tiêu dài hạn
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: _goalType == CreateGoalType.longTerm,
                          label: 'Chọn mục tiêu dài hạn',
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _goalType = CreateGoalType.longTerm;
                                _isRepeating = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(10.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: _goalType == CreateGoalType.longTerm
                                    ? ADayColors.actionBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    size: 16.0,
                                    color: _goalType == CreateGoalType.longTerm
                                        ? ADayColors.surface
                                        : ADayColors.brandNavy,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Flexible(
                                    child: Text(
                                      'Mục tiêu dài hạn',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ADayTypography.label.copyWith(
                                        fontSize: 12.5,
                                        color:
                                            _goalType == CreateGoalType.longTerm
                                            ? ADayColors.surface
                                            : ADayColors.brandNavy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: ADaySpacing.sm),
                Center(
                  child: Text(
                    _goalType.description,
                    textAlign: TextAlign.center,
                    style: ADayTypography.caption.copyWith(
                      color: ADayColors.mutedInk,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiêu đề mục tiêu',
                style: ADayTypography.label.copyWith(fontSize: 14.0),
              ),
              ListenableBuilder(
                listenable: _titleController,
                builder: (context, _) {
                  return Text(
                    '${_titleController.text.length}/100',
                    style: ADayTypography.caption.copyWith(
                      color: _titleController.text.length > 100
                          ? ADayColors.cancelCoral
                          : ADayColors.mutedInk,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.xs),
          TextField(
            controller: _titleController,
            maxLength: 100,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
            onChanged: (_) {
              if (_titleError != null) {
                setState(() {
                  _titleError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Ví dụ: Đọc sách 30 phút mỗi ngày',
              hintStyle: ADayTypography.body.copyWith(
                color: ADayColors.mutedInk.withValues(alpha: 0.7),
                fontSize: 14.5,
              ),
              errorText: _titleError,
              filled: true,
              fillColor: ADayColors.canvas,
              contentPadding: ADaySpacing.paddingInput,
              border: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(
                  color: ADayColors.actionBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: ADaySpacing.md),

          // Description Header & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mô tả (không bắt buộc)',
                style: ADayTypography.label.copyWith(fontSize: 14.0),
              ),
              ListenableBuilder(
                listenable: _descriptionController,
                builder: (context, _) {
                  return Text(
                    '${_descriptionController.text.length}/300',
                    style: ADayTypography.caption.copyWith(
                      color: _descriptionController.text.length > 300
                          ? ADayColors.cancelCoral
                          : ADayColors.mutedInk,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.xs),
          TextField(
            controller: _descriptionController,
            maxLength: 300,
            maxLines: 3,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
            decoration: InputDecoration(
              hintText: 'Viết thêm chi tiết về mục tiêu của bạn...',
              hintStyle: ADayTypography.body.copyWith(
                color: ADayColors.mutedInk.withValues(alpha: 0.7),
                fontSize: 14.5,
              ),
              filled: true,
              fillColor: ADayColors.canvas,
              contentPadding: ADaySpacing.paddingInput,
              border: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(
                  color: ADayColors.actionBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndPriorityRow() {
    return Row(
      children: [
        // Danh mục
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh mục', style: ADayTypography.label),
              const SizedBox(height: ADaySpacing.xs),
              Semantics(
                button: true,
                label: 'Chọn danh mục, hiện tại là $_category',
                child: InkWell(
                  onTap: _showCategoryPicker,
                  borderRadius: ADaySpacing.controlRadius,
                  child: Container(
                    height: 50.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: ADayColors.surface,
                      borderRadius: ADaySpacing.controlRadius,
                      border: Border.all(
                        color: ADayColors.dividerMist,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcon(_category),
                          size: 18.0,
                          color: ADayColors.actionBlue,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _category,
                            style: ADayTypography.bodyMedium.copyWith(
                              fontSize: 14.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: ADayColors.mutedInk,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ADaySpacing.md),

        // Mức độ ưu tiên
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mức độ ưu tiên', style: ADayTypography.label),
              const SizedBox(height: ADaySpacing.xs),
              Semantics(
                button: true,
                label: 'Chọn mức độ ưu tiên, hiện tại là ${_priority.label}',
                child: InkWell(
                  onTap: _showPriorityPicker,
                  borderRadius: ADaySpacing.controlRadius,
                  child: Container(
                    height: 50.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: ADayColors.surface,
                      borderRadius: ADaySpacing.controlRadius,
                      border: Border.all(
                        color: ADayColors.dividerMist,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _priority.icon,
                          size: 18.0,
                          color: _priority.color,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _priority.label,
                            style: ADayTypography.bodyMedium.copyWith(
                              fontSize: 14.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: ADayColors.mutedInk,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionRow() {
    if (_goalType == CreateGoalType.daily) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ngày thực hiện', style: ADayTypography.label),
          const SizedBox(height: ADaySpacing.xs),
          Semantics(
            button: true,
            label: 'Ngày thực hiện: ${_formatDateVietnamese(_startDate)}',
            child: InkWell(
              onTap: _pickStartDate,
              borderRadius: ADaySpacing.controlRadius,
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: ADayColors.surface,
                  borderRadius: ADaySpacing.controlRadius,
                  border: Border.all(color: ADayColors.dividerMist, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18.0,
                      color: ADayColors.actionBlue,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _formatDateVietnamese(_startDate),
                        style: ADayTypography.body.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: ADayColors.brandNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.0,
                      color: ADayColors.mutedInk,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Bắt đầu từ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bắt đầu từ', style: ADayTypography.label),
                  const SizedBox(height: ADaySpacing.xs),
                  Semantics(
                    button: true,
                    label: 'Ngày bắt đầu: ${_formatDateVietnamese(_startDate)}',
                    child: InkWell(
                      onTap: _pickStartDate,
                      borderRadius: ADaySpacing.controlRadius,
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: ADayColors.surface,
                          borderRadius: ADaySpacing.controlRadius,
                          border: Border.all(
                            color: ADayColors.dividerMist,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16.0,
                              color: ADayColors.actionBlue,
                            ),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                _formatDateVietnamese(_startDate),
                                style: ADayTypography.caption.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: ADayColors.brandNavy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.0,
                              color: ADayColors.mutedInk,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ADaySpacing.md),

            // Thời hạn (Deadline)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời hạn (Deadline)',
                    style: ADayTypography.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ADaySpacing.xs),
                  Semantics(
                    button: true,
                    label: _endDate != null
                        ? 'Thời hạn kết thúc: ${_formatDateVietnamese(_endDate!)}'
                        : 'Chọn ngày kết thúc',
                    child: InkWell(
                      onTap: _pickEndDate,
                      borderRadius: ADaySpacing.controlRadius,
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: ADayColors.surface,
                          borderRadius: ADaySpacing.controlRadius,
                          border: Border.all(
                            color: _dateError != null
                                ? ADayColors.cancelCoral
                                : ADayColors.dividerMist,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 16.0,
                              color: ADayColors.actionBlue,
                            ),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                _endDate != null
                                    ? _formatDateVietnamese(_endDate!)
                                    : 'Chọn ngày kết thúc',
                                style: ADayTypography.caption.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: _endDate != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _endDate != null
                                      ? ADayColors.brandNavy
                                      : ADayColors.mutedInk,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_endDate != null)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _endDate = null;
                                    _dateError = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.0,
                                  color: ADayColors.mutedInk,
                                ),
                              )
                            else
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18.0,
                                color: ADayColors.mutedInk,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_dateError != null) ...[
          const SizedBox(height: 4.0),
          Text(
            _dateError!,
            style: ADayTypography.caption.copyWith(
              color: ADayColors.cancelCoral,
              fontSize: 12.0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderSection() {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Row(
              children: [
                // Green Bell Icon
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8F0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF20C99A),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: ADaySpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhắc nhở',
                        style: ADayTypography.titleMedium.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Nhận thông báo để không bỏ lỡ mục tiêu.',
                        style: ADayTypography.caption.copyWith(
                          color: ADayColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _hasReminder,
                  activeTrackColor: const Color(0xFF20C99A),
                  onChanged: (val) {
                    setState(() {
                      _hasReminder = val;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_hasReminder) ...[
            Divider(
              height: 1.0,
              indent: ADaySpacing.md,
              endIndent: ADaySpacing.md,
              color: ADayColors.dividerMist,
            ),
            Semantics(
              button: true,
              label:
                  'Thời gian nhắc nhở: ${_formatTimeMinute(_reminderMinute)}',
              child: InkWell(
                onTap: _pickReminderTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ADaySpacing.md,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20.0,
                        color: ADayColors.actionBlue,
                      ),
                      const SizedBox(width: ADaySpacing.sm),
                      Expanded(
                        child: Text(
                          'Thời gian nhắc nhở',
                          style: ADayTypography.body.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeMinute(_reminderMinute),
                        style: ADayTypography.label.copyWith(
                          color: ADayColors.actionBlue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20.0,
                        color: ADayColors.mutedInk,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskListSection() {
    return SectionSurface(
      title: 'Danh sách nhiệm vụ',
      icon: Icons.checklist_rounded,
      iconColor: ADayColors.progressTeal,
      iconBackgroundColor: ADayColors.progressTealTint,
      headerTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: ADayColors.coolSurface,
          borderRadius: ADaySpacing.pillRadius,
        ),
        child: Text(
          '${_tasks.length} nhiệm vụ',
          style: ADayTypography.caption.copyWith(
            color: ADayColors.actionBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ADaySpacing.md,
              vertical: 4.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thêm các nhiệm vụ nhỏ để hoàn thành mục tiêu này.',
                style: ADayTypography.caption.copyWith(
                  color: ADayColors.mutedInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: ADaySpacing.xs),

          // Task items list
          ..._tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ADaySpacing.md,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      // Reorder icon handle
                      Icon(
                        Icons.drag_indicator_rounded,
                        size: 20.0,
                        color: ADayColors.mutedInk,
                      ),
                      const SizedBox(width: ADaySpacing.xs),

                      // Checkbox mockup
                      Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          borderRadius: ADaySpacing.checkboxRadius,
                          border: Border.all(
                            color: ADayColors.dividerMist,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),

                      // Title
                      Expanded(
                        child: Text(
                          task.title,
                          style: ADayTypography.bodyMedium.copyWith(
                            fontSize: 14.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.xs),

                      // Time chip
                      task.isAllDay
                          ? const StatusTimeChip.allDay()
                          : StatusTimeChip.time(timeRange: task.timeLabel),
                      const SizedBox(width: ADaySpacing.xs),

                      // Remove button
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18.0,
                          color: ADayColors.mutedInk,
                        ),
                        constraints: ADaySpacing.minTouchTargetConstraints,
                        onPressed: () {
                          setState(() {
                            _tasks.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (index < _tasks.length - 1)
                  Divider(
                    height: 1.0,
                    indent: ADaySpacing.md,
                    endIndent: ADaySpacing.md,
                    color: ADayColors.dividerMist,
                  ),
              ],
            );
          }),

          // "+ Thêm nhiệm vụ" button
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: ADayButton.secondary(
              label: 'Thêm nhiệm vụ',
              icon: Icons.add_rounded,
              height: 44.0,
              onPressed: _showAddTaskSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSection() {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Row(
        children: [
          // Blue Repeat Icon
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: ADayColors.coolSurface,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              Icons.sync_rounded,
              color: ADayColors.actionBlue,
              size: 22.0,
            ),
          ),
          const SizedBox(width: ADaySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lặp lại mục tiêu',
                  style: ADayTypography.titleMedium.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Tự động tạo lại mục tiêu này mỗi ngày.',
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isRepeating,
            activeThumbColor: const Color(0xFF20C99A),
            onChanged: (val) {
              setState(() {
                _isRepeating = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
