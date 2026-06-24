import 'package:flutter/material.dart';

class TenkaiPageTransitionBuilder extends PageTransitionsBuilder {
  const TenkaiPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Define your global transition here.
    // Example: A clean fade transition for your custom theme
    return FadeTransition(opacity: animation, child: child);
  }
}
