import 'package:cupertino_native/components/tab_bar.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: showBottomBar
          ? CNTabBar(
              items: const [
                CNTabBarItem(icon: CNSymbol('house.fill')),
                CNTabBarItem(icon: CNSymbol('person.crop.circle')),
                CNTabBarItem(icon: CNSymbol('text.book.closed.fill')),
                CNTabBarItem(icon: CNSymbol('book.fill')),
              ],
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onItemTap,
            )
          : null,
    );
  }
}
