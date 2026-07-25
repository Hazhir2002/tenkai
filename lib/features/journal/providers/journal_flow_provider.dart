import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

enum JournalFlowStage {
  idle, // showing the big "Start Recording" button
  recording, // actively listening
  reviewing, // transcript ready, user can edit before saving
}

class JournalFlowState {
  const JournalFlowState({
    this.stage = JournalFlowStage.idle,
    this.speechAvailable = false,
    this.liveTranscript = '',
    this.draftText = '',
    this.draftSource = 'typed',
  });

  final JournalFlowStage stage;
  final bool speechAvailable;
  final String liveTranscript;
  final String draftText;
  final String draftSource;

  JournalFlowState copyWith({
    JournalFlowStage? stage,
    bool? speechAvailable,
    String? liveTranscript,
    String? draftText,
    String? draftSource,
  }) {
    return JournalFlowState(
      stage: stage ?? this.stage,
      speechAvailable: speechAvailable ?? this.speechAvailable,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      draftText: draftText ?? this.draftText,
      draftSource: draftSource ?? this.draftSource,
    );
  }
}

class JournalFlowNotifier extends Notifier<JournalFlowState> {
  final SpeechToText _speech = SpeechToText();

  @override
  JournalFlowState build() {
    _initSpeech();
    return const JournalFlowState();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' &&
            state.stage == JournalFlowStage.recording) {
          _finishRecording();
        }
      },
    );
    state = state.copyWith(speechAvailable: available);
  }

  /// Called from the big button on the home screen.
  Future<void> startRecording() async {
    if (!state.speechAvailable) return;
    state = state.copyWith(
      stage: JournalFlowStage.recording,
      liveTranscript: '',
    );

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    state = state.copyWith(liveTranscript: result.recognizedWords);
  }

  /// User taps the stop button while recording.
  Future<void> stopRecording() async {
    await _speech.stop();
    _finishRecording();
  }

  void _finishRecording() {
    state = state.copyWith(
      stage: JournalFlowStage.reviewing,
      draftText: state.liveTranscript.trim(),
      draftSource: 'voice',
    );
  }

  /// Lets the user start a fresh entry by typing instead of speaking.
  void startTyping() {
    state = state.copyWith(
      stage: JournalFlowStage.reviewing,
      draftText: '',
      draftSource: 'typed',
    );
  }

  void updateDraft(String text) {
    state = state.copyWith(draftText: text);
  }

  void discardDraft() {
    state = state.copyWith(
      stage: JournalFlowStage.idle,
      draftText: '',
      liveTranscript: '',
    );
  }

  /// Final confirm step: only now does the entry get written to Drift.
  Future<void> confirmAndSave() async {
    final trimmed = state.draftText.trim();
    if (trimmed.isEmpty) return;
    await ref
        .read(appDataBaseProvider)
        .journalDao
        .addEntry(content: trimmed, source: state.draftSource);
    state = state.copyWith(
      stage: JournalFlowStage.idle,
      draftText: '',
      liveTranscript: '',
    );
  }

  Future<void> deleteEntry(int id) {
    return ref.read(appDataBaseProvider).journalDao.deleteEntry(id);
  }

  Future<void> editEntry(JournalEntry entry, String newContent) {
    return ref
        .read(appDataBaseProvider)
        .journalDao
        .updateEntry(entry, newContent.trim());
  }
}

final journalFlowProvider =
    NotifierProvider<JournalFlowNotifier, JournalFlowState>(
      JournalFlowNotifier.new,
    );
