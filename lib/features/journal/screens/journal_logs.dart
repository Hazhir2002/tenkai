import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tenkai/core/database.dart';

import '../providers/journal_entries_provider.dart';
import '../providers/journal_flow_provider.dart';

class JournalLogsScreen extends ConsumerWidget {
  const JournalLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Journal Logs')),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: entriesAsync.when(
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (err, _) =>
                    Center(child: Text('Couldn\'t load entries: $err')),
                data: (entries) {
                  if (entries.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _EntryCard(entry: entries[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CNIcon(symbol: CNSymbol('book.closed', size: 40)),
              const SizedBox(height: 12),
              Text(
                'No entries yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Record or type your first journal entry\nand it will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends HookConsumerWidget {
  const _EntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(journalFlowProvider.notifier);
    final dateLabel = DateFormat('MMM d, y · h:mm a').format(entry.createdAt);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFFF6B6B).withOpacity(0.6),
        ),
        child: const CNIcon(
          symbol: CNSymbol('trash.fill', color: Colors.white),
        ),
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
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
                // Native Liquid Glass popup menu — a real upgrade over a
                // hand-rolled menu button, so we use cupertino_native here.
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
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, WidgetRef ref, JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditEntrySheet(entry: entry),
    );
  }
}

class _EditEntrySheet extends HookConsumerWidget {
  const _EditEntrySheet({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: entry.content);
    final notifier = ref.read(journalFlowProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                minLines: 3,
                style: TextStyle(color: Colors.black.withOpacity(0.85)),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CNButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CNButton(
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
          ),
        ),
      ),
    );
  }
}
