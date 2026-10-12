import 'package:drift/drift.dart' hide Column;
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/services/image_storage_service.dart';
import 'package:tenkai/features/knowledge/models/book_enums.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

import 'book_card.dart';

class BookForm extends ConsumerStatefulWidget {
  final BookModel? editing;
  final void Function()? onUpdate;

  const BookForm({super.key, this.editing, this.onUpdate});

  @override
  ConsumerState<BookForm> createState() => _BookFormState();
}

class _BookFormState extends ConsumerState<BookForm> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  DateTime? _deadline;
  BookStatus _bookStatus = BookStatus.wantToRead;
  bool _reminderEnabled = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;
  String? _coverImage;

  @override
  void initState() {
    if (widget.editing != null) {
      final book = widget.editing!;
      _titleCtrl.text = book.title;
      _authorCtrl.text = book.author ?? '';
      _totalCtrl.text = book.totalPages.toString();
      _currentCtrl.text = book.currentPage.toString();
      _goalCtrl.text = book.dailyPageGoal != null
          ? book.dailyPageGoal.toString()
          : '';
      _deadline = book.deadline;
      _bookStatus = book.bookStatus;
      _reminderEnabled = book.reminderEnabled;
      _reminderHour = book.reminderHour ?? 20;
      _reminderMinute = book.reminderMinute ?? 0;
      _coverImage = book.coverImagePath;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _totalCtrl.dispose();
    _currentCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      child: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickCover(context, (cover) {
                        setState(() {
                          _coverImage = cover;
                        });
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          BookCover(path: _coverImage, width: 84, height: 118),
                          const SizedBox(height: 8),
                          Text(
                            _coverImage == null ? 'Add cover' : 'Change cover',
                            style: TenkaiTypography.labelSm,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TenkaiTextFormField(
                    label: 'title',
                    isRequired: true,
                    placeholder: 'Book title',
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TenkaiTextFormField(
                    label: 'Author',
                    placeholder: 'Author',
                    controller: _authorCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TenkaiTextFormField(
                          label: 'Total pages',
                          placeholder: '320',
                          controller: _totalCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TenkaiTextFormField(
                          label: 'Current page',
                          placeholder: '0',
                          controller: _currentCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Shelf', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  RadioGroup<BookStatus>(
                    groupValue: _bookStatus,
                    onChanged: (BookStatus? value) {
                      setState(() {
                        _bookStatus = value!;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<BookStatus>(
                          title: Text('Want to read'),
                          value: BookStatus.wantToRead,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<BookStatus>(
                          title: Text('Reading'),
                          value: BookStatus.reading,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<BookStatus>(
                          title: Text('Finished'),
                          value: BookStatus.finished,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<BookStatus>(
                          title: Text('Paused'),
                          value: BookStatus.paused,
                          contentPadding: EdgeInsets.all(0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Deadline (optional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deadline (optional)',
                        style: TenkaiTypography.bodyMd,
                      ),
                      Row(
                        children: [
                          if (_deadline != null) ...[
                            Text(
                              DateFormat('MMM d, y').format(_deadline!),
                              style: TenkaiTypography.labelMd.copyWith(
                                color: context.tenkai.foreground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() {
                                _deadline = null;
                              }),
                              child: Icon(Icons.close_outlined),
                            ),
                          ] else
                            OutlinedButton(
                              child: Text('Set'),
                              onPressed: () async {
                                final picked = await _pickDate(
                                  context,
                                  _deadline,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _deadline = picked;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TenkaiTextFormField(
                    label: 'Or a daily page goal (optional)',
                    placeholder: 'e.g. 10',
                    controller: _goalCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Reminder
                  Row(
                    children: [
                      Switch(
                        value: _reminderEnabled,
                        onChanged: (value) {
                          setState(() {
                            _reminderEnabled = value;
                          });
                        },
                      ),
                      Text('Daily reading reminder'),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remind me at', style: TenkaiTypography.bodyMd),
                        GestureDetector(
                          onTap: () async {
                            final picked = await _pickTime(
                              context,
                              _reminderHour,
                              _reminderMinute,
                            );
                            if (picked != null) {
                              setState(() {
                                _reminderHour = picked.$1;
                                _reminderMinute = picked.$2;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.tenkai.card,
                              borderRadius: BorderRadius.circular(
                                TenkaiRadius.control,
                              ),
                              border: Border.all(
                                color: context.tenkai.border,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _hm(_reminderHour, _reminderMinute),
                              style: TenkaiTypography.mono.copyWith(
                                color: context.tenkai.foreground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              child: Text(widget.editing != null ? 'Save changes' : 'Add book'),
              onPressed: () async {
                if (widget.editing != null) {
                  final book = widget.editing!;
                  await ref
                      .read(bookProvider.notifier)
                      .updateBook(
                        BooksCompanion(
                          id: Value(book.id),
                          title: Value(_titleCtrl.text),
                          author: Value(_authorCtrl.text),
                          totalPages: Value(int.parse(_totalCtrl.text)),
                          currentPage: Value(int.parse(_currentCtrl.text)),
                          status: Value(_bookStatus.dbValue),
                          deadline: Value(_deadline),
                          dailyPageGoal: Value(int.tryParse(_goalCtrl.text)),
                          updatedAt: Value(DateTime.now()),
                          coverImagePath: Value(_coverImage),
                        ),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Book updated')));
                  }
                  if (widget.onUpdate != null) {
                    widget.onUpdate!();
                  }
                } else {
                  await ref
                      .read(bookProvider.notifier)
                      .createBook(
                        BooksCompanion(
                          title: Value(_titleCtrl.text),
                          author: Value(_authorCtrl.text),
                          totalPages: Value(int.parse(_totalCtrl.text)),
                          currentPage: Value(int.parse(_currentCtrl.text)),
                          status: Value(_bookStatus.dbValue),
                          deadline: Value(_deadline),
                          dailyPageGoal: Value(int.tryParse(_goalCtrl.text)),
                          coverImagePath: Value(_coverImage),
                        ),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Book added')));
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCover(
    BuildContext context,
    void Function(String?) onCoverChanged,
  ) async {
    final service = ref.read(imageStorageServiceProvider);
    // final notifier = ref.read(bookFormProvider.notifier);
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: context.tenkai.card,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(IconsaxBold.camera),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(IconsaxBold.gallery),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            if (_coverImage != null)
              ListTile(
                leading: Icon(
                  IconsaxOutline.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Remove cover'),
                onTap: () {
                  onCoverChanged(null);
                  Navigator.pop(sheetCtx, null);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final path = await service.pickAndStore(source: source);
    if (path != null) {
      onCoverChanged(path);
    }
  }
}

String _hm(int h, int m) =>
    '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
  var picked = initial ?? DateTime.now();
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.tenkai.card,
    builder: (sheetCtx) => CupertinoTheme(
      data: CupertinoThemeData(brightness: Theme.of(context).brightness),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: picked,
                minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: TenkaiButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(sheetCtx).pop(true),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return ok == true ? picked : null;
}

Future<(int, int)?> _pickTime(
  BuildContext context,
  int hour,
  int minute,
) async {
  var h = hour, m = minute;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.tenkai.card,
    builder: (sheetCtx) => CupertinoTheme(
      data: CupertinoThemeData(brightness: Theme.of(context).brightness),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2024, 1, 1, hour, minute),
                onDateTimeChanged: (d) {
                  h = d.hour;
                  m = d.minute;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: TenkaiButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(sheetCtx).pop(true),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return ok == true ? (h, m) : null;
}
