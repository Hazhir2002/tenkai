import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/widgets/empty_state_widget.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

import '../models/book_enums.dart';
import '../widgets/book_card.dart';

class BookLibraryScreen extends ConsumerStatefulWidget {
  const BookLibraryScreen({super.key});

  @override
  ConsumerState<BookLibraryScreen> createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends ConsumerState<BookLibraryScreen> {
  BookStatus? _filter = null;

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Books'),
        actions: [
          IconButton(
            icon: Icon(IconsaxOutline.add),
            onPressed: () => context.push('/knowledge/book-library/new'),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: Builder(
          builder: (context) {
            if (bookState.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (bookState.error != null) {
              return Center(
                child: Text(
                  'Couldn\'t load books: ${bookState.error}',
                  style: TenkaiTypography.bodySmall,
                ),
              );
            } else {
              final books = bookState.books;
              final filtered = _filter == null
                  ? books
                  : books.where((v) => v.status == _filter?.dbValue).toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text('All'),
                            selected: _filter == null,
                            onSelected: (value) {
                              setState(() {
                                _filter = null;
                              });
                            },
                          ),
                          for (final s in BookStatus.values) ...[
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(s.label),
                              selected: _filter == s,
                              onSelected: (value) {
                                setState(() {
                                  _filter = s;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: TenkaiSpacing.xl),
                    if (books.isEmpty)
                      EmptyStateWidget(
                        icon: const TenkaiNode(size: 28),
                        title: 'No books yet',
                        subtitle:
                            'Add a book to track your reading progress\nand pace toward a deadline or goal.',
                        actionWidget: TenkaiButton(
                          label: 'Add your first book',
                          onPressed: () =>
                              context.push('/knowledge/book-library/new'),
                        ),
                      )
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
                          book: v,
                          onTap: () =>
                              context.push('/knowledge/book-library/${v.id}'),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
