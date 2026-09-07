// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../models/task_view_item.dart';

class ADayThemeChoice {
  const ADayThemeChoice({
    required this.id,
    required this.name,
    required this.previewAsset,
    required this.seed,
    this.widgetTemplateAsset = '',
  });

  final String id;
  final String name;
  final String previewAsset;
  final Color seed;
  final String widgetTemplateAsset;

  static const all = [
    ADayThemeChoice(
      id: 'default',
      name: 'Bình minh ADay',
      previewAsset: '',
      seed: ADayColors.defaultActionBlue,
      widgetTemplateAsset:
          'assets/templates/widgets/e77250d3-5a31-47a4-9e9c-c8df84d39209.png',
    ),
    ADayThemeChoice(
      id: 'theme_1',
      name: 'Lavender Dream',
      previewAsset:
          'assets/templates/theme/1224c664-0fa7-4bc1-becc-8e7582192fe0.png',
      seed: Color(0xFF7C3AED),
      widgetTemplateAsset:
          'assets/templates/widgets/e77250d3-5a31-47a4-9e9c-c8df84d39209.png',
    ),
    ADayThemeChoice(
      id: 'theme_2',
      name: 'Sunset Peach',
      previewAsset:
          'assets/templates/theme/5cd0c0f3-cd20-4ab9-86e5-8b75607c2ca6.png',
      seed: Color(0xFFF97316),
      widgetTemplateAsset:
          'assets/templates/widgets/d19e18f6-30a2-4d4c-8764-37b48e2c3d87.png',
    ),
    ADayThemeChoice(
      id: 'theme_3',
      name: 'Midnight Indigo (Chế độ tối)',
      previewAsset:
          'assets/templates/theme/7c918954-8f69-4056-bd2a-9c91dc364e2c.png',
      seed: Color(0xFF38BDF8),
      widgetTemplateAsset:
          'assets/templates/widgets/92dcdfd1-9e10-4473-bebb-103e504b5709.png',
    ),
    ADayThemeChoice(
      id: 'theme_4',
      name: 'Rose Blush',
      previewAsset:
          'assets/templates/theme/7fa13b9e-eb4c-4b66-9920-72b403c38a4e.png',
      seed: Color(0xFFE11D48),
      widgetTemplateAsset:
          'assets/templates/widgets/e8831994-5c8e-4051-90ec-00c2219490db.png',
    ),
    ADayThemeChoice(
      id: 'theme_5',
      name: 'Forest Sage',
      previewAsset:
          'assets/templates/theme/e060c34f-67b8-4292-bf88-7cc09b1c4259.png',
      seed: Color(0xFF2E7D57),
      widgetTemplateAsset:
          'assets/templates/widgets/faa8555e-2cb2-48c7-9758-a9f0745ea0fe.png',
    ),
  ];

  static ADayThemeChoice byId(String id) =>
      all.firstWhere((choice) => choice.id == id, orElse: () => all.first);

