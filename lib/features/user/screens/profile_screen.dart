import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/theme_mode_provider.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/features/user/provider/user_stat_provider.dart';
import 'package:tenkai/features/user/widgets/add_stat_form.dart';
import 'package:tenkai/features/user/widgets/update_stat_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _confirmLogout() async {
    final shouldLogout = await showTenkaiDialog<bool>(
      context: context,
      title: 'Log out?',
      description: 'You will need to sign in again to continue.',
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          child: Text('Log out'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (shouldLogout ?? false) {
      // The router guard redirects to /login once state is unauthenticated.
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStatState = ref.watch(userStatProvider);
    final c = context.tenkai;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // appBar: TenkaiAppBar(
      //   title: 'Profile',
      //   showBackButton: false,
      //   actions: [
      //     TenkaiAppBarAction(
      //       symbol: 'plus',
      //       onPressed: () => showTenkaiSheet(
      //         context: context,
      //         title: 'Track a stat',
      //         child: AddStatForm(),
      //       ),
      //     ),
      //     TenkaiAppBarAction(
      //       symbol: 'rectangle.portrait.and.arrow.right',
      //       onPressed: _confirmLogout,
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Column(children: [Card(child: Text('asdfas'))]),
      ),
      // body: ListView(
      //   padding: EdgeInsets.fromLTRB(
      //     TenkaiSpacing.lg,
      //     MediaQuery.of(context).padding.top + TenkaiAppBar.compactHeight,
      //     TenkaiSpacing.lg,
      //     TenkaiSpacing.xl,
      //   ),
      //   children: [
      //     _sectionLabel('Appearance', c),
      //     const SizedBox(height: TenkaiSpacing.sm),
      //     const _ThemeModeSelector(),
      //     const SizedBox(height: TenkaiSpacing.xl),
      //     _sectionLabel('Tracked stats', c),
      //     const SizedBox(height: TenkaiSpacing.sm),
      //     _statsBody(userStatState, c),
      //   ],
      // ),
    );
  }

  Widget _sectionLabel(String text, TenkaiSemanticColors c) => Text(
    text.toUpperCase(),
    style: TenkaiTypography.labelSm.copyWith(color: c.secondaryForeground),
  );

  Widget _statsBody(dynamic state, TenkaiSemanticColors c) {
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: TenkaiSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: c.mutedForeground,
            ),
          ),
        ),
      );
    }
    final stats = state.userStats;
    if (stats == null) {
      return const TenkaiEmptyState(
        title: 'Couldn\'t load your stats',
        description:
            'Something went wrong. Pull down or try again in a moment.',
      );
    }
    if (stats.isEmpty) {
      return const TenkaiEmptyState(
        title: 'No stats yet',
        description: 'Track a stat with the + button to see it here.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: TenkaiSpacing.sm),
          ListTile(
            title: stats[i].title,
            trailing: Text(
              '${stats[i].value} ${stats[i].unit}',
              style: TenkaiTypography.bodyMd.copyWith(color: c.mutedForeground),
            ),
            onTap: () => showTenkaiSheet(
              context: context,
              title: 'Update ${stats[i].title}',
              child: UpdateStatForm(userStat: stats[i]),
            ),
          ),
        ],
      ],
    );
  }
}

/// System / Light / Dark selector, persisted via [themeModeProvider].
class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    Widget chip(String label, ThemeMode value) => Padding(
      padding: const EdgeInsets.only(right: TenkaiSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: mode == value,
        onSelected: (isSelected) => notifier.set(value),
      ),
    );

    return Row(
      children: [
        chip('System', ThemeMode.system),
        chip('Light', ThemeMode.light),
        chip('Dark', ThemeMode.dark),
      ],
    );
  }
}
