import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page gutter.
  static const double page = 20;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: page);

  /// Minimum interactive size (Material / WCAG guidance).
  static const double touchTarget = 48;
}

/// Radii follow hierarchy: hero panels are the roundest, chips the tightest.
class AppRadius {
  AppRadius._();
  static const double chip = 10;
  static const double field = 14;
  static const double card = 18;
  static const double panel = 28;
}
