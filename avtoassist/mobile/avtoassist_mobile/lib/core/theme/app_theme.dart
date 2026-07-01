import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const asphalt    = Color(0xFF111317);
  static const asphalt2   = Color(0xFF0C0E11);
  static const charcoal   = Color(0xFF1B1F25);
  static const charcoal2  = Color(0xFF232830);
  static const steel      = Color(0xFF2C3138);
  static const steelLine  = Color(0xFF323840);
  static const steelLight = Color(0xFF8A8F98);
  static const amber      = Color(0xFFFF7A1A);
  static const amberLight = Color(0xFFFF9B4D);
  static const amberDim   = Color(0xFF7A4521);
  static const teal       = Color(0xFF2BD9A6);
  static const tealLight  = Color(0xFF54E8BC);
  static const bone       = Color(0xFFECE7DE);
  static const boneDim    = Color(0xFFB9B4AA);
  static const danger     = Color(0xFFE5484D);
  static const success    = Color(0xFF2BD9A6);
  static const white      = Color(0xFFFFFFFF);

  // Gradientlar
  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9B4D), Color(0xFFFF6A00)],
  );
  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF54E8BC), Color(0xFF1FC793)],
  );
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF20252C), Color(0xFF181C22)],
  );

  // Soyalar
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
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
      ).copyWith(
        headlineSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.bone),
        titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppColors.bone),
        titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: AppColors.bone),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.asphalt,
        foregroundColor: AppColors.bone,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            letterSpacing: -0.3, color: AppColors.bone),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.steelLine),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: const Color(0xFF1A1100),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bone,
          side: const BorderSide(color: AppColors.steelLine),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.steelLine)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.steelLine)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.amber, width: 1.6)),
        hintStyle: const TextStyle(color: AppColors.steelLight),
        labelStyle: const TextStyle(color: AppColors.steelLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.charcoal,
        side: const BorderSide(color: AppColors.steelLine),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(color: AppColors.boneDim, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bone),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal2,
        contentTextStyle: const TextStyle(color: AppColors.bone),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF15181D),
        selectedItemColor: AppColors.amber,
        unselectedItemColor: AppColors.steelLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      dividerColor: AppColors.steelLine,
      iconTheme: const IconThemeData(color: AppColors.bone),
    );
  }
}
