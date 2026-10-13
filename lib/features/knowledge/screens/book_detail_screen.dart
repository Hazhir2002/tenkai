import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/tokens/tenkai_colors.dart';
import 'package:tenkai/core/tokens/tenkai_duration.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/core/widgets/show_confirm_delete_dialog.dart';
import 'package:tenkai/core/widgets/tenkai_metric_card.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';
import 'package:tenkai/features/knowledge/widgets/highlight_list_tile.dart';

import '../models/book_enums.dart';
import '../widgets/book_highlight_form.dart';
import '../widgets/book_card.dart';
import '../widgets/book_form.dart';
import '../widgets/book_pace_chart.dart';
import '../widgets/finish_book_sheet.dart';
import '../widgets/reading_session_form.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});
  final int bookId;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isEditing = false;

  @override
  void initState() {
    final bookNotifier = ref.read(bookProvider.notifier);
    Future.microtask(() => bookNotifier.listReadingSessions(widget.bookId));
    Future.microtask(() => bookNotifier.listBookHighlights(widget.bookId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final book = ref
        .watch(bookProvider)
        .books
        .where((book) => book.id == widget.bookId)
        .first;

    final readingSessions = book.readingSessions;
    final bookHighlights = book.bookHighlights;
    final computedBook = BookModel.compute(
      book,
      readingSessions,
      bookHighlights,
      DateTime.now(),
    );

    final badge = paceBadge(computedBook.paceState);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(computedBook.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_outlined : IconsaxOutline.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          _isEditing
              ? SizedBox()
              : IconButton(
                  icon: Icon(IconsaxOutline.trash),
                  onPressed: () => showConfirmDeleteDialog(
                    context,
                    'Delete book?',
                    'This removes the book, its reading log, and highlights. This can\'t be undone.',
                    () async {
                      await ref
                          .read(appDataBaseProvider)
                          .bookDao
                          .deleteBook(book.id);
                    },
                  ),
                ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: AnimatedSwitcher(
          duration: TenkaiDuration.medium,
          child: _isEditing
              ? BookForm(
                  editing: computedBook,
                  onUpdate: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            BookCover(
                              path: computedBook.coverImagePath,
                              width: 140,
                              height: 196,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              computedBook.title,
                              style: theme.textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (computedBook.author != null &&
                                computedBook.author!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                computedBook.author!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(computedBook.bookStatus.label),
                                ),
                                if (badge != null) ...[
                                  const SizedBox(width: 8),
                                  badge,
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TenkaiSpacing.xl),
                      Column(
                        spacing: TenkaiSpacing.sm,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${computedBook.currentPage} / ${computedBook.totalPages} pages',
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(
                                '${(computedBook.percent * 100).floor()}%',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                          LinearProgressIndicator(value: computedBook.percent),
                        ],
                      ),
                      if (computedBook.hasTarget) ...[
                        const SizedBox(height: TenkaiSpacing.xl),
                        BookPaceChart(view: computedBook),
                      ],
                      const SizedBox(height: TenkaiSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: TenkaiMetricCard(
                              label: 'Streak',
                              value: '${computedBook.streakDays}',
                              subtext: computedBook.streakDays == 1
                                  ? 'day'
                                  : 'days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TenkaiMetricCard(
                              label: 'This week',
                              value: '${computedBook.pagesThisWeek}',
                              subtext: 'pages',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TenkaiMetricCard(
                              label: 'Avg / day',
                              value: computedBook.avgPagesPerDay
                                  .toStringAsFixed(1),
                              subtext: 'pages',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TenkaiMetricCard(
                              label: 'Projected finish',
                              value: computedBook.projectedFinish != null
                                  ? DateFormat(
                                      'MMM d',
                                    ).format(computedBook.projectedFinish!)
                                  : '—',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TenkaiSpacing.xl),
                      if (computedBook.bookStatus != BookStatus.finished) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            child: Text('Update progress'),
                            onPressed: () =>
                                _updateProgress(context, computedBook),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                child: Text('Add highlight'),
                                onPressed: () => showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (context) => SafeArea(
                                    minimum: const EdgeInsets.all(
                                      TenkaiSpacing.md,
                                    ),
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                      ),
                                      child: BookHighlightForm(book: book),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                child: Text('Mark finished'),
                                onPressed: () => showFinishBookSheet(
                                  context,
                                  ref,
                                  computedBook,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            child: Text('Add highlight'),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) => SafeArea(
                                minimum: const EdgeInsets.all(TenkaiSpacing.md),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: BookHighlightForm(book: book),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: TenkaiSpacing.xxl),
                      Row(
                        spacing: TenkaiSpacing.sm,
                        children: [
                          Text(
                            'Reading Logs',
                            style: theme.textTheme.labelLarge,
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      readingSessions.isEmpty
                          ? Text(
                              'No sessions logged yet.',
                              style: TenkaiTypography.bodySmall,
                            )
                          : Column(
                              children: [
                                for (final s in readingSessions) ...[
                                  _SessionRow(session: s),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                      const SizedBox(height: TenkaiSpacing.xxl),
                      Row(
                        spacing: TenkaiSpacing.sm,
                        children: [
                          Text('Highlights', style: theme.textTheme.labelLarge),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      bookHighlights.isEmpty
                          ? Text(
                              'No highlights saved yet.',
                              style: theme.textTheme.bodySmall,
                            )
                          : Column(
                              children: [
                                for (final h in bookHighlights) ...[
                                  HighlightListTile(highlight: h),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _updateProgress(BuildContext context, BookModel book) async {
    final finished = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.md),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ReadingSessionForm(book: book),
        ),
      ),
    );
    // if (finished == true && context.mounted) {
    //   final updated = await ref
    //       .read(appDataBaseProvider)
    //       .bookDao
    //       .getBook(book.id);
    //   if (updated != null && context.mounted) {
    //     await showFinishBookSheet(context, ref, updated);
    //   }
    // }
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session});
  final ReadingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('session-${session.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: TenkaiColors.errorDim,
        child: const Icon(IconsaxOutline.trash, color: TenkaiColors.error),
      ),
      onDismissed: (_) => ref
          .read(appDataBaseProvider)
          .bookDao
          .deleteReadingSession(session.id),
      child: Card(
        // padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'p${session.startPage} → p${session.endPage}',
                  style: TenkaiTypography.labelMd,
                ),
                // Text(session.dateKey, style: TenkaiTypography.bodySmall),
              ],
            ),
            if (session.summary != null && session.summary!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(session.summary!, style: TenkaiTypography.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
