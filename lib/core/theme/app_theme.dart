import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      secondary: AppColors.blush,
      onSecondary: AppColors.charcoal,
      surface: AppColors.parchment,
      onSurface: AppColors.charcoal,
      onSurfaceVariant: AppColors.taupe,
      outline: AppColors.outline,
      outlineVariant: AppColors.sand,
      error: const Color(0xFFB3261E),
    );

    return _theme(colorScheme, brightness: Brightness.light).copyWith(
      scaffoldBackgroundColor: AppColors.cream,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.clay,
      onPrimary: AppColors.espresso,
      secondary: const Color(0xFF4A3A34),
      onSecondary: const Color(0xFFF3EBE4),
      surface: AppColors.cocoa,
      onSurface: const Color(0xFFF3EBE4),
      onSurfaceVariant: const Color(0xFFB7A99F),
      outline: const Color(0xFF3D332E),
      outlineVariant: const Color(0xFF3D332E),
      error: const Color(0xFFE8A0A0),
    );

    return _theme(colorScheme, brightness: Brightness.dark).copyWith(
      scaffoldBackgroundColor: AppColors.espresso,
    );
  }

  static ThemeData _theme(ColorScheme colorScheme, {required Brightness brightness}) {
    final display = GoogleFonts.frauncesTextTheme();
    final body = GoogleFonts.outfitTextTheme();

    final textTheme = body
        .copyWith(
          displayLarge: display.displayLarge,
          displayMedium: display.displayMedium,
          displaySmall: display.displaySmall,
          headlineLarge: display.headlineLarge,
          headlineMedium: display.headlineMedium,
          headlineSmall: display.headlineSmall,
          titleLarge: display.titleLarge,
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.55),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return body.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.2,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: body.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.secondary.withValues(alpha: 0.65),
        backgroundColor: colorScheme.surface,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: body.labelLarge,
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.7),
        space: 1,
      ),
    );
  }
}
