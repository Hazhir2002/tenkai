import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/tokens/tenkai_radius.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

class HighlightListTile extends ConsumerWidget {
  final BookHighlight highlight;

  const HighlightListTile({super.key, required this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('highlight-${highlight.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TenkaiRadius.md),
          color: theme.colorScheme.errorContainer,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: TenkaiSpacing.md),
        child: Icon(IconsaxOutline.trash, color: theme.colorScheme.error),
      ),
      onDismissed: (_) async => await ref
          .read(bookProvider.notifier)
          .deleteBookHighlight(highlight.bookId, highlight.id),
      child: Card(
        child: ListTile(
          title: Text('"${highlight.quote}"'),
          subtitle: highlight.note != null ? Text(highlight.note!) : null,
          trailing: Text(
            'p${highlight.page}',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
