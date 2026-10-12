import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/providers.dart';

import '../providers/books_provider.dart';

/// Records a reading session (page update + optional "what I learned"
/// summary). Returns `true` when the update reached the last page, so the
/// caller can chain into the finish flow.
Future<bool?> showUpdateProgressSheet(
  BuildContext context,
  WidgetRef ref,
  Book book,
) {
  return showTenkaiSheet<bool>(
    context: context,
    title: 'Update progress',
    child: _UpdateProgressSheet(book: book),
  );
}

class _UpdateProgressSheet extends HookConsumerWidget {
  const _UpdateProgressSheet({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageCtrl = useTextEditingController(
      text: book.currentPage.toString(),
    );
    final summaryCtrl = useTextEditingController();
    final page = useState(book.currentPage);
    final saving = useState(false);

    useEffect(() {
      void listener() => page.value = int.tryParse(pageCtrl.text) ?? -1;
      pageCtrl.addListener(listener);
      return () => pageCtrl.removeListener(listener);
    }, [pageCtrl]);

    final valid =
        page.value > book.currentPage && page.value <= book.totalPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(book.title, style: TenkaiTypography.h3),
        const SizedBox(height: 16),
        TenkaiTextFormField(
          label: 'Current page (of ${book.totalPages})',
          placeholder: '${book.currentPage}',
          controller: pageCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TenkaiTextFormField(
          label: 'What did you learn? (optional)',
          placeholder: 'A brief takeaway from this session…',
          controller: summaryCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TenkaiButton(
            label: 'Save progress',
            loading: saving.value,
            enabled: valid && !saving.value,
            onPressed: () async {
              saving.value = true;
              final db = ref.read(appDataBaseProvider);
              final summary = summaryCtrl.text.trim();
              // await db.bookDao.createReadingSession(
              //   bookId: book.id,
              //   startPage: book.currentPage,
              //   endPage: page.value,
              //   summary: summary.isEmpty ? null : summary,
              //   dateKey: bookDateKey(),
              // );
              if (context.mounted) {
                Navigator.of(context).pop(page.value >= book.totalPages);
              }
            },
          ),
        ),
      ],
    );
  }
}
