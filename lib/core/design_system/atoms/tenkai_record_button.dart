import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

/// The big central control. Shows a calm glass orb with a mic glyph when
/// idle, and a pulsing red-tinted glass ring with a stop glyph while
/// recording.
///
/// This stays a hand-rolled widget rather than `cupertino_native`'s
/// `CNButton`: the package has no equivalent to an arbitrarily large,
/// continuously-pulsing custom surface like this, since its buttons are
/// fixed-chrome native platform views. It does give us `CNIcon` for a
/// pixel-perfect native SF Symbol glyph inside that surface, so we use that.
class RecordButton extends StatefulWidget {
  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.enabled = true,
  });

  final bool isRecording;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
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

  @override
  Widget build(BuildContext context) {
    final recording = widget.isRecording;

    // IMPORTANT: the pulsing ring is the only thing that needs to rebuild
    // every animation tick. The glass orb itself (with its BackdropFilter)
    // is built exactly once and passed into AnimatedBuilder as `child`, so
    // its expensive blur layer isn't torn down and recomposited ~60x/sec.
    // Rebuilding a BackdropFilter that fast — especially stacked with
    // another BackdropFilter behind it — is what triggers a
    // 'dart:ui/painting.dart ... is not true' crash on some renderers.
    final glassOrb = RepaintBoundary(
      child: CNButton.icon(
        tint: recording ? const Color(0xFFFF6B6B) : null,
        icon: CNSymbol(
          recording ? 'stop.fill' : 'mic.fill',
          // size: 56,
          color: recording ? const Color(0xFFD03A3A) : const Color(0xFF3D3D46),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: SizedBox(
        width: 250,
        height: 250,
        child: AnimatedBuilder(
          animation: _pulseController,
          child: glassOrb,
          builder: (context, child) {
            final pulse = recording ? _pulseController.value : 0.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                if (recording)
                  Container(
                    width: 220 + pulse * 30,
                    height: 220 + pulse * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFFFF5C5C,
                      ).withOpacity(0.25 - pulse * 0.15),
                    ),
                  ),
                child!,
              ],
            );
          },
        ),
      ),
    );
  }
}
