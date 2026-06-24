import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

// ─────────────────────────────────────────────
// TENKAI · Sound Engine
// Synthetic / Sci-fi tones via C++ SoLoud Engine (dart:ffi)
// Context-aware: zero-latency micro-interactions
// ─────────────────────────────────────────────
//
// SETUP: Add to pubspec.yaml
//   dependencies:
//     flutter_soloud: ^3.0.0
//
// Sound files go in assets/sounds/
// Ensure they are declared in your pubspec.yaml
// ─────────────────────────────────────────────

/// Tenkai sound event types mapped to interaction contexts
enum TenkaiSoundEvent {
  /// Micro-interactions: checkbox, radio, toggle (subtle)
  tap,

  /// Text fields gaining focus (barely-there)
  focus,

  /// Primary CTA, confirm, success action (bold 3-note chord)
  confirm,

  /// Navigation: tab switch, page push (single mid tone)
  nav,

  /// Destructive action, error state (dissonant, lower freq)
  error,

  /// App launch, system ready (rising synth sweep)
  boot,

  /// Slider drag (continuous, very soft)
  drag,

  /// Sheet/dialog open (airy, mid freq)
  modal,

  /// Sheet/dialog close (descending)
  modalClose,
}

/// Global mutable sound config — wire to user settings
class TenkaiSoundConfig {
  static bool enabled = true;
  static double volume = 0.6; // 0.0 – 1.0
}

/// Sound engine — Call TenkaiSound.initialize() at app boot,
/// then call TenkaiSound.play() from anywhere.
abstract final class TenkaiSound {
  /// Asset path map — flutter_soloud utilizes full bundle paths
  static const Map<TenkaiSoundEvent, String> _assets = {
    TenkaiSoundEvent.tap: 'assets/sounds/click1.mp3',
    // TenkaiSoundEvent.focus: 'assets/sounds/focus.ogg',
    TenkaiSoundEvent.confirm: 'assets/sounds/confirm.mp3',
    // TenkaiSoundEvent.nav: 'assets/sounds/nav.ogg',
    // TenkaiSoundEvent.error: 'assets/sounds/error.ogg',
    // TenkaiSoundEvent.boot: 'assets/sounds/boot.ogg',
    // TenkaiSoundEvent.drag: 'assets/sounds/drag.ogg',
    // TenkaiSoundEvent.modal: 'assets/sounds/modal.ogg',
    // TenkaiSoundEvent.modalClose: 'assets/sounds/modal_close.ogg',
  };

  /// Preloaded audio sound sources stored in memory for instant triggers
  static final Map<TenkaiSoundEvent, AudioSource> _sources = {};
  static bool _initialized = false;

  /// Initializes the SoLoud instance and preloads audio into memory.
  /// Call this in main.dart before running your app.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await SoLoud.instance.init();

      // Concurrently load all assets into memory for instant firing
      for (final entry in _assets.entries) {
        final source = await SoLoud.instance.loadAsset(entry.value);
        _sources[entry.key] = source;
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint('[TenkaiSound] ⚡ Engine initialized. All assets cached.');
      }
    } catch (err) {
      debugPrint('[TenkaiSound] ❌ Initialization failed: $err');
    }
  }

  /// Play a sound event instantly. Safe to call anywhere — no-ops when disabled.
  static void play(TenkaiSoundEvent event) {
    if (!TenkaiSoundConfig.enabled || !_initialized) return;

    try {
      final source = _sources[event];
      if (source == null) {
        debugPrint(
          '[TenkaiSound] ⚠️ Source not found for event: ${event.name}',
        );
        return;
      }

      // Fire-and-forget instantly via C++ bindings
      SoLoud.instance.play(source, volume: TenkaiSoundConfig.volume);

      if (kDebugMode) {
        debugPrint('[TenkaiSound] ▶ ${event.name}');
      }
    } catch (err) {
      debugPrint('[TenkaiSound] ❌ Playback exception: $err');
    }
  }

  /// Convenience methods for common events
  static void tap() => play(TenkaiSoundEvent.tap);
  static void focus() => play(TenkaiSoundEvent.focus);
  static void confirm() => play(TenkaiSoundEvent.confirm);
  static void nav() => play(TenkaiSoundEvent.nav);
  static void error() => play(TenkaiSoundEvent.error);
  static void boot() => play(TenkaiSoundEvent.boot);
  static void modal() => play(TenkaiSoundEvent.modal);
  static void modalClose() => play(TenkaiSoundEvent.modalClose);
}

// ─────────────────────────────────────────────
// SOUND FREQUENCY REFERENCE
// (for generating your .ogg assets with Audacity/Tone.js)
// ─────────────────────────────────────────────
//
// tap         → sine 880Hz → 1200Hz, 80ms, gain 0.06, fade out
// focus       → sine 440Hz, 60ms, gain 0.04, fade out
// confirm     → sine chord: 523→659→784Hz, 320ms, gain 0.06
// nav         → sine 1046Hz, 50ms, gain 0.05, fade out
// error       → sawtooth 220→180Hz, 300ms, gain 0.06
// boot        → sine sweep 220→880Hz, 800ms, reverb tail
// drag        → sine 660Hz, 20ms loop, gain 0.02
// modal       → sine 523Hz, 120ms, gain 0.05
// modalClose  → sine 392Hz, 100ms, gain 0.04, fade out
