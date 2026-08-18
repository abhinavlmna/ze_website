import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();

  /// Mobile:  320 – 767
  /// Tablet:  768 – 1023
  /// Desktop: 1024+
  static const double tablet = 768;
  static const double desktop = 1024;

  /// Editorial measure — content never stretches past this.
  static const double contentMaxWidth = 1280;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceType get device {
    final w = screenWidth;
    if (w < Breakpoints.tablet) return DeviceType.mobile;
    if (w < Breakpoints.desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  bool get isMobile => device == DeviceType.mobile;
  bool get isTablet => device == DeviceType.tablet;
  bool get isDesktop => device == DeviceType.desktop;

  /// True when the visitor has asked the platform for reduced motion.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  T pick<T>({required T mobile, T? tablet, required T desktop}) {
    switch (device) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Horizontal page gutter.
  double get gutter => pick(mobile: 24.0, tablet: 44.0, desktop: 72.0);

  /// Vertical rhythm between major sections.
  double get sectionGap => pick(mobile: 84.0, tablet: 108.0, desktop: 150.0);

  /// Height of the sticky navigation bar.
  double get navHeight => pick(mobile: 68.0, tablet: 76.0, desktop: 92.0);
  double get navHeightCollapsed => pick(mobile: 60.0, tablet: 64.0, desktop: 70.0);
}

/// Smoothly interpolates a value between [min] at 360px wide and [max] at
/// 1440px wide, so typography and spacing scale rather than jump at
/// breakpoints.
double fluid(
  BuildContext context, {
  required double min,
  required double max,
  double from = 360,
  double to = 1440,
}) {
  final width = MediaQuery.sizeOf(context).width.clamp(from, to);
  final t = (width - from) / (to - from);
  return min + (max - min) * t;
}
