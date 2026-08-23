import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'breakpoints.dart';

/// Type system: an elegant serif (Cormorant Garamond) carries the statements,
/// a geometric sans (Jost — echoing the logo wordmark) carries everything the
/// reader has to *use*: navigation, labels, buttons and body copy.
class AppText {
  AppText._();

  static const String serif = 'Cormorant';
  static const String sans = 'Jost';

  // ---- Display / headings --------------------------------------------------

  /// Hero statement.
  static TextStyle display(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontSize: fluid(c, min: 44, max: 92),
        fontWeight: FontWeight.w300,
        height: 1.04,
        letterSpacing: -0.5,
        color: color ?? AppColors.textPrimary,
      );

  /// Section headings.
  static TextStyle h2(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontSize: fluid(c, min: 32, max: 58),
        fontWeight: FontWeight.w300,
        height: 1.12,
        letterSpacing: -0.2,
        color: color ?? AppColors.textPrimary,
      );

  /// Large pull-quote / philosophy statement.
  static TextStyle statement(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontSize: fluid(c, min: 29, max: 56),
        fontWeight: FontWeight.w300,
        height: 1.22,
        letterSpacing: -0.2,
        color: color ?? AppColors.textOnDark,
      );

  static TextStyle h3(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontSize: fluid(c, min: 22, max: 30),
        fontWeight: FontWeight.w400,
        height: 1.25,
        color: color ?? AppColors.textPrimary,
      );

  // ---- Sans ----------------------------------------------------------------

  /// Small uppercase eyebrow above a heading.
  static TextStyle eyebrow(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 10.5, max: 12),
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 3.2,
        color: color ?? AppColors.teal,
      );

  /// Hero carousel caption. A step up from [eyebrow] so a single line of copy
  /// still holds its own across a full-bleed photograph.
  static TextStyle slideCaption(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 13, max: 18),
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 2.6,
        color: color ?? AppColors.textOnDark,
      );

  /// The hero's lead paragraph. Deliberately not [body]: that style is tuned
  /// for dark type on paper, and its 300 weight goes thin and washed out set in
  /// white over a photograph. A step up in weight and size, with slightly
  /// tighter leading to stop the larger type running away with the height.
  static TextStyle heroLead(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 15.5, max: 18.5),
        fontWeight: FontWeight.w400,
        height: 1.75,
        letterSpacing: 0.2,
        color: color ?? AppColors.textOnDark,
      );

  /// Caption beneath a process badge — small, quiet, and set tight enough to
  /// stay readable at three or four words per line.
  static TextStyle processStep(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 10.5, max: 15.5),
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.3,
        color: color ?? AppColors.textOnDark,
      );

  static TextStyle body(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 15, max: 17),
        fontWeight: FontWeight.w300,
        height: 1.85,
        letterSpacing: 0.15,
        color: color ?? AppColors.textMuted,
      );

  static TextStyle bodySmall(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 13.5, max: 15),
        fontWeight: FontWeight.w300,
        height: 1.8,
        letterSpacing: 0.15,
        color: color ?? AppColors.textMuted,
      );

  /// Buttons and navigation.
  static TextStyle action(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 12, max: 13),
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.8,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle navItem(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: sans,
        fontSize: fluid(c, min: 12.5, max: 13.5),
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 1.5,
        color: color ?? AppColors.textPrimary,
      );

  /// Oversized index numerals (01 – 04) in the services grid.
  static TextStyle numeral(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontSize: fluid(c, min: 34, max: 46),
        fontWeight: FontWeight.w300,
        height: 1,
        color: color ?? AppColors.border,
      );

  /// Wordmark lockup.
  static TextStyle wordmark(BuildContext c, {Color? color, double? size}) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size ?? fluid(c, min: 14, max: 17),
        fontWeight: FontWeight.w500,
        height: 1.05,
        letterSpacing: 2.4,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle wordmarkSub(BuildContext c, {Color? color, double? size}) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size ?? fluid(c, min: 7.5, max: 8.5),
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 2.6,
        color: color ?? AppColors.textMuted,
      );
}
