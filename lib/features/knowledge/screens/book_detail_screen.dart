import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/services/notification_service.dart';

import '../models/book_enums.dart';
import '../models/book_view.dart';
import '../providers/books_provider.dart';
import '../widgets/add_highlight_sheet.dart';
import '../widgets/book_card.dart';
import '../widgets/book_form_sheet.dart';
import '../widgets/book_pace_chart.dart';
import '../widgets/finish_book_sheet.dart';
import '../widgets/update_progress_sheet.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});
  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(bookViewProvider(bookId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: TenkaiAppBar(
        title: viewAsync.valueOrNull?.book.title ?? 'Book',
        actions: [
          if (viewAsync.valueOrNull != null) ...[
            TenkaiAppBarAction(
              symbol: 'pencil',
              onPressed: () => showBookFormSheet(
                context,
                ref,
                editing: viewAsync.value!.book,
              ),
            ),
            TenkaiAppBarAction(
              symbol: 'trash',
              onPressed: () => _confirmDelete(context, ref, bookId),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: viewAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, _) =>
              Center(child: Text('Couldn\'t load book: $err')),
          data: (view) {
            if (view == null) {
              return const Center(child: Text('Book not found'));
            }
            return _BookDetailBody(view: view);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete book?'),
        content: const Text(
          'This removes the book, its reading log, and highlights. This can\'t be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(appDataBaseProvider).bookDao.deleteBook(id);
    await ref.read(notificationServiceProvider).cancelBook(id);
    if (context.mounted) context.pop();
  }
}

class _BookDetailBody extends ConsumerWidget {
  const _BookDetailBody({required this.view});
  final BookView view;

  TenkaiBadgeVariant get _statusVariant => switch (view.status) {
    BookStatus.reading => TenkaiBadgeVariant.active,
    BookStatus.finished => TenkaiBadgeVariant.success,
    BookStatus.paused => TenkaiBadgeVariant.warning,
    BookStatus.wantToRead => TenkaiBadgeVariant.neutral,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = view.book;
    final sessionsAsync = ref.watch(sessionsForBookProvider(book.id));
    final highlightsAsync = ref.watch(highlightsForBookProvider(book.id));
    final badge = paceBadge(view.paceState);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        TenkaiSpacing.lg,
        TenkaiAppBar.compactHeight + TenkaiSpacing.md,
        TenkaiSpacing.lg,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                BookCover(path: book.coverImagePath, width: 140, height: 196),
                const SizedBox(height: 16),
                Text(
                  book.title,
                  style: TenkaiTypography.h2,
                  textAlign: TextAlign.center,
                ),
                if (book.author != null && book.author!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(book.author!, style: TenkaiTypography.bodySmall),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TenkaiBadge(label: view.status.label, variant: _statusVariant),
                    if (badge != null) ...[const SizedBox(width: 8), badge],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: TenkaiSpacing.xl),
          TenkaiProgress(
            value: view.percent,
            label: '${book.currentPage} / ${book.totalPages} pages',
          ),
          if (view.hasTarget) ...[
            const SizedBox(height: TenkaiSpacing.xl),
            BookPaceChart(view: view),
          ],
          const SizedBox(height: TenkaiSpacing.xl),
          Row(
            children: [
              Expanded(
                child: TenkaiMetricCard(
                  label: 'Streak',
                  value: '${view.streakDays}',
                  subtext: view.streakDays == 1 ? 'day' : 'days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TenkaiMetricCard(
                  label: 'This week',
                  value: '${view.pagesThisWeek}',
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
                  value: view.avgPagesPerDay.toStringAsFixed(1),
                  subtext: 'pages',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TenkaiMetricCard(
                  label: 'Projected finish',
                  value: view.projectedFinish != null
                      ? DateFormat('MMM d').format(view.projectedFinish!)
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: TenkaiSpacing.xl),
          if (view.status != BookStatus.finished) ...[
            SizedBox(
              width: double.infinity,
              child: TenkaiGlassButton(
                label: 'Update progress',
                style: TenkaiGlassButtonStyle.prominentGlass,
                onPressed: () => _updateProgress(context, ref, book),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TenkaiButton(
                    label: 'Add highlight',
                    variant: TenkaiButtonVariant.ghost,
                    onPressed: () => showAddHighlightSheet(context, ref, book),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TenkaiButton(
                    label: 'Mark finished',
                    variant: TenkaiButtonVariant.ghost,
                    onPressed: () => showFinishBookSheet(context, ref, book),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: TenkaiButton(
                label: 'Add highlight',
                variant: TenkaiButtonVariant.ghost,
                onPressed: () => showAddHighlightSheet(context, ref, book),
              ),
            ),
          const SizedBox(height: TenkaiSpacing.xxl),
          TenkaiDivider(label: 'Reading log'),
          const SizedBox(height: 16),
          sessionsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (sessions) {
              if (sessions.isEmpty) {
                return Text(
                  'No sessions logged yet.',
                  style: TenkaiTypography.bodySmall,
                );
              }
              return Column(
                children: [
                  for (final s in sessions) ...[
                    _SessionRow(session: s),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: TenkaiSpacing.xxl),
          TenkaiDivider(label: 'Highlights'),
          const SizedBox(height: 16),
          highlightsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (highlights) {
              if (highlights.isEmpty) {
                return Text(
                  'No highlights saved yet.',
                  style: TenkaiTypography.bodySmall,
                );
              }
              return Column(
                children: [
                  for (final h in highlights) ...[
                    _HighlightRow(highlight: h),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateProgress(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final finished = await showUpdateProgressSheet(context, ref, book);
    if (finished == true && context.mounted) {
      final updated = await ref.read(appDataBaseProvider).bookDao.getBook(book.id);
      if (updated != null && context.mounted) {
        await showFinishBookSheet(context, ref, updated);
      }
    }
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
        child: const CNIcon(symbol: CNSymbol('trash', color: TenkaiColors.error)),
      ),
      onDismissed: (_) =>
          ref.read(appDataBaseProvider).bookDao.deleteSession(session.id),
      child: TenkaiCard(
        padding: const EdgeInsets.all(14),
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
                Text(session.dateKey, style: TenkaiTypography.bodySmall),
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

class _HighlightRow extends ConsumerWidget {
  const _HighlightRow({required this.highlight});
  final BookHighlight highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('highlight-${highlight.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: TenkaiColors.errorDim,
        child: const CNIcon(symbol: CNSymbol('trash', color: TenkaiColors.error)),
      ),
      onDismissed: (_) =>
          ref.read(appDataBaseProvider).bookDao.deleteHighlight(highlight.id),
      child: TenkaiCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '"${highlight.quote}"',
                    style: TenkaiTypography.bodyMd,
                  ),
                ),
                const SizedBox(width: 8),
                Text('p${highlight.page}', style: TenkaiTypography.labelSm),
              ],
            ),
            if (highlight.note != null && highlight.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(highlight.note!, style: TenkaiTypography.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
