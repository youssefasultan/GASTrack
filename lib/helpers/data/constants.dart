// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// enums
enum AuthMode { Admin, Login }

// colors
Color redColor = const Color.fromRGBO(250, 70, 22, 1);
Color blueColor = const Color.fromRGBO(0, 48, 135, 1);

final LinearGradient linerGradient = LinearGradient(
  colors: [
    blueColor.withOpacity(0.5),
    redColor.withOpacity(0.8),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: const [0, 1],
);

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {super.key, 
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

