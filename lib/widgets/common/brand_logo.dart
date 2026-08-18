import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text.dart';

/// Set to `true` after dropping the supplied artwork at
/// `assets/logo/logo.png` (and uncommenting the asset entry in pubspec.yaml).
/// Until then the lockup below is drawn in code from the logo's own geometry
/// and colours, so nothing on the page is a placeholder rectangle.
const bool kUseLogoAsset = false;

/// The wordmark lockup: geometric mark + "ZE SPACE / INTERIOR".
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.onDark = false,
    this.markHeight = 30,
    this.textSize = 15.5,
    this.showWordmark = true,
  });

  final bool onDark;
  final double markHeight;
  final double textSize;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    if (kUseLogoAsset) {
      return Image.asset(
        'assets/logo/logo.png',
        height: markHeight * 1.35,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Ze Space Interior',
      );
    }

    final wordColor = onDark ? AppColors.textOnDark : AppColors.teal;

    return Semantics(
      label: 'Ze Space Interior',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(markHeight * 1.18, markHeight),
            painter: _BrandMarkPainter(onDark: onDark),
          ),
          if (showWordmark) ...[
            SizedBox(width: markHeight * 0.42),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZE SPACE',
                  style: AppText.wordmark(
                    context,
                    color: wordColor,
                    size: textSize,
                  ),
                ),
                SizedBox(height: textSize * 0.14),
                Text(
                  'INTERIOR',
                  style: AppText.wordmark(
                    context,
                    color: wordColor,
                    size: textSize,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A "Z" built from two sheared planes — teal above, slate below — with a
/// single coral bar cutting through the gap between them. Same geometry family
/// and same three inks as the Ze Space mark.
class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({required this.onDark});

  final bool onDark;

  /// A parallelogram given as fractions of the mark's box.
  Path _plane(
    Size size,
    double x0,
    double x1,
    double y0,
    double y1,
    double shear,
  ) {
    final w = size.width;
    final h = size.height;
    final s = w * shear;
    return Path()
      ..moveTo(w * x0, h * y1)
      ..lineTo(w * x0 + s, h * y0)
      ..lineTo(w * x1 + s, h * y0)
      ..lineTo(w * x1, h * y1)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Upper bar.
    canvas.drawPath(
      _plane(size, 0.14, 0.84, 0.0, 0.44, 0.16),
      paint..color = AppColors.teal,
    );
    // Lower bar, mirrored.
    canvas.drawPath(
      _plane(size, 0.0, 0.70, 0.56, 1.0, 0.16),
      paint
        ..color = onDark ? const Color(0xFFD5DAE0) : AppColors.slate,
    );
    // Accent cutting through the middle.
    canvas.drawPath(
      _plane(size, 0.40, 0.53, 0.22, 0.78, 0.16),
      paint..color = AppColors.coral,
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) =>
      oldDelegate.onDark != onDark;
}
