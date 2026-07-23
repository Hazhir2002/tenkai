import 'package:flutter/material.dart';

class PettaioPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const PettaioPadding({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
