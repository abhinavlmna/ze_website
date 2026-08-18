import 'package:flutter/material.dart';

/// Palette derived directly from the Ze Space Interior logo.
///
/// The logo is built from three inks: a teal wordmark/mark, a deep slate
/// geometric form and a single coral parallelogram. The site keeps that
/// restraint — slate and warm neutrals carry the page, teal carries the brand,
/// coral is used sparingly as a single point of emphasis.
class AppColors {
  AppColors._();

  // ---- Primary brand -------------------------------------------------------
  static const Color teal = Color(0xFF2E9B93);
  static const Color tealDeep = Color(0xFF1E6F69);
  static const Color tealWash = Color(0xFFE7F1EF);

  // ---- Secondary / structural ---------------------------------------------
  static const Color slate = Color(0xFF3D4756);
  static const Color slateDeep = Color(0xFF232C38);

  // ---- Accent (used sparingly) --------------------------------------------
  static const Color coral = Color(0xFFE04A48);

  // ---- Neutrals ------------------------------------------------------------
  static const Color canvas = Color(0xFFFBFAF8);
  static const Color sand = Color(0xFFF2EFEA);
  static const Color surface = Color(0xFFFFFFFF);

  // ---- Type ----------------------------------------------------------------
  static const Color textPrimary = Color(0xFF232C38);
  static const Color textMuted = Color(0xFF7A8590);
  static const Color textOnDark = Color(0xFFF7F6F3);
  static const Color textOnDarkMuted = Color(0xFFB3BCC5);

  // ---- Lines ---------------------------------------------------------------
  static const Color border = Color(0xFFE3DFD8);
  static const Color borderOnDark = Color(0x33FFFFFF);
}
