import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/widgets/tenkai_section.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Hello ${authState.user!.username}')),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TenkaiSection(title: 'Todays tasks', child: Text('tasks')),
              Center(
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
