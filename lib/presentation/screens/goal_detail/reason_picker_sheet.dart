import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_button.dart';

enum ReasonPickerType { postpone, cancel }

/// Result model containing the chosen postponement date and user reason.
class PostponeSelection {
  const PostponeSelection({required this.untilDate, required this.reason});

  final DateTime untilDate;
  final String reason;
}

/// Accessible bottom sheet modal to collect target date & reason for postponing,
/// or reason for cancelling a goal.
///
/// Features:
/// - Target date picker with smart Vietnamese quick chips (Ngày mai, 2 ngày nữa, Đầu tuần sau, Chọn ngày)
/// - Predefined Vietnamese options matching ADay product tone (supportive, non-judgmental)
/// - Optional custom reason text field when "Lý do khác" is selected
/// - Touch targets >= 44x44
/// - Keyboard friendly and semantics labeled
class ReasonPickerSheet extends StatefulWidget {
  const ReasonPickerSheet({
    super.key,
    required this.type,
    this.predefinedReasons,
    this.initialDate,
  });

  final ReasonPickerType type;
  final List<String>? predefinedReasons;
  final DateTime? initialDate;

  /// Helper static method to display the postpone modal sheet.
  static Future<PostponeSelection?> showPostpone(
    BuildContext context, {
    DateTime? initialDate,
    List<String>? predefinedReasons,
  }) {
    return showModalBottomSheet<PostponeSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) => ReasonPickerSheet(
        type: ReasonPickerType.postpone,
        initialDate: initialDate,
        predefinedReasons: predefinedReasons,
      ),
    );
  }

  /// Helper static method to display the cancel modal sheet.
  static Future<String?> showCancel(
    BuildContext context, {
    List<String>? predefinedReasons,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) => ReasonPickerSheet(
        type: ReasonPickerType.cancel,
        predefinedReasons: predefinedReasons,
      ),
    );
  }

  /// Backwards-compatible helper static method.
  static Future<dynamic> show(
    BuildContext context, {
    required ReasonPickerType type,
    List<String>? predefinedReasons,
  }) {
    if (type == ReasonPickerType.postpone) {
      return showPostpone(context, predefinedReasons: predefinedReasons);
    }
    return showCancel(context, predefinedReasons: predefinedReasons);
  }

  @override
  State<ReasonPickerSheet> createState() => _ReasonPickerSheetState();
}

class _ReasonPickerSheetState extends State<ReasonPickerSheet> {
  late final List<String> _reasons;
  late String _selectedReason;
  late DateTime _selectedDate;
  final _customReasonController = TextEditingController();
  bool _isCustomSelected = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultDate =
        widget.initialDate ??
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _selectedDate = DateTime(
      defaultDate.year,
      defaultDate.month,
      defaultDate.day,
    );

    if (widget.predefinedReasons != null &&
        widget.predefinedReasons!.isNotEmpty) {
      _reasons = widget.predefinedReasons!;
    } else if (widget.type == ReasonPickerType.postpone) {
      _reasons = const [
        'Bận việc đột xuất',
        'Chưa đủ thời gian hôm nay',
        'Cần thêm tài liệu hoặc chuẩn bị',
        'Sức khỏe không tốt, cần nghỉ ngơi',
      ];
    } else {
      _reasons = const [
        'Kế hoạch hoặc ưu tiên đã thay đổi',
        'Không còn phù hợp với mục tiêu hiện tại',
        'Đã gộp vào một mục tiêu khác',
        'Quá tải khối lượng công việc',
      ];
    }
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

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
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month/${date.year}';
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final initial = _selectedDate.isBefore(tomorrow) ? tomorrow : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Chọn ngày muốn hoãn đến',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _handleConfirm() {
    String finalReason;
    if (_isCustomSelected) {
      final text = _customReasonController.text.trim();
      finalReason = text.isNotEmpty ? text : 'Lý do khác';
    } else {
      finalReason = _selectedReason;
    }

