import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/knowledge/providers/book_provider.dart';

import '../models/book_enums.dart';

class KnowledgeDashboard extends ConsumerWidget {
  const KnowledgeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookState = ref.watch(bookProvider);
    final reading = bookState.books
        .where((b) => BookStatus.fromDb(b.status) == BookStatus.reading)
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
                  onTap: () => context.push('/knowledge/book-library'),
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
