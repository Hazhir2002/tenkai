import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/services/image_storage_service.dart';

import '../models/book_enums.dart';
import '../providers/book_form_provider.dart';
import 'book_card.dart';

/// Opens the create/edit book form (seeds the shared form provider first).
Future<void> showBookFormSheet(
  BuildContext context,
  WidgetRef ref, {
  Book? editing,
}) {
  final notifier = ref.read(bookFormProvider.notifier);
  if (editing != null) {
    notifier.startEdit(editing);
  } else {
    notifier.startCreate();
  }
  return showTenkaiSheet<void>(
    context: context,
    title: editing != null ? 'Edit book' : 'Add a book',
    child: _BookFormSheet(editing: editing),
  );
}

class _BookFormSheet extends HookConsumerWidget {
  const _BookFormSheet({this.editing});
  final Book? editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(bookFormProvider);
    final notifier = ref.read(bookFormProvider.notifier);

    final titleCtrl = useTextEditingController(text: form.title);
    final authorCtrl = useTextEditingController(text: form.author);
    final totalCtrl = useTextEditingController(
      text: form.totalPages?.toString() ?? '',
    );
    final currentCtrl = useTextEditingController(
      text: form.currentPage == 0 ? '' : form.currentPage.toString(),
    );
    final goalCtrl = useTextEditingController(
      text: form.dailyPageGoal?.toString() ?? '',
    );

    // The sheet (`showTenkaiSheet`) already scrolls and lifts above the
    // keyboard, so this just lays out its fields.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cover picker
        Center(
          child: GestureDetector(
            onTap: () => _pickCover(context, ref),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                BookCover(path: form.coverImagePath, width: 84, height: 118),
                const SizedBox(height: 8),
                Text(
                  form.coverImagePath == null ? 'Add cover' : 'Change cover',
                  style: TenkaiTypography.labelSm,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        _label('Title'),
        const SizedBox(height: 6),
        TenkaiTextFormField(
          placeholder: 'Book title',
          controller: titleCtrl,
          onChanged: notifier.setTitle,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TenkaiTextFormField(
          label: 'Author (optional)',
          placeholder: 'Author',
          controller: authorCtrl,
          onChanged: notifier.setAuthor,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TenkaiTextFormField(
                label: 'Total pages',
                placeholder: '320',
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.setTotalPages(int.tryParse(v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TenkaiTextFormField(
                label: 'Current page',
                placeholder: '0',
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.setCurrentPage(int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _label('Shelf'),
        const SizedBox(height: 8),
        // TenkaiRadioGroup<BookStatus>(
        //   options: BookStatus.values,
        //   labels: BookStatus.values.map((s) => s.label).toList(),
        //   value: form.status,
        //   onChanged: notifier.setStatus,
        // ),
        const SizedBox(height: 20),
        const TenkaiDivider(),
        const SizedBox(height: 16),

        // Deadline (optional)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Deadline (optional)', style: TenkaiTypography.bodyMd),
            Row(
              children: [
                if (form.deadline != null) ...[
                  Text(
                    DateFormat('MMM d, y').format(form.deadline!),
                    style: TenkaiTypography.labelMd.copyWith(
                      color: context.tenkai.foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => notifier.setDeadline(null),
                    child: CNIcon(
                      symbol: CNSymbol(
                        'xmark',
                        size: 16,
                        color: context.tenkai.mutedForeground,
                      ),
                    ),
                  ),
                ] else
                  TenkaiButton(
                    label: 'Set',
                    size: TenkaiButtonSize.sm,
                    variant: TenkaiButtonVariant.ghost,
                    onPressed: () async {
                      final picked = await _pickDate(context, form.deadline);
                      if (picked != null) notifier.setDeadline(picked);
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
          controller: goalCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => notifier.setDailyGoal(int.tryParse(v)),
        ),
        const SizedBox(height: 20),
        const TenkaiDivider(),
        const SizedBox(height: 16),

        // Reminder
        TenkaiToggle(
          value: form.reminderEnabled,
          onChanged: notifier.setReminderEnabled,
          label: 'Daily reading reminder',
        ),
        if (form.reminderEnabled) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Remind me at', style: TenkaiTypography.bodyMd),
              GestureDetector(
                onTap: () async {
                  final picked = await _pickTime(
                    context,
                    form.reminderHour,
                    form.reminderMinute,
                  );
                  if (picked != null) {
                    notifier.setReminderTime(picked.$1, picked.$2);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.tenkai.card,
                    borderRadius: BorderRadius.circular(TenkaiRadius.control),
                    border: Border.all(color: context.tenkai.border, width: 1),
                  ),
                  child: Text(
                    _hm(form.reminderHour, form.reminderMinute),
                    style: TenkaiTypography.mono.copyWith(
                      color: context.tenkai.foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TenkaiButton(
            label: editing != null ? 'Save changes' : 'Add book',
            loading: form.saving,
            enabled: form.isValid && !form.saving,
            onPressed: () async {
              final id = await notifier.save();
              if (id != null && context.mounted) {
                Navigator.of(context).pop();
                showTenkaiToast(
                  context,
                  TenkaiToastData(
                    title: editing != null ? 'Book updated' : 'Book added',
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

  Widget _label(String t) =>
      Text(t.toUpperCase(), style: TenkaiTypography.labelMd);

  Future<void> _pickCover(BuildContext context, WidgetRef ref) async {
    final service = ref.read(imageStorageServiceProvider);
    final notifier = ref.read(bookFormProvider.notifier);
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: context.tenkai.card,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CNIcon(
                symbol: CNSymbol(
                  'camera.fill',
                  color: context.tenkai.foreground,
                ),
              ),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: CNIcon(
                symbol: CNSymbol(
                  'photo.on.rectangle',
                  color: context.tenkai.foreground,
                ),
              ),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            if (ref.read(bookFormProvider).coverImagePath != null)
              ListTile(
                leading: const CNIcon(
                  symbol: CNSymbol('trash', color: TenkaiColors.error),
                ),
                title: const Text('Remove cover'),
                onTap: () {
                  notifier.setCover(null);
                  Navigator.pop(sheetCtx, null);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final path = await service.pickAndStore(source: source);
    if (path != null) notifier.setCover(path);
  }
}

String _hm(int h, int m) =>
    '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
  var picked = initial ?? DateTime.now().add(const Duration(days: 14));
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
