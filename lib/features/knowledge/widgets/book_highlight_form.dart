import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

class BookHighlightForm extends ConsumerStatefulWidget {
  const BookHighlightForm({super.key, required this.book});
  final BookModel book;

  @override
  ConsumerState<BookHighlightForm> createState() => _BookHighlightFormState();
}

class _BookHighlightFormState extends ConsumerState<BookHighlightForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _pageCtrl = TextEditingController();
  final _quoteCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    _pageCtrl.text = widget.book.currentPage.toString();
    super.initState();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _quoteCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.book.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          TenkaiTextFormField(
            label: 'Page',
            placeholder: '${widget.book.currentPage}',
            controller: _pageCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TenkaiTextFormField(
            label: 'Quote',
            placeholder: 'What stood out to you?',
            controller: _quoteCtrl,
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TenkaiTextFormField(
            label: 'Note (optional)',
            placeholder: 'Why it mattered…',
            controller: _noteCtrl,
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              child: Text('Save highlight'),
              onPressed: () async {
                final note = _noteCtrl.text.trim();
                ref
                    .read(bookProvider.notifier)
                    .addBookHighlight(
                      BookHighlightsCompanion(
                        bookId: Value(widget.book.id),
                        page: Value(
                          int.tryParse(_pageCtrl.text) ??
                              widget.book.currentPage,
                        ),
                        quote: Value(_quoteCtrl.text.trim()),
                        note: Value(note.isEmpty ? null : note),
                      ),
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Highlight saved')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
