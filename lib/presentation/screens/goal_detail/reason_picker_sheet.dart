import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_button.dart';

enum ReasonPickerType { postpone, cancel }

/// Accessible bottom sheet modal to collect a reason for postponing or cancelling a goal.
///
/// Features:
/// - Predefined Vietnamese options matching ADay product tone (supportive, non-judgmental)
/// - Optional custom reason text field when "Lý do khác" is selected
/// - Touch targets >= 44x44
/// - Keyboard friendly and semantics labeled
class ReasonPickerSheet extends StatefulWidget {
  const ReasonPickerSheet({
    super.key,
    required this.type,
    this.predefinedReasons,
  });

  final ReasonPickerType type;
  final List<String>? predefinedReasons;

  /// Helper static method to display the modal bottom sheet.
  static Future<String?> show(
    BuildContext context, {
    required ReasonPickerType type,
    List<String>? predefinedReasons,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ADayColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) =>
          ReasonPickerSheet(type: type, predefinedReasons: predefinedReasons),
    );
  }

  @override
  State<ReasonPickerSheet> createState() => _ReasonPickerSheetState();
}

class _ReasonPickerSheetState extends State<ReasonPickerSheet> {
  late final List<String> _reasons;
  late String _selectedReason;
  final _customReasonController = TextEditingController();
  bool _isCustomSelected = false;

  @override
  void initState() {
    super.initState();
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

  void _handleConfirm() {
    String finalReason;
    if (_isCustomSelected) {
      final text = _customReasonController.text.trim();
      finalReason = text.isNotEmpty ? text : 'Lý do khác';
    } else {
      finalReason = _selectedReason;
    }
    Navigator.of(context).pop(finalReason);
  }

  @override
  Widget build(BuildContext context) {
    final isPostpone = widget.type == ReasonPickerType.postpone;
    final title = isPostpone ? 'Tạm hoãn mục tiêu' : 'Hủy mục tiêu';
    final icon = isPostpone ? Icons.schedule_rounded : Icons.cancel_rounded;
    final accentColor = isPostpone
        ? ADayColors.sunriseGold
        : ADayColors.cancelCoral;

    return Padding(
      padding: EdgeInsets.only(
        left: ADaySpacing.md,
        right: ADaySpacing.md,
        top: ADaySpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + ADaySpacing.md,
      ),
      child: SafeArea(
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
                        ? ADayColors.sunriseGoldTint
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
              'Chia sẻ ngắn gọn để ADay ghi nhận và giúp bạn điều chỉnh kế hoạch tốt hơn mà không tạo áp lực.',
              style: ADayTypography.subhead.copyWith(
                fontSize: 13.5,
                color: ADayColors.mutedInk,
              ),
            ),
            const SizedBox(height: ADaySpacing.md),

            // Predefined options
            ..._reasons.map((reason) {
              final isChosen = !_isCustomSelected && _selectedReason == reason;
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
                                ? ADayColors.sunriseGoldTint
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
                                  : ADayColors.brandNavy.withValues(alpha: 0.8),
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
                              ? ADayColors.sunriseGoldTint
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
              label: isPostpone ? 'Xác nhận tạm hoãn' : 'Xác nhận hủy mục tiêu',
              variant: isPostpone
                  ? ADayButtonVariant.primary
                  : ADayButtonVariant.destructive,
              onPressed: _handleConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
