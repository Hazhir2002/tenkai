import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';

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
    TenkaiSound.tap();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final recording = widget.isRecording;

    final glassOrb = AnimatedSwitcher(
      duration: TenkaiDuration.medium,
      child: CNButton.icon(
        key: Key(recording ? 'recording' : 'idle'),
        onPressed: widget.enabled ? _onTap : null,
        config: CNButtonConfig(width: 180, minHeight: 180),
        icon: CNSymbol(
          recording ? 'stop.fill' : 'mic.fill',
          size: 56,
          color: recording ? TenkaiColors.error : TenkaiColors.gray600,
        ),
      ),
    );

    return SizedBox(
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
                    color: TenkaiColors.error.withOpacity(0.25 - pulse * 0.15),
                  ),
                ),
              child!,
            ],
          );
        },
      ),
    );
  }
}