    if (widget.type == ReasonPickerType.postpone) {
      Navigator.of(
        context,
      ).pop(PostponeSelection(untilDate: _selectedDate, reason: finalReason));
    } else {
      Navigator.of(context).pop(finalReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPostpone = widget.type == ReasonPickerType.postpone;
    final title = isPostpone ? 'Tạm hoãn mục tiêu' : 'Hủy mục tiêu';
    final icon = isPostpone ? Icons.schedule_rounded : Icons.cancel_rounded;
    final accentColor = isPostpone
        ? const Color(0xFFD68A0A)
        : ADayColors.cancelCoral;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final inTwoDays = today.add(const Duration(days: 2));

    int daysUntilNextMonday = (8 - today.weekday) % 7;
    if (daysUntilNextMonday <= 1) daysUntilNextMonday += 7;
    final nextMonday = today.add(Duration(days: daysUntilNextMonday));

    return Padding(
      padding: EdgeInsets.only(
        left: ADaySpacing.md,
        right: ADaySpacing.md,
        top: ADaySpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + ADaySpacing.md,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: isPostpone
                          ? const Color(0xFFFFF3DB)
                          : ADayColors.cancelCoralTint,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(icon, color: accentColor, size: 20.0),
                  ),
                  const SizedBox(width: ADaySpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: ADayTypography.title.copyWith(fontSize: 18.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: ADayColors.mutedInk),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: ADaySpacing.xs),
              Text(
                isPostpone
                    ? 'Chọn ngày dời đến và chia sẻ lý do ngắn gọn để ADay tự động sắp xếp lại các nhiệm vụ cho bạn.'
                    : 'Chia sẻ ngắn gọn để ADay ghi nhận và giúp bạn điều chỉnh kế hoạch tốt hơn mà không tạo áp lực.',
                style: ADayTypography.subhead.copyWith(
                  fontSize: 13.5,
                  color: ADayColors.mutedInk,
                ),
              ),

              // Date Selection Section (Only for Postpone)
              if (isPostpone) ...[
                const SizedBox(height: ADaySpacing.md),
                Text(
                  'Hoãn đến ngày:',
                  style: ADayTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ADayColors.brandNavy,
                  ),
                ),
                const SizedBox(height: ADaySpacing.xs),

                // Selected Date Display Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9EE),
                    borderRadius: ADaySpacing.controlRadius,
                    border: Border.all(
                      color: const Color(0xFFFFD569),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20.0,
                        color: Color(0xFFD68A0A),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _formatDateVietnamese(_selectedDate),
                          style: ADayTypography.body.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A4800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),

                // Quick pick chips
                Wrap(
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: [
                    _buildDateChip(
                      label: 'Ngày mai (${tomorrow.day}/${tomorrow.month})',
                      targetDate: tomorrow,
                    ),
                    _buildDateChip(
                      label: '2 ngày nữa (${inTwoDays.day}/${inTwoDays.month})',
                      targetDate: inTwoDays,
                    ),
                    _buildDateChip(
                      label:
                          'Đầu tuần sau (${nextMonday.day}/${nextMonday.month})',
                      targetDate: nextMonday,
                    ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.calendar_month_rounded,
                        size: 16.0,
                        color: Color(0xFFD68A0A),
                      ),
                      label: Text(
                        'Chọn ngày khác...',
                        style: ADayTypography.caption.copyWith(
                          color: const Color(0xFF7A4800),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: ADayColors.coolSurface,
                      side: BorderSide(color: ADayColors.dividerMist),
                      shape: RoundedRectangleBorder(
                        borderRadius: ADaySpacing.pillRadius,
                      ),
                      onPressed: _pickCustomDate,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: ADaySpacing.md),
              Text(
                isPostpone ? 'Lý do tạm hoãn:' : 'Lý do hủy:',
                style: ADayTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ADayColors.brandNavy,
                ),
              ),
              const SizedBox(height: ADaySpacing.xs),

              // Predefined options
              ..._reasons.map((reason) {
                final isChosen =
                    !_isCustomSelected && _selectedReason == reason;
                return Semantics(
                  button: true,
                  selected: isChosen,
                  label: reason,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedReason = reason;
                        _isCustomSelected = false;
                      });
                    },
                    borderRadius: ADaySpacing.controlRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      margin: const EdgeInsets.only(bottom: 6.0),
                      decoration: BoxDecoration(
                        color: isChosen
                            ? (isPostpone
                                  ? const Color(0xFFFFF3DB)
                                  : ADayColors.cancelCoralTint)
                            : ADayColors.coolSurface,
                        borderRadius: ADaySpacing.controlRadius,
                        border: Border.all(
                          color: isChosen ? accentColor : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isChosen
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            size: 20.0,
                            color: isChosen ? accentColor : ADayColors.mutedInk,
                          ),
                          const SizedBox(width: ADaySpacing.sm),
                          Expanded(
                            child: Text(
                              reason,
                              style: ADayTypography.bodyMedium.copyWith(
                                fontSize: 14.0,
                                color: isChosen
                                    ? ADayColors.brandNavy
                                    : ADayColors.brandNavy.withValues(
                                        alpha: 0.8,
                                      ),
                                fontWeight: isChosen
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // "Lý do khác" option
              Semantics(
                button: true,
                selected: _isCustomSelected,
                label: 'Lý do khác',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isCustomSelected = true;
                    });
                  },
                  borderRadius: ADaySpacing.controlRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10.0,
                    ),
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: BoxDecoration(
                      color: _isCustomSelected
                          ? (isPostpone
                                ? const Color(0xFFFFF3DB)
                                : ADayColors.cancelCoralTint)
                          : ADayColors.coolSurface,
                      borderRadius: ADaySpacing.controlRadius,
                      border: Border.all(
                        color: _isCustomSelected
                            ? accentColor
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCustomSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 20.0,
                          color: _isCustomSelected
                              ? accentColor
                              : ADayColors.mutedInk,
                        ),
                        const SizedBox(width: ADaySpacing.sm),
                        Expanded(
                          child: Text(
                            'Lý do khác...',
                            style: ADayTypography.bodyMedium.copyWith(
                              fontSize: 14.0,
                              color: _isCustomSelected
                                  ? ADayColors.brandNavy
                                  : ADayColors.brandNavy.withValues(alpha: 0.8),
                              fontWeight: _isCustomSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Custom reason text field if selected
              if (_isCustomSelected) ...[
                const SizedBox(height: ADaySpacing.xs),
                TextField(
                  controller: _customReasonController,
                  autofocus: true,
                  maxLines: 2,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Nhập chi tiết lý do của bạn...',
                    hintStyle: ADayTypography.body.copyWith(
                      color: ADayColors.mutedInk,
                      fontSize: 13.5,
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
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: ADaySpacing.md),

              // Confirm Button
              ADayButton(
                label: isPostpone
                    ? 'Xác nhận tạm hoãn'
                    : 'Xác nhận hủy mục tiêu',
                variant: isPostpone
                    ? ADayButtonVariant.primary
                    : ADayButtonVariant.destructive,
                onPressed: _handleConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip({required String label, required DateTime targetDate}) {
    final isSelected =
        _selectedDate.year == targetDate.year &&
        _selectedDate.month == targetDate.month &&
        _selectedDate.day == targetDate.day;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: ADayTypography.caption.copyWith(
        color: isSelected ? Colors.white : const Color(0xFF7A4800),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      selectedColor: const Color(0xFFD68A0A),
      backgroundColor: ADayColors.coolSurface,
      side: BorderSide(
        color: isSelected ? const Color(0xFFD68A0A) : ADayColors.dividerMist,
      ),
      shape: RoundedRectangleBorder(borderRadius: ADaySpacing.pillRadius),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDate = targetDate;
          });
        }
      },
    );
  }
}
