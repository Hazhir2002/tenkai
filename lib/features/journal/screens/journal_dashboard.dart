import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_app_bar.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_record_button.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_duration.dart';

import '../providers/journal_flow_provider.dart';

class JournalDashboard extends HookConsumerWidget {
  const JournalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(journalFlowProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TenkaiAppBar(
        title: 'Journal',
        showBackButton: false,
        actions: [
          TenkaiAppBarAction(
            symbol: 'archivebox.fill',
            onPressed: () => context.push('/journal/logs'),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        minimum: const EdgeInsets.only(
          left: TenkaiSpacing.lg,
          right: TenkaiSpacing.lg,
          top: TenkaiAppBar.compactHeight,
        ),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: TenkaiDuration.medium,
                child: flow.stage == JournalFlowStage.reviewing
                    ? const _ReviewSheet()
                    : _IdleOrRecordingBody(stage: flow.stage),
              ),
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
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: TenkaiDuration.medium,
              child: recording
                  ? _LiveTranscriptPreview(text: flow.liveTranscript)
                  : _IdlePrompt(speechAvailable: flow.speechAvailable),
            ),
          ),
        ),
        TenkaiRecordButton(
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
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (!recording)
          CNButton(
            label: 'Or type instead',
            onPressed: () => notifier.startTyping(),
            config: CNButtonConfig(style: CNButtonStyle.plain),
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
    final theme = Theme.of(context);

    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 120,
          maxHeight: 260,
          minWidth: double.infinity,
        ),
        child: SingleChildScrollView(
          reverse: true,
          child: Text(
            text.isEmpty ? 'Listening…' : text,
            style: theme.textTheme.bodyLarge,
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
    final controller = useTextEditingController(text: flow.draftText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TenkaiInput(
          controller: controller,
          maxLines: null,
          // expands: true,
          textAlignVertical: TextAlignVertical.top,
          autofocus: flow.draftSource == 'typed',
          onChanged: notifier.updateDraft,
          label: 'Review your entry',
          placeholder: 'Start typing your journal entry…',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TenkaiButton(
                label: 'Discard',
                variant: TenkaiButtonVariant.ghost,
                onPressed: () => notifier.discardDraft(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TenkaiButton(
                label: 'Save to Journal',
                onPressed: () async {
                  await notifier.confirmAndSave();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
