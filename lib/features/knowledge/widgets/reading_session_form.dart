import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

class ReadingSessionForm extends ConsumerStatefulWidget {
  final BookModel book;

  const ReadingSessionForm({super.key, required this.book});

  @override
  ConsumerState<ReadingSessionForm> createState() => _ReadingSessionFormState();
}

class _ReadingSessionFormState extends ConsumerState<ReadingSessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _pageCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  @override
  void initState() {
    _pageCtrl.text = widget.book.currentPage.toString();
    super.initState();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valid =
        int.parse(_pageCtrl.text) > widget.book.currentPage &&
        int.parse(_pageCtrl.text) <= widget.book.totalPages;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.book.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          TenkaiTextFormField(
            label: 'Current page (of ${widget.book.totalPages})',
            placeholder: '${widget.book.currentPage}',
            controller: _pageCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TenkaiTextFormField(
            label: 'What did you learn? (optional)',
            placeholder: 'A brief takeaway from this session…',
            controller: _summaryCtrl,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              child: Text('Save progress'),
              onPressed: () async {
                final summary = _summaryCtrl.text.trim();
                await ref
                    .read(bookProvider.notifier)
                    .addReadingSession(
                      ReadingSessionsCompanion(
                        bookId: Value(widget.book.id),
                        startPage: Value(widget.book.currentPage),
                        endPage: Value(int.parse(_pageCtrl.text)),
                        summary: Value(summary.isEmpty ? null : summary),
                      ),
                    );
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pop(int.parse(_pageCtrl.text) >= widget.book.totalPages);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
