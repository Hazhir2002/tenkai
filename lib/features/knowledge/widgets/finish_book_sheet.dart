import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/notifications/tenkai_notifications.dart';
import 'package:tenkai/core/providers.dart';

import 'star_rating.dart';

/// Collects a rating + final takeaway when a book is finished.
Future<void> showFinishBookSheet(
  BuildContext context,
  WidgetRef ref,
  Book book,
) {
  return showModalBottomSheet<void>(
    context: context,
    // title: 'Finished — nice work',
    builder: (context) => _FinishBookSheet(book: book),
  );
}

class _FinishBookSheet extends HookConsumerWidget {
  const _FinishBookSheet({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = useState<int>(book.rating ?? 0);
    final reviewCtrl = useTextEditingController(text: book.review ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(book.title, style: TenkaiTypography.h3),
        const SizedBox(height: 16),
        Text('YOUR RATING', style: TenkaiTypography.labelMd),
        const SizedBox(height: 8),
        Center(
          child: StarRating(
            rating: rating.value,
            size: 36,
            onChanged: (r) => rating.value = r,
          ),
        ),
        const SizedBox(height: 20),
        TenkaiTextFormField(
          label: 'Biggest takeaway (optional)',
          placeholder: 'What will you remember from this book?',
          controller: reviewCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            child: Text('Mark finished'),
            onPressed: () async {
              final db = ref.read(appDataBaseProvider);
              await db.bookDao.updateBook(
                BooksCompanion(
                  id: Value(book.id),
                  rating: Value(rating.value == 0 ? null : rating.value),
                  review: Value(
                    reviewCtrl.text.trim().isEmpty
                        ? null
                        : reviewCtrl.text.trim(),
                  ),
                ),
              );
              await TenkaiNotifications.deleteReadingSessionReminder(
                id: book.id,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
