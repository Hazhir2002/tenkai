import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/book_enums.dart';
import '../providers/books_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/book_form_sheet.dart';

class BooksScreen extends HookConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(bookViewsProvider);
    final filter = useState<BookStatus?>(null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Books'),
        actions: [
          // TenkaiAppBarAction(
          //   symbol: 'plus',
          //   onPressed: () => showBookFormSheet(context, ref),
          // ),
        ],
      ),
      body: SafeArea(
        child: viewsAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Couldn\'t load books: $err',
              style: TenkaiTypography.bodySmall,
            ),
          ),
          data: (views) {
            final filtered = filter.value == null
                ? views
                : views.where((v) => v.status == filter.value).toList();

            return SingleChildScrollView(
              // padding: const EdgeInsets.fromLTRB(
              //   TenkaiSpacing.lg,
              //   TenkaiAppBar.compactHeight + TenkaiSpacing.md,
              //   TenkaiSpacing.lg,
              //   120,
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text('All'),
                          selected: filter.value == null,
                          onSelected: (value) => filter.value = null,
                        ),
                        for (final s in BookStatus.values) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(s.label),
                            selected: filter.value == s,
                            onSelected: (value) => filter.value = s,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: TenkaiSpacing.xl),
                  if (views.isEmpty)
                    _EmptyState(onAdd: () => showBookFormSheet(context, ref))
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No books on this shelf',
                          style: TenkaiTypography.bodySmall,
                        ),
                      ),
                    )
                  else
                    for (final v in filtered) ...[
                      BookCard(
                        view: v,
                        onTap: () =>
                            context.push('/knowledge/books/${v.book.id}'),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TenkaiNode(size: 28),
            const SizedBox(height: TenkaiSpacing.xl),
            Text('No books yet', style: TenkaiTypography.h2),
            const SizedBox(height: TenkaiSpacing.sm),
            Text(
              'Add a book to track your reading progress\nand pace toward a deadline or goal.',
              textAlign: TextAlign.center,
              style: TenkaiTypography.bodySmall,
            ),
            const SizedBox(height: TenkaiSpacing.xl),
            TenkaiButton(label: 'Add your first book', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}
