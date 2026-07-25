import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/providers.dart';

/// Saves a highlighted quote (with page number and optional note) for a book.
Future<void> showAddHighlightSheet(
  BuildContext context,
  WidgetRef ref,
  Book book,
) {
  return showTenkaiSheet<void>(
    context: context,
    title: 'Add a highlight',
    child: _AddHighlightSheet(book: book),
  );
}

class _AddHighlightSheet extends HookConsumerWidget {
  const _AddHighlightSheet({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageCtrl = useTextEditingController(
      text: book.currentPage.toString(),
    );
    final quoteCtrl = useTextEditingController();
    final noteCtrl = useTextEditingController();
    final quote = useState('');
    final saving = useState(false);

    useEffect(() {
      void listener() => quote.value = quoteCtrl.text;
      quoteCtrl.addListener(listener);
      return () => quoteCtrl.removeListener(listener);
    }, [quoteCtrl]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(book.title, style: TenkaiTypography.h3),
        const SizedBox(height: 16),
        TenkaiInput(
          label: 'Page',
          placeholder: '${book.currentPage}',
          controller: pageCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TenkaiInput(
          label: 'Quote',
          placeholder: 'What stood out to you?',
          controller: quoteCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TenkaiInput(
          label: 'Note (optional)',
          placeholder: 'Why it mattered…',
          controller: noteCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TenkaiButton(
            label: 'Save highlight',
            loading: saving.value,
            enabled: quote.value.trim().isNotEmpty && !saving.value,
            onPressed: () async {
              saving.value = true;
              final db = ref.read(appDataBaseProvider);
              final note = noteCtrl.text.trim();
              await db.bookDao.addHighlight(
                bookId: book.id,
                page: int.tryParse(pageCtrl.text) ?? book.currentPage,
                quote: quoteCtrl.text.trim(),
                note: note.isEmpty ? null : note,
              );
              TenkaiSound.confirm();
              if (context.mounted) {
                Navigator.of(context).pop();
                showTenkaiToast(
                  context,
                  const TenkaiToastData(
                    title: 'Highlight saved',
                    variant: TenkaiToastVariant.success,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
