import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const asphalt    = Color(0xFF15171B);
  static const charcoal   = Color(0xFF1F2329);
  static const steel      = Color(0xFF2C3138);
  static const steelLine  = Color(0xFF33383F);
  static const steelLight = Color(0xFF8A8F98);
  static const amber      = Color(0xFFFF7A1A);
  static const amberDim   = Color(0xFF7A4521);
  static const teal       = Color(0xFF2BD9A6);
  static const bone       = Color(0xFFECE7DE);
  static const boneDim    = Color(0xFFB9B4AA);
  static const danger     = Color(0xFFE5484D);
  static const success    = Color(0xFF2BD9A6);
  static const white      = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.asphalt,
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.amber,
        secondary: AppColors.teal,
        surface:   AppColors.charcoal,
        error:     AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    AppColors.bone,
        displayColor: AppColors.bone,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.asphalt,
        foregroundColor: AppColors.bone,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.steelLine),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: const Color(0xFF1A1100),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bone,
          side: const BorderSide(color: AppColors.steelLine),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoal,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.steelLine)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.steelLine)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.steelLight),
        labelStyle: const TextStyle(color: AppColors.steelLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1B1E23),
        selectedItemColor: AppColors.amber,
        unselectedItemColor: AppColors.steelLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: AppColors.steelLine,
      iconTheme: const IconThemeData(color: AppColors.bone),
    );
  }
}
