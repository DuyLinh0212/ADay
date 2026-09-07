import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../models/task_view_item.dart';
import '../../widgets/task_goal_row.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    super.key,
    required this.title,
    required this.tasks,
    this.onToggleTask,
    this.onTaskTap,
    this.onCreateTask,
  });

  final String title;
  final List<TaskViewItem> tasks;
  final void Function(TaskViewItem task, bool completed)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;
  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    floatingActionButton: onCreateTask == null
        ? null
        : FloatingActionButton.extended(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Tạo nhiệm vụ'),
          ),
    body: tasks.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.task_alt_rounded,
                    size: 48,
                    color: ADayColors.mutedInk,
                  ),
                  const SizedBox(height: 12),
                  Text('Chưa có nhiệm vụ', style: ADayTypography.title),
                  const SizedBox(height: 6),
                  const Text(
                    'Tạo một nhiệm vụ nhỏ để bắt đầu ngày mới.',
                    textAlign: TextAlign.center,
                  ),
                  if (onCreateTask != null) ...[
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onCreateTask,
                      child: const Text('Tạo nhiệm vụ'),
                    ),
                  ],
                ],
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: ADaySpacing.sm),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: ADaySpacing.md,
              endIndent: ADaySpacing.md,
            ),
            itemBuilder: (_, index) {
              final task = tasks[index];
              return TaskGoalRow(
                item: task,
                showDivider: false,
                onToggleCompleted: onToggleTask == null
                    ? null
                    : (value) => onToggleTask!(task, value),
                onTap: onTaskTap == null ? null : () => onTaskTap!(task),
              );
            },
          ),
  );
}

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key, required this.onSubmit});
  final Future<void> Function(String title, String note, String category)
  onSubmit;

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _category = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tạo nhiệm vụ')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ADaySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tên nhiệm vụ',
                hintText: 'Ví dụ: Đọc sách 20 phút',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Danh mục (không bắt buộc)',
                hintText: 'Ví dụ: Sức khỏe',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      if (_title.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hãy nhập tên nhiệm vụ.'),
                          ),
                        );
                        return;
                      }
                      setState(() => _saving = true);
                      try {
                        await widget.onSubmit(
                          _title.text,
                          _note.text,
                          _category.text,
                        );
                        if (!mounted) return;
                        navigator.pop();
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: Text(_saving ? 'Đang lưu...' : 'Tạo nhiệm vụ'),
            ),
          ],
        ),
      ),
    ),
  );
}
