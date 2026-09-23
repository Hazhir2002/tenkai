import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../providers/journal_entries_provider.dart';
import '../providers/journal_flow_provider.dart';

class JournalLogsScreen extends ConsumerWidget {
  const JournalLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Journal Logs')),
      body: entriesAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Couldn\'t load entries',
            style: TenkaiTypography.bodyMd.copyWith(
              color: context.tenkai.mutedForeground,
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top,
              20,
              32,
            ),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _EntryCard(entry: entries[index]),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TenkaiEmptyState(
        icon: CNIcon(
          symbol: CNSymbol(
            'book.closed',
            size: 36,
            color: context.tenkai.mutedForeground,
          ),
        ),
        title: 'No entries yet',
        description:
            'Record or type your first journal entry and it will show up here.',
      ),
    );
  }
}

class _EntryCard extends HookConsumerWidget {
  const _EntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.tenkai;
    final notifier = ref.read(journalFlowProvider.notifier);
    final dateLabel = DateFormat('MMM d, y · h:mm a').format(entry.createdAt);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TenkaiRadius.card),
          color: c.destructive,
          border: Border.all(color: c.border, width: 1),
        ),
        child: CNIcon(symbol: CNSymbol('trash.fill', color: c.destructive)),
      ),
      onDismissed: (_) => notifier.deleteEntry(entry.id),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CNIcon(
                  symbol: CNSymbol(
                    entry.source == 'voice' ? 'mic.fill' : 'pencil',
                    size: 14,
                    color: c.secondaryForeground,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: TenkaiTypography.labelMd.copyWith(
                      color: c.secondaryForeground,
                    ),
                  ),
                ),
                CNPopupMenuButton(
                  buttonLabel: '•••',
                  items: const [
                    CNPopupMenuItem(label: 'Edit', icon: CNSymbol('pencil')),
                    CNPopupMenuItem(label: 'Delete', icon: CNSymbol('trash')),
                  ],
                  onSelected: (i) {
                    if (i == 0) {
                      _openEditSheet(context, ref, entry);
                    } else {
                      notifier.deleteEntry(entry.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _openEditSheet(context, ref, entry),
              child: Text(
                entry.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, WidgetRef ref, JournalEntry entry) {
    showTenkaiSheet(
      context: context,
      title: 'Edit entry',
      child: _EditEntryForm(entry: entry),
    );
  }
}

class _EditEntryForm extends HookConsumerWidget {
  const _EditEntryForm({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: entry.content);
    final notifier = ref.read(journalFlowProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TenkaiTextarea(controller: controller, rows: 5),
        const SizedBox(height: TenkaiSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TenkaiButton(
                label: 'Cancel',
                variant: TenkaiButtonVariant.ghost,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: TenkaiSpacing.md),
            Expanded(
              child: TenkaiButton(
                label: 'Save',
                onPressed: () async {
                  await notifier.editEntry(entry, controller.text);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
