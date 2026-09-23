import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/book_enums.dart';
import '../providers/books_provider.dart';

/// The Knowledge tab is a hub of subsections. Books is the first one; more
/// (notes, courses, ...) will land here over time.
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
        child: SingleChildScrollView(
          // padding: const EdgeInsets.fromLTRB(
          //   TenkaiSpacing.lg,
          //   TenkaiAppBar.compactHeight + TenkaiSpacing.md,
          //   TenkaiSpacing.lg,
          //   120,
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                // interactive: true,
                // onTap: () => context.push('/knowledge/books'),
                child: Row(
                  children: [
                    const TenkaiNode(size: 22),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Books', style: TenkaiTypography.h3),
                          const SizedBox(height: 2),
                          Text(
                            reading == null
                                ? 'Track what you\'re reading'
                                : reading == 0
                                ? 'Nothing in progress'
                                : '$reading reading',
                            style: TenkaiTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    CNIcon(
                      symbol: CNSymbol(
                        'chevron.right',
                        color: context.tenkai.secondaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ComingSoonCard(title: 'Notes'),
              const SizedBox(height: 12),
              _ComingSoonCard(title: 'Courses'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Card(
        child: Row(
          children: [
            CNIcon(
              symbol: CNSymbol(
                'hourglass',
                size: 20,
                color: context.tenkai.secondaryForeground,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TenkaiTypography.h3),
                  const SizedBox(height: 2),
                  Text('Coming soon', style: TenkaiTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
