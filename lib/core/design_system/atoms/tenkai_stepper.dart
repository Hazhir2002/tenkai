import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// A vertical stepper — "one step at a time" made structural. Completed steps
/// show an accent check, the current step glows (the one sanctioned bloom), and
/// the connector fills to accent as steps complete.
class TenkaiStepper extends StatelessWidget {
  const TenkaiStepper({super.key, required this.steps, this.current = 0});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < steps.length; i++) _step(context, c, i)],
    );
  }

  Widget _step(BuildContext context, TenkaiSemanticColors c, int i) {
    final done = i < current;
    final active = i == current;
    final isLast = i == steps.length - 1;
    final marked = done || active;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: TenkaiDuration.medium,
                curve: TenkaiCurves.spring,
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: marked ? c.accent : c.card,
                  border: Border.all(
                    color: marked ? c.accent : c.border,
                    width: 1,
                  ),
                  boxShadow: active ? TenkaiGlow.accentOf(c.accent) : null,
                ),
                child: done
                    ? Icon(Icons.check, size: 10, color: c.accentForeground)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    constraints: const BoxConstraints(minHeight: 26),
                    color: done ? c.accent : c.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 0),
            child: Text(
              steps[i],
              style: TenkaiTypography.bodySmall.copyWith(
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                color: active
                    ? c.foreground
                    : done
                    ? c.mutedForeground
                    : c.secondaryForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
