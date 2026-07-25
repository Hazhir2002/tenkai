import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/configs/app_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TenkaiSound.initialize();

  // Share a single container so the notification service instance initialized
  // here is the same one the app reads via [notificationServiceProvider].
  final container = ProviderContainer();
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

    return MaterialApp.router(
      routerConfig: router,
      theme: TenkaiTheme.dark,
      title: 'Tenkai',
      builder: (context, child) => GestureDetector(
        // Tap anywhere outside a field to dismiss the keyboard, app-wide.
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }
}
