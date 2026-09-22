import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/services/storage_service.dart';

/// Seed for [themeModeProvider]. Overridden in `main()` with the value loaded
/// from storage *before* `runApp`, so the app starts on the persisted theme
/// with no flash. Defaults to following the system appearance.
final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);

/// The active UI theme mode (System / Light / Dark). Persisted on change.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(initialThemeModeProvider);

  Future<void> set(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(storageServiceProvider).saveThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
