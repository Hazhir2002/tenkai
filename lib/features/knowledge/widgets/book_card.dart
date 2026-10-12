import 'dart:io';

import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';

import '../models/book_enums.dart';

/// Maps a pace state to a badge. Returns null when there's nothing to show.
TenkaiBadge? paceBadge(PaceState state) => switch (state) {
  PaceState.ahead => const TenkaiBadge(
    label: 'Ahead',
    variant: TenkaiBadgeVariant.success,
  ),
  PaceState.onTrack => const TenkaiBadge(
    label: 'On track',
    variant: TenkaiBadgeVariant.success,
  ),
  PaceState.behind => const TenkaiBadge(
    label: 'Behind',
    variant: TenkaiBadgeVariant.warning,
  ),
  PaceState.finished => const TenkaiBadge(
    label: 'Finished',
    variant: TenkaiBadgeVariant.success,
  ),
  PaceState.noTarget => null,
};

/// A cover thumbnail, falling back to a placeholder when there's no photo.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.path,
    this.width = 48,
    this.height = 68,
  });

  final String? path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
      child: SizedBox(
        width: width,
        height: height,
        child: (path != null && File(path!).existsSync())
            ? Image.file(File(path!), fit: BoxFit.cover)
            : Container(
                color: context.tenkai.card,
                child: Center(child: Icon(IconsaxOutline.book)),
              ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});

  final BookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = paceBadge(book.paceState);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: BookCover(path: book.coverImagePath),
        title: Text(book.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: TenkaiSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: book.percent),
              Text(
                '${book.currentPage} / ${book.totalPages} (p)',
                style: theme.textTheme.labelSmall,
              ),
              ?badge,
            ],
          ),
        ),
        trailing: badge,
      ),
    );
  }
}
