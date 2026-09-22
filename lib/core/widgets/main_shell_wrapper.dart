import 'package:cupertino_native_better/components/tab_bar.dart';
import 'package:cupertino_native_better/style/sf_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainShellWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellWrapper({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShellWrapper> createState() => _MainShellWrapperState();
}

class _MainShellWrapperState extends ConsumerState<MainShellWrapper> {
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final bool showBottomBar = [
      // '/',
      // '/goals',
      '/habits',
      '/profile',
      // '/knowledge',
      // '/journal',
    ].contains(location);

    void _onItemTap(int index) {
      HapticFeedback.mediumImpact();
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // body: IndexedStack(
      //   index: widget.navigationShell.currentIndex,
      //   children: const [
      //     HabitDashboard(),
      //     ProfileScreen(),
      //     KnowledgeDashboard(),
      //     JournalDashboard(),
      //   ],
      // ),
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: showBottomBar
          ? NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onItemTap,
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(Iconsax.user),
                  icon: Icon(Iconsax.user),
                  label: 'habits',
                ),
                NavigationDestination(
                  selectedIcon: Icon(LucideIcons.user),
                  icon: Icon(LucideIcons.user),
                  label: 'profile',
                ),
              ],
              // currentIndex: widget.navigationShell.currentIndex,
              // onTap: _onItemTap,
            )
          : null,
    );
  }
}
