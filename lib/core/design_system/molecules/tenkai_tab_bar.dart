import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';

/// One item in a [TenkaiTabBar].
class TenkaiTabBarItem {
  const TenkaiTabBarItem({required this.icon, required this.label});
  final Widget icon;
  final String label;
}

/// A flat bottom tab bar: icon over a small uppercase-ish label, active tab in
/// `--fg`, others in `--fg-subtle`, a hairline top border. Provided as a design
/// component; the app shell itself uses the native `CNTabBar`.
class TenkaiTabBar extends StatelessWidget {
  const TenkaiTabBar({
    super.key,
    required this.items,
    required this.active,
    required this.onChanged,
  });

  final List<TenkaiTabBarItem> items;
  final int active;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _tab(context, c, i, items[i]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    TenkaiSemanticColors c,
    int i,
    TenkaiTabBarItem item,
  ) {
    final selected = i == active;
    final color = selected ? c.foreground : c.secondaryForeground;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        TenkaiSound.nav();
        onChanged(i);
      },
      child: AnimatedDefaultTextStyle(
        duration: TenkaiDuration.medium,
        style: TenkaiTypography.labelSm.copyWith(
          letterSpacing: 0,
          color: color,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: IconTheme.merge(
                data: IconThemeData(color: color, size: 18),
                child: item.icon,
              ),
            ),
            const SizedBox(height: 3),
            Text(item.label),
          ],
        ),
      ),
    );
  }
}
