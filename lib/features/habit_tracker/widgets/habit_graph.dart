import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';

/// Visual styling for a graph node derived from its [HabitDayState] and status.
class _NodeStyle {
  const _NodeStyle({
    required this.color,
    required this.glowing,
    required this.size,
    required this.badgeLabel,
    required this.badgeVariant,
  });

  final Color color;
  final bool glowing;
  final double size;
  final String? badgeLabel;
  final TenkaiBadgeVariant badgeVariant;

  factory _NodeStyle.of(HabitView v, TenkaiSemanticColors c) {
    switch (v.dayState) {
      case HabitDayState.doneToday:
        return const _NodeStyle(
          color: TenkaiColors.success,
          glowing: true,
          size: 18,
          badgeLabel: 'Done',
          badgeVariant: TenkaiBadgeVariant.success,
        );
      case HabitDayState.next:
        return _NodeStyle(
          color: c.foreground,
          glowing: true,
          size: 24,
          badgeLabel: 'Next',
          badgeVariant: TenkaiBadgeVariant.active,
        );
      case HabitDayState.pendingToday:
        return _NodeStyle(
          color: c.foreground,
          glowing: true,
          size: 18,
          badgeLabel: 'Pending',
          badgeVariant: TenkaiBadgeVariant.neutral,
        );
      case HabitDayState.notScheduledToday:
        return _NodeStyle(
          color: c.mutedForeground,
          glowing: false,
          size: 16,
          badgeLabel: null,
          badgeVariant: TenkaiBadgeVariant.neutral,
        );
      case HabitDayState.building:
        return _NodeStyle(
          color: c.mutedForeground,
          glowing: true,
          size: 16,
          badgeLabel: 'Building',
          badgeVariant: TenkaiBadgeVariant.neutral,
        );
      case HabitDayState.planned:
        return _NodeStyle(
          color: c.border,
          glowing: false,
          size: 14,
          badgeLabel: 'Planned',
          badgeVariant: TenkaiBadgeVariant.neutral,
        );
    }
  }
}

/// Renders the habit forest as vertical stacking chains — glowing nodes joined
/// by cue edges. Roots are time-cued/unanchored habits; children hang off their
/// cue habit, indented and connected by a vertical guide line.
class HabitGraph extends StatelessWidget {
  const HabitGraph({super.key, required this.roots, required this.onTap});

  final List<HabitView> roots;
  final void Function(HabitView) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final root in roots) _ChainBranch(view: root, onTap: onTap),
      ],
    );
  }
}

class _ChainBranch extends StatelessWidget {
  const _ChainBranch({required this.view, required this.onTap});

  final HabitView view;
  final void Function(HabitView) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NodeRow(view: view, onTap: onTap),
        if (view.children.isNotEmpty)
          Container(
            // Vertical guide line running down the stacked children, aligned
            // roughly under the parent node's centre.
            margin: const EdgeInsets.only(left: 13),
            padding: const EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.tenkai.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in view.children)
                  _ChainBranch(view: child, onTap: onTap),
              ],
            ),
          ),
      ],
    );
  }
}

class _NodeRow extends StatelessWidget {
  const _NodeRow({required this.view, required this.onTap});

  final HabitView view;
  final void Function(HabitView) onTap;

  @override
  Widget build(BuildContext context) {
    final style = _NodeStyle.of(view, context.tenkai);
    final dimmed = view.dayState == HabitDayState.planned;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: TenkaiNode(
                size: style.size,
                color: style.color,
                glowing: style.glowing,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Opacity(
              opacity: dimmed ? 0.6 : 1.0,
              child: Card(
                // interactive: true,
                // onTap: () => onTap(view),
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 16,
                //   vertical: 14,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            view.habit.title,
                            style: TenkaiTypography.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (style.badgeLabel != null) ...[
                          const SizedBox(width: 8),
                          TenkaiBadge(
                            label: style.badgeLabel!,
                            variant: style.badgeVariant,
                            dot: view.dayState == HabitDayState.next,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      view.cueDescription(),
                      style: TenkaiTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