  static String widgetTemplateForId(String id) => byId(id).widgetTemplateAsset;
}

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chọn giao diện')),
    body: ListView(
      padding: const EdgeInsets.all(ADaySpacing.md),
      children: [
        Text(
          'Một diện mạo cho nhịp sống của bạn',
          style: ADayTypography.title.copyWith(color: ADayColors.brandNavy),
        ),
        const SizedBox(height: 6),
        const Text(
          'Giao diện mặc định giữ nguyên phong cách ADay hiện tại. Bạn có thể đổi lại bất cứ lúc nào.',
        ),
        const SizedBox(height: ADaySpacing.md),
        ...ADayThemeChoice.all.map(
          (choice) => _ThemeTile(
            choice: choice,
            selected: choice.id == selectedId,
            onTap: () {
              onSelected(choice.id);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
  );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });
  final ADayThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      selected: selected,
      button: true,
      label: '${choice.name}${selected ? ', đang dùng' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 128,
          decoration: BoxDecoration(
            color: choice.seed.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? choice.seed : ADayColors.dividerMist,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 132,
                height: double.infinity,
                child: choice.previewAsset.isEmpty
                    ? _DefaultPreview(color: choice.seed)
                    : Image.asset(
                        choice.previewAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _DefaultPreview(color: choice.seed),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  choice.name,
                  style: ADayTypography.title.copyWith(
                    fontSize: 16,
                    color: ADayColors.brandNavy,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? choice.seed : ADayColors.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DefaultPreview extends StatelessWidget {
  const _DefaultPreview({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    color: color,
    padding: const EdgeInsets.all(12),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADay',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: SizedBox(width: double.infinity, height: 24),
        ),
      ],
    ),
  );
}

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({
    super.key,
    required this.quotes,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> quotes;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Câu nói mỗi ngày')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _addQuote(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Thêm câu nói'),
    ),
    body: quotes.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Thêm một lời nhắn cho bản thân. ADay sẽ luân phiên hiển thị khi bạn mở ứng dụng.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(ADaySpacing.md),
            itemCount: quotes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) => ListTile(
              tileColor: ADayColors.coolSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                Icons.format_quote_rounded,
                color: ADayColors.actionBlue,
              ),
              title: Text('“${quotes[index]}”'),
              trailing: IconButton(
                tooltip: 'Xóa câu nói',
                onPressed: () => onRemove(quotes[index]),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
          ),
  );

  Future<void> _addQuote(BuildContext context) async {
    final editor = TextEditingController();
    final quote = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm câu nói'),
        content: TextField(
          controller: editor,
          autofocus: true,
          maxLength: 180,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Mỗi bước nhỏ đều đáng giá.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, editor.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    editor.dispose();
    if (quote != null && quote.trim().isNotEmpty) {
      onAdd(quote);
    }
  }
}

class WidgetSetupScreen extends StatefulWidget {
  const WidgetSetupScreen({
    super.key,
    required this.themeId,
    required this.onAddWidget,
    this.todayTasks,
    this.completedCount,
    this.totalCount,
    this.completionPercent,
    this.onApplyTheme,
  });

  final String themeId;
  final Future<bool> Function() onAddWidget;
  final List<TaskViewItem>? todayTasks;
  final int? completedCount;
  final int? totalCount;
  final int? completionPercent;
  final ValueChanged<String>? onApplyTheme;

  @override
  State<WidgetSetupScreen> createState() => _WidgetSetupScreenState();
}

class _WidgetSetupScreenState extends State<WidgetSetupScreen> {
  late String _selectedThemeId;
  int _viewMode = 0; // 0: Live Widget Card, 1: Mẫu Launcher mẫu

  @override
  void initState() {
    super.initState();
    _selectedThemeId = widget.themeId;
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeChoice = ADayThemeChoice.byId(_selectedThemeId);
    final palette = ADayThemePalette.forId(_selectedThemeId);
    final templateImage = ADayThemeChoice.widgetTemplateForId(_selectedThemeId);

    return Scaffold(
      appBar: AppBar(title: const Text('Tiện ích màn hình chính')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ADaySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Xem hôm nay ngay trên màn hình chính',
              style: ADayTypography.title.copyWith(color: ADayColors.brandNavy),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiện ích 2 cột hiển thị tiến độ, lịch nhỏ tháng này và nhiệm vụ hôm nay theo đúng 5 mẫu thiết kế.',
              style: ADayTypography.caption.copyWith(
                color: ADayColors.mutedInk,
              ),
            ),
            const SizedBox(height: 16),

            // Segmented mode toggle: Thẻ tiện ích | Ảnh mẫu Launcher
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.widgets_rounded),
                  label: Text('Thẻ tiện ích'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.phone_android_rounded),
                  label: Text('Mẫu launcher'),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (newSelection) {
                setState(() => _viewMode = newSelection.first);
              },
            ),
            const SizedBox(height: 14),

            // Theme selector chips: 5 templates
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ADayThemeChoice.all.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final choice = ADayThemeChoice.all[index];
                  final isSelected = choice.id == _selectedThemeId;
                  final isCurrentApp = choice.id == widget.themeId;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: choice.seed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(choice.name),
                        if (isCurrentApp) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 12),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedThemeId = choice.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Live Preview or Launcher Mockup
            if (_viewMode == 0)
              ADayFaithfulWidgetPreview(
                themeId: _selectedThemeId,
                palette: palette,
                todayTasks: widget.todayTasks,
                completedCount: widget.completedCount ?? 4,
                totalCount: widget.totalCount ?? 6,
                completionPercent: widget.completionPercent ?? 67,
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 480,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ADayColors.dividerMist),
                  ),
                  child: templateImage.isNotEmpty
                      ? Image.asset(
                          templateImage,
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        )
                      : Center(
                          child: Text(
                            'Chưa có ảnh mẫu cho giao diện này',
                            style: ADayTypography.caption,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: 18),

            // Button to apply theme if different from current
            if (widget.onApplyTheme != null &&
                _selectedThemeId != widget.themeId) ...[
              OutlinedButton.icon(
                onPressed: () {
                  widget.onApplyTheme!(_selectedThemeId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã áp dụng giao diện "${currentThemeChoice.name}" cho toàn bộ ứng dụng!',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.color_lens_outlined),
                label: Text(
                  'Áp dụng "${currentThemeChoice.name}" cho ứng dụng',
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Button to Add to Home Screen
            FilledButton.icon(
              onPressed: () async {
                final added = await widget.onAddWidget();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? 'Đã mở trình thêm tiện ích vào màn hình chính.'
                            : 'Hãy nhấn giữ màn hình chính, chọn Tiện ích rồi tìm ADay.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_to_home_screen_rounded),
              label: const Text('Thêm vào màn hình chính'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A faithful Flutter recreation of the 2-column widget card from the 5 templates in assets/templates/widgets.
class ADayFaithfulWidgetPreview extends StatelessWidget {
  const ADayFaithfulWidgetPreview({
    super.key,
    required this.themeId,
    required this.palette,
    this.todayTasks,
    this.completedCount = 4,
    this.totalCount = 6,
    this.completionPercent = 67,
  });

  final String themeId;
  final ADayThemePalette palette;
  final List<TaskViewItem>? todayTasks;
  final int completedCount;
  final int totalCount;
  final int completionPercent;

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final now = DateTime.now();

    // Background gradient matching the theme templates
    final bgGradient = switch (themeId) {
      'theme_3' => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B132B), Color(0xFF162544)],
      ),
      'theme_2' => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF8F3), Color(0xFFFFECE0)],
      ),
      'theme_1' => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAF7FF), Color(0xFFEFE8FD)],
      ),
      'theme_4' => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF2F4), Color(0xFFFFE6EB)],
      ),
      'theme_5' => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF3FAF5), Color(0xFFE4F4EB)],
      ),
      _ => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF4FAFF), Color(0xFFE5F2FD)],
      ),
    };

    final cardBorderColor = isDark
        ? const Color(0x4D22D3EE)
        : palette.dividerMist;

    final subCardBg = isDark ? const Color(0xCC16203D) : palette.surface;

    final subCardBorderColor = isDark
        ? const Color(0x3322D3EE)
        : palette.dividerMist.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x66000000)
                : palette.actionBlue.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Header Row: Logo, Title, Quote & Themed artwork
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ADay Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: palette.appIconGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: palette.actionBlue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // App Title + Slogan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ADay',
                    style: TextStyle(
                      color: palette.brandNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Plan Today • A Better Tomorrow',
                    style: TextStyle(
                      color: palette.mutedInk,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Quote & Themed Artwork
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '“Kiên trì hôm nay,\nthành công ngày mai!”',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: palette.brandNavy,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildThemeBadge(themeId),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: palette.dividerMist.withOpacity(0.5)),
          const SizedBox(height: 10),

          // 2. Main 2-Column Body: Left (Progress + Mini Calendar) & Right (Today Tasks)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Progress Ring & Mini Calendar Month
              Expanded(
                flex: 43,
                child: Column(
                  children: [
                    // A. Progress Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: subCardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: subCardBorderColor),
                      ),
                      child: Row(
                        children: [
                          // Circular percentage ring
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: (completionPercent / 100).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  strokeWidth: 4.5,
                                  backgroundColor: isDark
                                      ? const Color(0x3322D3EE)
                                      : palette.dividerMist.withOpacity(0.6),
                                  color: isDark
                                      ? const Color(0xFF22D3EE)
                                      : palette.actionBlue,
                                ),
                                Text(
                                  '$completionPercent%',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.brandNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Summary text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Đã hoàn thành',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: palette.mutedInk,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$completedCount / $totalCount',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.brandNavy,
                                  ),
                                ),
                                Text(
                                  'nhiệm vụ',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: palette.mutedInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // B. Mini Calendar Month Card
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: subCardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: subCardBorderColor),
                      ),
                      child: _buildMiniCalendar(now, isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right Column: Today Tasks Card
              Expanded(
                flex: 57,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: subCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: subCardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Nhiệm vụ hôm nay | Xem tất cả >
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nhiệm vụ hôm nay',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: palette.brandNavy,
                            ),
                          ),
                          Text(
                            'Xem tất cả ›',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF22D3EE)
                                  : palette.actionBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Task Items
                      ..._buildWidgetTasks(isDark),

                      const SizedBox(height: 6),

                      // Bottom Encouragement Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.coolSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _buildFooterMessage(themeId),
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: palette.brandNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeBadge(String themeId) {
    return switch (themeId) {
      'theme_3' => const Text('🌙 ✨', style: TextStyle(fontSize: 11)),
      'theme_2' => const Text('🌅 🕊️', style: TextStyle(fontSize: 11)),
      'theme_1' => const Text('💜 🌸', style: TextStyle(fontSize: 11)),
      'theme_4' => const Text('🌸 💕', style: TextStyle(fontSize: 11)),
      'theme_5' => const Text('🍃 ⛰️', style: TextStyle(fontSize: 11)),
      _ => const Text('☀️ 🏔️', style: TextStyle(fontSize: 11)),
    };
  }

  String _buildFooterMessage(String themeId) {
    return switch (themeId) {
      'theme_3' => '✨ Kỷ luật ban đêm, thành công ngày mai!',
      'theme_2' => '☀️ Mỗi ngày tốt hơn một chút!',
      'theme_1' => '💜 Mỗi ngày tốt hơn một chút!',
      'theme_4' => '🌸 Nở rộ từng ngày cùng mục tiêu!',
      'theme_5' => '🍃 Bền bỉ vươn lên từng bước nhỏ!',
      _ => '✨ Mỗi ngày tốt hơn một chút!',
    };
  }

  Widget _buildMiniCalendar(DateTime date, bool isDark) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    // 1 (Monday) to 7 (Sunday)
    final startingWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Month Title Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chevron_left_rounded, size: 13, color: palette.mutedInk),
            Text(
              'Tháng ${date.month}, ${date.year}',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: palette.brandNavy,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 13,
              color: palette.mutedInk,
            ),
          ],
        ),
        const SizedBox(height: 3),
        // Weekday Row: T2 - CN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
              .map(
                (w) => Text(
                  w,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E9BAE),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 3),
        // Days Grid (5 rows of 7 days)
        ...List.generate(5, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - (startingWeekday - 1) + 1;
                final isCurrentMonth =
                    dayNumber >= 1 && dayNumber <= daysInMonth;
                final isToday = isCurrentMonth && dayNumber == date.day;

                String label;
                if (isCurrentMonth) {
                  label = '$dayNumber';
                } else if (dayNumber < 1) {
                  // Prev month trailing
                  final prevDays = DateUtils.getDaysInMonth(
                    date.month == 1 ? date.year - 1 : date.year,
                    date.month == 1 ? 12 : date.month - 1,
                  );
                  label = '${prevDays + dayNumber}';
                } else {
                  // Next month leading
                  label = '${dayNumber - daysInMonth}';
                }

                if (isToday) {
                  return Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF22D3EE)
                          : palette.actionBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: 15,
                  height: 15,
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: isCurrentMonth
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: isCurrentMonth
                            ? palette.brandNavy
                            : palette.mutedInk.withOpacity(0.35),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildWidgetTasks(bool isDark) {
    // Up to 4 tasks from user or faithfully mapped to template
    final templateMocks = [
      (
        title: 'Đọc sách 30 phút',
        sub: 'Phát triển bản thân',
        icon: '📖',
        time: 'Cả ngày',
        done: true,
      ),
      (
        title: 'Tập thể dục',
        sub: 'Sức khỏe là nền tảng',
        icon: '🏋️',
        time: 'Cả ngày',
        done: true,
      ),
      (
        title: 'Học Flutter 1 giờ',
        sub: 'Nâng cao kỹ năng',
        icon: '💻',
        time: '20:00',
        done: false,
      ),
      (
        title: 'Họp nhóm dự án',
        sub: 'Trao đổi tiến độ tuần này',
        icon: '👥',
        time: '10:00',
        done: false,
      ),
    ];

    final items =
        <(String title, String sub, String icon, String time, bool done)>[];

    if (todayTasks != null && todayTasks!.isNotEmpty) {
      for (final t in todayTasks!.take(4)) {
        items.add((
          t.title,
          (t.category != null && t.category!.isNotEmpty)
              ? t.category!
              : 'Nhiệm vụ',
          t.isCompleted ? '✅' : '📌',
          t.isAllDay ? 'Cả ngày' : (t.timeLabel ?? 'Hôm nay'),
          t.isCompleted,
        ));
      }
    }

    while (items.length < 4) {
      final mock = templateMocks[items.length];
      items.add((mock.title, mock.sub, mock.icon, mock.time, mock.done));
    }

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: item.$5
                    ? (isDark
                          ? const Color(0xFF10B981)
                          : const Color(0xFF22C55E))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.5),
                border: item.$5
                    ? null
                    : Border.all(
                        color: palette.mutedInk.withOpacity(0.5),
                        width: 1.2,
                      ),
              ),
              child: item.$5
                  ? const Center(
                      child: Icon(Icons.check, size: 10, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 5),
            // Category Emoji
            Text(item.$3, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 5),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: palette.brandNavy,
                    ),
                  ),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 7.5, color: palette.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Time Pill Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2422D3EE) : palette.coolSurface,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isDark ? const Color(0x3322D3EE) : palette.dividerMist,
                  width: 0.8,
                ),
              ),
              child: Text(
                item.$4,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : palette.mutedInk,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class DriveBackupScreen extends StatefulWidget {
  const DriveBackupScreen({
    super.key,
    required this.accountEmail,
    required this.lastBackupAt,
    required this.onBackup,
  });

  final String? accountEmail;
  final DateTime? lastBackupAt;
  final Future<void> Function() onBackup;

  @override
  State<DriveBackupScreen> createState() => _DriveBackupScreenState();
}

class _DriveBackupScreenState extends State<DriveBackupScreen> {
  bool _isBackingUp = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sao lưu Google Drive')),
    body: Padding(
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: ADayColors.actionBlue,
            size: 42,
          ),
          const SizedBox(height: 16),
          Text(
            'Bản sao riêng tư cho ADay',
            textAlign: TextAlign.center,
            style: ADayTypography.title.copyWith(color: ADayColors.brandNavy),
          ),
          const SizedBox(height: 8),
          const Text(
            'ADay chỉ ghi một tệp sao lưu trong vùng dữ liệu riêng của ứng dụng trên Google Drive. Tệp này không xuất hiện trong Drive thông thường và không được chia sẻ.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ListTile(
            tileColor: ADayColors.coolSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(widget.accountEmail ?? 'Chưa kết nối Google Drive'),
            subtitle: Text(
              widget.accountEmail == null
                  ? 'Chọn tài khoản Google khi sao lưu lần đầu.'
                  : 'Đã cấp quyền Google cho ADay.',
            ),
          ),
          if (widget.lastBackupAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Sao lưu gần nhất: ${widget.lastBackupAt!.day.toString().padLeft(2, '0')}/${widget.lastBackupAt!.month.toString().padLeft(2, '0')}/${widget.lastBackupAt!.year} lúc ${widget.lastBackupAt!.hour.toString().padLeft(2, '0')}:${widget.lastBackupAt!.minute.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: ADayTypography.caption,
            ),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: _isBackingUp
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    setState(() => _isBackingUp = true);
                    try {
                      await widget.onBackup();
                      if (mounted) navigator.pop();
                    } finally {
                      if (mounted) setState(() => _isBackingUp = false);
                    }
                  },
            icon: _isBackingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(_isBackingUp ? 'Đang sao lưu...' : 'Sao lưu ngay'),
          ),
        ],
      ),
    ),
  );
}
