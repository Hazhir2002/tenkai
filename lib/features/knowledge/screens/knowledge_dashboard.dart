import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/book_enums.dart';
import '../providers/books_provider.dart';

class KnowledgeDashboard extends HookConsumerWidget {
  const KnowledgeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final reading = booksAsync.valueOrNull
        ?.where((b) => BookStatus.fromDb(b.status) == BookStatus.reading)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Knowledge')),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  onTap: () => context.push('/knowledge/books'),
                  leading: const TenkaiNode(size: 22),
                  title: Text('Books'),
                  subtitle: Text(
                    reading == null
                        ? 'Track what you\'re reading'
                        : reading == 0
                        ? 'Nothing in progress'
                        : '$reading reading',
                  ),
                  trailing: Icon(IconsaxOutline.arrow_right_3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
