import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.headlineSmall,
  );
}
