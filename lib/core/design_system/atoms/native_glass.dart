import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../tokens/tenkai_tokens.dart';
import 'liquid_glass.dart';

/// The *real* thing: Apple's actual Liquid Glass material, rendered through
/// a native platform view (`cupertino_native_better`'s
/// `LiquidGlassContainer`, a `UiKitView` under the hood). This is what has
/// the dynamic specular highlight and refraction behavior — that behavior
/// lives in Apple's private rendering pipeline, not something a Flutter
/// `BackdropFilter` can reproduce. What [LiquidGlass] does (blur + gradient
/// + hairline border) is plain glassmorphism, not Liquid Glass; this widget
/// is the honest version of that claim.
///
/// Falls back to [LiquidGlass] automatically on iOS < 26, macOS < 26, and
/// non-Apple platforms, where no native Liquid Glass material exists to
/// render at all.
///
/// ⚠️ IMPORTANT — do not use this inside scrolling lists. Per the package's
/// own guidance, `LiquidGlassContainer` is a real platform view, and
/// creating many of them in a `ListView`/`GridView` causes serious jank.
/// Use it only for static, single-instance surfaces: app bars, the record
/// button, bottom sheets, empty states, headers. For repeated list items
/// (e.g. journal entry cards), use [LiquidGlass] directly instead — that's
/// a deliberate choice, not an oversight.
class NativeGlass extends StatelessWidget {
  const NativeGlass({
    super.key,
    required this.child,
    this.cornerRadius = TenkaiRadius.lg,
    this.shape = CNGlassEffectShape.rect,
    this.interactive = false,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final double cornerRadius;
  final CNGlassEffectShape shape;
  final bool interactive;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (PlatformVersion.shouldUseNativeGlass) {
      return LiquidGlassContainer(
        config: LiquidGlassConfig(
          effect: CNGlassEffect.regular,
          shape: shape,
          cornerRadius: cornerRadius,
          interactive: interactive,
        ),
        child: Padding(padding: padding, child: child),
      );
    }
    // No native Liquid Glass material available on this OS/version — fall
    // back to the Flutter-drawn glassmorphism approximation.
    return LiquidGlass(
      borderRadius: cornerRadius,
      padding: padding,
      child: child,
    );
  }
}
