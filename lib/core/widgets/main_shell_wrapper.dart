import 'package:cupertino_native_better/components/tab_bar.dart';
import 'package:cupertino_native_better/style/sf_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/habit_tracker/screens/habit_dashboard.dart';
import 'package:tenkai/features/journal/screens/journal_dashboard.dart';
import 'package:tenkai/features/knowledge/screens/knowledge_dashboard.dart';
import 'package:tenkai/features/profile/screens/profile_screen.dart';

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
      '/profile',
      '/',
      '/knowledge',
      '/journal',
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
          ? CNTabBar(
              iconSize: 16,
              items: [
                CNTabBarItem(
                  icon: CNSymbol(
                    widget.navigationShell.currentIndex == 0
                        ? 'house.fill'
                        : 'house',
                  ),
                ),
                CNTabBarItem(
                  icon: CNSymbol(
                    widget.navigationShell.currentIndex == 1
                        ? 'person.fill'
                        : 'person',
                  ),
                ),
                CNTabBarItem(
                  icon: CNSymbol(
                    widget.navigationShell.currentIndex == 2
                        ? 'text.book.closed.fill'
                        : 'text.book.closed',
                  ),
                ),
                CNTabBarItem(
                  icon: CNSymbol(
                    widget.navigationShell.currentIndex == 3
                        ? 'book.fill'
                        : 'book',
                  ),
                ),
              ],
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onItemTap,
            )
          : null,
    );
  }
}
