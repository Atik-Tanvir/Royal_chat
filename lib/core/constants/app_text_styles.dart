import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headerLarge => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
      );

  static TextStyle get headerMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
      );

  static TextStyle get titleBold => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite70,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textWhite70,
      );

  static TextStyle get statNumber => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get goldAmount => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textWhite,
      );

  static TextStyle get gameScore => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.textWhite,
        letterSpacing: 1.5,
      );
}
