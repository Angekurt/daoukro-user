import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      // Titre d'écran
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      // Titre de section
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      // Titre de carte
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      // Corps
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      // Légende / méta
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
      ),

      // ── Boutons ────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Champs de saisie ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.textMuted),
      ),

      // ── Cartes ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── BottomSheet ────────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primaryLight,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500),
        side: const BorderSide(color: AppColors.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.whatsapp,
        foregroundColor: AppColors.white,
        elevation: 1,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.white),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.white54),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white12, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.white54),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.white12, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.white12,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDark,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.white),
        side: const BorderSide(color: AppColors.white12, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.whatsapp,
        foregroundColor: AppColors.white,
        elevation: 1,
      ),
    );
  }
}
