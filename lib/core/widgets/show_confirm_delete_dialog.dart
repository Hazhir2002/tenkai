import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showConfirmDeleteDialog(
  BuildContext context,
  String title,
  String content,
  Future<void> Function() onDelete,
) async {
  final theme = Theme.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: theme.filledButtonTheme.style!.copyWith(
            backgroundColor: WidgetStatePropertyAll(theme.colorScheme.error),
          ),
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await onDelete();
  if (context.mounted) context.pop();
}
