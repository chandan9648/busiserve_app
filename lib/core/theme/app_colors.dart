import 'package:flutter/material.dart';

/// Colours sampled from the official Busiserve logo: the navy hexagon, the
/// electric-blue circuit traces and the orange growth arrow.
class AppColors {
  AppColors._();

  // Brand
  static const Color ink = Color(0xFF0A1F66); // hexagon navy
  static const Color inkDeep = Color(0xFF061445);
  static const Color blue = Color(0xFF1477E0); // circuit blue
  static const Color sky = Color(0xFF38A8F5);
  static const Color flame = Color(0xFFF24E12); // arrow base
  static const Color amber = Color(0xFFFFA21A); // arrow tip

  // Light surfaces
  static const Color background = Color(0xFFF3F6FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFDCE3F1);
  static const Color text = Color(0xFF0B1533);
  static const Color textMuted = Color(0xFF55627F);

  // Dark surfaces (navy, never neutral black)
  static const Color backgroundDark = Color(0xFF050D2A);
  static const Color surfaceDark = Color(0xFF0D1B47);
  static const Color lineDark = Color(0xFF1E2F66);
  static const Color textDark = Color(0xFFEAF0FF);
  static const Color textMutedDark = Color(0xFFA2B0D4);

  // Semantic
  static const Color success = Color(0xFF138A5E);
  static const Color warning = Color(0xFFB86E00);
  static const Color danger = Color(0xFFC62F2F);

  static const LinearGradient arrow = LinearGradient(
    colors: [flame, amber],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient circuit = LinearGradient(
    colors: [blue, sky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hero = LinearGradient(
    colors: [inkDeep, ink, Color(0xFF12348F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
