import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_record_button.dart';

import '../providers/journal_flow_provider.dart';

class JournalDashboard extends HookConsumerWidget {
  const JournalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(journalFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
        actions: [
          CNButton.icon(
            icon: const CNSymbol('heart.fill'),
            onPressed: () => context.push('/journal/logs'),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: flow.stage == JournalFlowStage.reviewing
                  ? const _ReviewSheet()
                  : _IdleOrRecordingBody(stage: flow.stage),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleOrRecordingBody extends HookConsumerWidget {
  const _IdleOrRecordingBody({required this.stage});
  final JournalFlowStage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(journalFlowProvider);
    final notifier = ref.read(journalFlowProvider.notifier);
    final recording = stage == JournalFlowStage.recording;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: recording
                ? _LiveTranscriptPreview(text: flow.liveTranscript)
                : _IdlePrompt(speechAvailable: flow.speechAvailable),
          ),
        ),
        RecordButton(
          isRecording: recording,
          enabled: flow.speechAvailable || recording,
          onTap: () {
            if (recording) {
              notifier.stopRecording();
            } else {
              notifier.startRecording();
            }
          },
        ),
        const SizedBox(height: 20),
        Text(
          recording ? 'Tap to stop' : 'Tap to start recording',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (!recording)
          CNButton(
            label: 'Or type instead',
            onPressed: () => notifier.startTyping(),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _IdlePrompt extends StatelessWidget {
  const _IdlePrompt({required this.speechAvailable});
  final bool speechAvailable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        speechAvailable
            ? "What's on your mind today?"
            : 'Speech recognition isn\'t available on this device.\nYou can still type your entry.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _LiveTranscriptPreview extends StatelessWidget {
  const _LiveTranscriptPreview({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 260),
        child: SingleChildScrollView(
          reverse: true,
          child: Text(
            text.isEmpty ? 'Listening…' : text,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: text.isEmpty
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown after recording stops (or when the user chooses to type). The
/// entry is NOT written to the database until the user explicitly
/// confirms here — this is the "make sure it's correct" step.
class _ReviewSheet extends HookConsumerWidget {
  const _ReviewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(journalFlowProvider);
    final notifier = ref.read(journalFlowProvider.notifier);

    // useTextEditingController keeps the controller alive across rebuilds
    // and disposes it automatically — no manual initState/dispose needed.
    final controller = useTextEditingController(text: flow.draftText);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review your entry',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Edit anything before saving it to your journal.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                autofocus: flow.draftSource == 'typed',
                onChanged: notifier.updateDraft,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.black.withOpacity(0.85),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing your journal entry…',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CNButton(
                  label: 'Discard',
                  onPressed: () => notifier.discardDraft(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CNButton(
                  label: 'Save to Journal',
                  onPressed: () async {
                    await notifier.confirmAndSave();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
