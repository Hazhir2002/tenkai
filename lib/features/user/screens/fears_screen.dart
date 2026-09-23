import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/user/widgets/user_fear_form_sheet.dart';

class FearsScreen extends HookConsumerWidget {
  const FearsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fears'),
        actions: [
          IconButton(
            onPressed: () => showUserFearFormSheet(context, ref),
            icon: Icon(IconsaxOutline.add),
          ),
        ],
      ),
      body: Center(child: Text('Fears')),
    );
  }
}
