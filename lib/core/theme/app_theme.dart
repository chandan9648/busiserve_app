import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'brand_tokens.dart';

/// Sora (geometric, matches the logo's heavy caps) for headings,
/// Manrope for body text.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.sky : AppColors.ink,
      onPrimary: isDark ? AppColors.inkDeep : Colors.white,
      primaryContainer: isDark ? const Color(0xFF16307A) : const Color(0xFFDCE6FF),
      onPrimaryContainer: isDark ? AppColors.textDark : AppColors.ink,
      secondary: AppColors.flame,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF4A2410) : const Color(0xFFFFE7D9),
      onSecondaryContainer: isDark ? const Color(0xFFFFD2B8) : const Color(0xFF7A2600),
      tertiary: AppColors.blue,
      onTertiary: Colors.white,
      error: isDark ? const Color(0xFFFF7070) : AppColors.danger,
      onError: Colors.white,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.textDark : AppColors.text,
      onSurfaceVariant: isDark ? AppColors.textMutedDark : AppColors.textMuted,
      outline: isDark ? AppColors.lineDark : AppColors.line,
      outlineVariant: isDark ? AppColors.lineDark : AppColors.line,
      surfaceContainerHighest: isDark ? const Color(0xFF15275E) : const Color(0xFFE8EEF9),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    final body = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    TextStyle? sora(TextStyle? s, double size, FontWeight w, {double ls = -0.3, double h = 1.15}) =>
        GoogleFonts.sora(textStyle: s, fontSize: size, fontWeight: w, letterSpacing: ls, height: h);

    final textTheme = body.copyWith(
      displaySmall: sora(body.displaySmall, 34, FontWeight.w700, ls: -0.8, h: 1.08),
      headlineMedium: sora(body.headlineMedium, 28, FontWeight.w700, ls: -0.6, h: 1.12),
      headlineSmall: sora(body.headlineSmall, 22, FontWeight.w700, ls: -0.4),
      titleLarge: sora(body.titleLarge, 19, FontWeight.w600),
      titleMedium: sora(body.titleMedium, 16, FontWeight.w600, ls: -0.1, h: 1.3),
      titleSmall: GoogleFonts.manrope(textStyle: body.titleSmall, fontSize: 14, fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.manrope(textStyle: body.bodyLarge, fontSize: 16, height: 1.55),
      bodyMedium: GoogleFonts.manrope(textStyle: body.bodyMedium, fontSize: 14.5, height: 1.5),
      bodySmall: GoogleFonts.manrope(
        textStyle: body.bodySmall,
        fontSize: 12.5,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(textStyle: body.labelLarge, fontSize: 15, fontWeight: FontWeight.w700),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: scheme.outline),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      textTheme: textTheme,
      extensions: [isDark ? BrandTokens.dark : BrandTokens.light],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: isDark ? AppColors.sky : AppColors.blue, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: scheme.error, width: 2)),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.sky : AppColors.blue,
          fontWeight: FontWeight.w600,
        ),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.touchTarget + 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.touchTarget + 4),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.45), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
          foregroundColor: isDark ? AppColors.sky : AppColors.blue,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
        side: BorderSide(color: scheme.outline),
        labelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF1C3786) : const Color(0xFFE2EAFF),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
