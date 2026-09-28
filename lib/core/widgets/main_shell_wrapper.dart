import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

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
      '/habits',
      '/fitness',
      '/user',
    ].contains(location);

    void onItemTap(int index) {
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
          ? NavigationBar(
              animationDuration: TenkaiDuration.medium,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: onItemTap,
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(IconsaxBold.bubble),
                  icon: Icon(IconsaxOutline.bubble),
                  label: 'habits',
                ),
                NavigationDestination(
                  selectedIcon: Icon(IconsaxBold.health),
                  icon: Icon(IconsaxOutline.health),
                  label: 'fitness',
                ),
                NavigationDestination(
                  selectedIcon: Icon(IconsaxBold.user),
                  icon: Icon(IconsaxOutline.user),
                  label: 'fears',
                ),
              ],
            )
          : null,
    );
  }
}
