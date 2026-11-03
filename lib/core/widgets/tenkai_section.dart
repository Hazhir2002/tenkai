import 'package:flutter/material.dart';

class TenkaiSection extends StatelessWidget {
  final String title;
  final Widget child;

  const TenkaiSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(children: [Text(title, style: theme.textTheme.titleSmall)]),
        child,
      ],
    );
  }
}
