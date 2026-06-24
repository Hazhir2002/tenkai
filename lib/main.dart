import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/configs/app_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TenkaiSound.initialize();

  runApp(ProviderScope(child: TenkaiApp()));
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
    );
  }
}
