import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// A flat modal dialog card: display-face title, optional description/content,
/// and a trailing actions row. Scales in over a dimmed barrier.
class TenkaiDialog extends StatelessWidget {
  const TenkaiDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    this.actions,
  });

  final String title;
  final String? description;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(TenkaiRadius.sheet),
                border: Border.all(color: c.border, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: TenkaiTypography.titleMd.copyWith(
                      fontSize: 19,
                      color: c.foreground,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: TenkaiTypography.bodyMd.copyWith(
                        color: c.mutedForeground,
                      ),
                    ),
                  ],
                  if (content != null) ...[
                    const SizedBox(height: 14),
                    content!,
                  ],
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions!.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          actions![i],
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Show a [TenkaiDialog] with the Tenkai scale-in transition.
Future<T?> showTenkaiDialog<T>({
  required BuildContext context,
  required String title,
  String? description,
  Widget? content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: TenkaiDuration.slow,
    pageBuilder: (_, __, ___) => TenkaiDialog(
      title: title,
      description: description,
      content: content,
      actions: actions,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: TenkaiCurves.spring,
        reverseCurve: TenkaiCurves.easeOut,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
