import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';

class ADayThemeChoice {
  const ADayThemeChoice({
    required this.id,
    required this.name,
    required this.previewAsset,
    required this.seed,
  });

  final String id;
  final String name;
  final String previewAsset;
  final Color seed;

  static const all = [
    ADayThemeChoice(
      id: 'default',
      name: 'Bình minh ADay',
      previewAsset: '',
      seed: ADayColors.actionBlue,
    ),
    ADayThemeChoice(
      id: 'theme_1',
      name: 'Mây dịu',
      previewAsset: 'Template_theme/1224c664-0fa7-4bc1-becc-8e7582192fe0.png',
      seed: Color(0xFF7D6CE0),
    ),
    ADayThemeChoice(
      id: 'theme_2',
      name: 'Nắng sớm',
      previewAsset: 'Template_theme/5cd0c0f3-cd20-4ab9-86e5-8b75607c2ca6.png',
      seed: Color(0xFFE58A23),
    ),
    ADayThemeChoice(
      id: 'theme_3',
      name: 'Rừng xanh',
      previewAsset: 'Template_theme/7c918954-8f69-4056-bd2a-9c91dc364e2c.png',
      seed: Color(0xFF25866E),
    ),
    ADayThemeChoice(
      id: 'theme_4',
      name: 'Hoàng hôn',
      previewAsset: 'Template_theme/7fa13b9e-eb4c-4b66-9920-72b403c38a4e.png',
      seed: Color(0xFFE06C61),
    ),
    ADayThemeChoice(
      id: 'theme_5',
      name: 'Đêm sao',
      previewAsset: 'Template_theme/e060c34f-67b8-4292-bf88-7cc09b1c4259.png',
      seed: Color(0xFF4669AA),
    ),
  ];

  static ADayThemeChoice byId(String id) =>
      all.firstWhere((choice) => choice.id == id, orElse: () => all.first);
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
              leading: const Icon(
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

class WidgetSetupScreen extends StatelessWidget {
  const WidgetSetupScreen({
    super.key,
    required this.themeId,
    required this.onAddWidget,
  });
  final String themeId;
  final Future<bool> Function() onAddWidget;
  @override
  Widget build(BuildContext context) {
    final choice = ADayThemeChoice.byId(themeId);
    return Scaffold(
      appBar: AppBar(title: const Text('Tiện ích màn hình chính')),
      body: Padding(
        padding: const EdgeInsets.all(ADaySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Xem hôm nay ngay trên màn hình chính',
              style: ADayTypography.title.copyWith(color: ADayColors.brandNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tiện ích hiển thị ngày, việc còn lại và tiến độ. Màu sắc sẽ theo giao diện bạn đang chọn.',
            ),
            const Spacer(),
            _WidgetPreview(color: choice.seed),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                final added = await onAddWidget();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? 'Đã mở trình thêm tiện ích.'
                            : 'Hãy nhấn giữ màn hình chính, chọn Tiện ích rồi tìm ADay.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_to_home_screen_rounded),
              label: const Text('Thêm vào màn hình chính'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetPreview extends StatelessWidget {
  const _WidgetPreview({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    height: 180,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hôm nay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text('3 việc còn lại', style: TextStyle(color: Colors.white)),
        Spacer(),
        LinearProgressIndicator(
          value: .55,
          color: Colors.white,
          backgroundColor: Colors.white38,
        ),
        SizedBox(height: 8),
        Text('55% đã hoàn thành', style: TextStyle(color: Colors.white)),
      ],
    ),
  );
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
          const Icon(
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
