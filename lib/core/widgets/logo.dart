import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final Color? color;
  final double? width;

  const Logo({super.key, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo-main',
      child: Image(
        image: const AssetImage('assets/images/logo.png'),
        colorBlendMode: BlendMode.srcIn,
        width: width ?? 100,
        // height: 115,
      ),
    );
  }
}
