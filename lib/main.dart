import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/configs/app_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/services/notification_service.dart';
import 'package:tenkai/core/services/storage_service.dart';
import 'package:tenkai/core/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TenkaiSound.initialize();

  // Load the persisted theme mode before the first frame so there's no flash.
  final storedThemeMode = await StorageService().getThemeMode();

  // Share a single container so the notification service instance initialized
  // here is the same one the app reads via [notificationServiceProvider].
  final container = ProviderContainer(
    overrides: [initialThemeModeProvider.overrideWithValue(storedThemeMode)],
  );
  await container.read(notificationServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(container: container, child: const TenkaiApp()),
  );
}

class TenkaiApp extends ConsumerWidget {
  const TenkaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: TenkaiTheme.light,
      darkTheme: TenkaiTheme.dark,
      themeMode: themeMode,
      title: 'Tenkai',
      builder: (context, child) => DefaultTextStyle(
        // Fallback text color so no text renders black-by-default now that the
        // TenkaiTypography styles are color-agnostic. Individual widgets still
        // override via context.tenkai.* / the theme's textTheme.
        style: TenkaiTypography.bodyMd.copyWith(
          color: context.tenkai.foreground,
        ),
        child: Listener(
          // Tap anywhere outside a field to dismiss the keyboard, app-wide.
          //
          // Uses a passive [Listener] (raw pointer events) rather than a
          // GestureDetector: a GestureDetector.onTap here joins the gesture
          // arena for every tap and beats native platform views (the CNTabBar
          // UiKitView), which only claim gestures nothing else wants — so tabs
          // could only be switched by dragging, not tapping. A Listener never
          // enters the arena, so native views keep receiving their taps.
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            final focus = FocusManager.instance.primaryFocus;
            if (focus != null && focus.hasPrimaryFocus) {
              focus.unfocus();
            }
          },
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
