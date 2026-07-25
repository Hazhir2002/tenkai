import 'package:flutter/material.dart';
import '../tokens/tenkai_tokens.dart';

/// Global route transition: a fade combined with a subtle scale-in,
/// driven by the same spring curve used across the design system's
/// interactive motion (buttons, glow, toggles). Deliberately cheap —
/// no blur — since it runs on every route push/pop.
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
    final curved = CurvedAnimation(
      parent: animation,
      curve: TenkaiCurves.spring,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
