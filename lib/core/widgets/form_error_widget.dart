import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_duration.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';

class FormErrorWidget extends StatelessWidget {
  final String? message;

  const FormErrorWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: TenkaiDuration.fast,
      child: message != null
          ? SizedBox(
              key: Key('error'),
              width: double.infinity,
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(TenkaiSpacing.md),
                  child: Text(
                    message!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(key: Key('no-error')),
    );
  }
}
