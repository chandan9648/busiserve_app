import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme extension for brand values that Material's ColorScheme lacks.
@immutable
class BrandTokens extends ThemeExtension<BrandTokens> {
  const BrandTokens({
    required this.muted,
    required this.line,
    required this.card,
    required this.success,
    required this.warning,
    required this.danger,
    required this.heroGradient,
    required this.actionGradient,
  });

  final Color muted;
  final Color line;
  final Color card;
  final Color success;
  final Color warning;
  final Color danger;
  final Gradient heroGradient;
  final Gradient actionGradient;

  static const light = BrandTokens(
    muted: AppColors.textMuted,
    line: AppColors.line,
    card: AppColors.surface,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    heroGradient: AppColors.hero,
    actionGradient: AppColors.arrow,
  );

  static const dark = BrandTokens(
    muted: AppColors.textMutedDark,
    line: AppColors.lineDark,
    card: AppColors.surfaceDark,
    success: Color(0xFF3CCB91),
    warning: Color(0xFFFFB84D),
    danger: Color(0xFFFF7070),
    heroGradient: AppColors.hero,
    actionGradient: AppColors.arrow,
  );

  @override
  BrandTokens copyWith({
    Color? muted,
    Color? line,
    Color? card,
    Color? success,
    Color? warning,
    Color? danger,
    Gradient? heroGradient,
    Gradient? actionGradient,
  }) =>
      BrandTokens(
        muted: muted ?? this.muted,
        line: line ?? this.line,
        card: card ?? this.card,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        heroGradient: heroGradient ?? this.heroGradient,
        actionGradient: actionGradient ?? this.actionGradient,
      );

  @override
  BrandTokens lerp(ThemeExtension<BrandTokens>? other, double t) {
    if (other is! BrandTokens) return this;
    return BrandTokens(
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      card: Color.lerp(card, other.card, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      actionGradient: t < 0.5 ? actionGradient : other.actionGradient,
    );
  }
}

extension BrandTokensX on BuildContext {
  BrandTokens get brand => Theme.of(this).extension<BrandTokens>() ?? BrandTokens.light;
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}
