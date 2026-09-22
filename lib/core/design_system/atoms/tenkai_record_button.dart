import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import '../sounds/tenkai_sound.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// Voice-capture button — a flat bordered circle, not a glass orb. Mic glyph at
/// rest; a red rounded-square "stop" plus a pulsing ring while recording.
class TenkaiRecordButton extends StatefulWidget {
  const TenkaiRecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.enabled = true,
  });

  final bool isRecording;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<TenkaiRecordButton> createState() => _TenkaiRecordButtonState();
}

class _TenkaiRecordButtonState extends State<TenkaiRecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled) return;
    TenkaiSound.tap();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final recording = widget.isRecording;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring — recording only.
          if (recording)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                // tk-pulse: scale 1 → 1.06, opacity .9 → .5.
                final t = Curves.easeInOut.transform(_pulseController.value);
                final scale = 1 + 0.06 * t;
                final opacity = 0.9 - 0.4 * t;
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.destructive,
                        border: Border.all(color: c.border, width: 1),
                      ),
                    ),
                  ),
                );
              },
            ),
          // The flat bordered circle.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: AnimatedContainer(
              duration: TenkaiDuration.medium,
              curve: TenkaiCurves.spring,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recording ? c.destructive : c.card,
                border: Border.all(
                  color: recording ? c.destructive : c.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: recording
                    ? Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: c.destructive,
                          borderRadius: BorderRadius.circular(
                            TenkaiRadius.check,
                          ),
                        ),
                      )
                    : CNIcon(
                        symbol: CNSymbol(
                          'mic.fill',
                          size: 32,
                          color: c.mutedForeground,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
