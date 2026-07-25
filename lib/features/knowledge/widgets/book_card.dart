import 'dart:io';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/book_enums.dart';
import '../models/book_view.dart';

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
                color: TenkaiColors.gray800,
                child: Center(
                  child: CNIcon(
                    symbol: CNSymbol(
                      'book.closed',
                      size: width * 0.5,
                      color: TenkaiColors.gray600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.view, required this.onTap});

  final BookView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = view.book;
    final badge = paceBadge(view.paceState);

    return TenkaiCard(
      interactive: true,
      glowOnHover: true,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(path: book.coverImagePath),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: TenkaiTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[const SizedBox(width: 8), badge],
                  ],
                ),
                if (book.author != null && book.author!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.author!,
                    style: TenkaiTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                TenkaiProgress(value: view.percent, showPercent: true),
                const SizedBox(height: 6),
                Text(
                  'p${book.currentPage} / ${book.totalPages}',
                  style: TenkaiTypography.labelSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
