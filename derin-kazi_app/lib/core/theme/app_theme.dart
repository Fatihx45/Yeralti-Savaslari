import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.lavaOrange,
      textTheme: GoogleFonts.rubikTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).apply(
        bodyColor: AppColors.primaryText,
        displayColor: AppColors.primaryText,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.lavaOrange,
        secondary: AppColors.goldText,
        surface: AppColors.hudPanel,
      ),
    );
  }

  static TextStyle get retroHeading => GoogleFonts.pressStart2p(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle get retroSmall => GoogleFonts.pressStart2p(
    fontSize: 9,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );
}
