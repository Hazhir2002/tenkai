import 'package:flutter/material.dart';
import 'package:tenkai/core/widgets/error_card.dart';

class ErrorTile extends StatelessWidget {
  final String message;
  final Widget? action;

  const ErrorTile({super.key, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ErrorCard(
      child: ListTile(
        leading: Icon(
          Icons.error_outline_rounded,
          color: theme.colorScheme.error,
          size: 18,
        ),
        title: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        trailing: action,
      ),
    );
  }
}
