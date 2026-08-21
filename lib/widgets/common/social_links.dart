import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/breakpoints.dart';
import '../../constants/contact_config.dart';

enum SocialNetwork { facebook, instagram }

/// The two social marks, drawn rather than shipped as assets.
///
/// Material has no Instagram glyph and its Facebook one is a solid badge, so
/// both are painted here at the same hairline weight the rest of the page uses.
/// Square outline, teal fill on hover — the same behaviour as the WhatsApp pill
/// in the navigation bar.
class SocialLinks extends StatelessWidget {
  const SocialLinks({
    super.key,
    this.onDark = false,
    this.alignment = WrapAlignment.start,
  });

  /// Placed over slate — borders and marks lighten to stay legible.
  final bool onDark;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    // Wrap rather than Row: in the narrow footer column on a small phone the
    // pair drops to a second line instead of overflowing.
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: alignment,
      children: [
        _SocialButton(
          network: SocialNetwork.facebook,
          label: 'Facebook',
          onDark: onDark,
        ),
        _SocialButton(
          network: SocialNetwork.instagram,
          label: 'Instagram',
          onDark: onDark,
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.network,
    required this.label,
    this.onDark = false,
  });

  final SocialNetwork network;
  final String label;
  final bool onDark;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  void _open() {
    switch (widget.network) {
      case SocialNetwork.facebook:
        LinkLauncher.facebook();
      case SocialNetwork.instagram:
        LinkLauncher.instagram();
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    final idleBorder =
        widget.onDark ? AppColors.borderOnDark : AppColors.border;
    final idleMark =
        widget.onDark ? AppColors.textOnDarkMuted : AppColors.textPrimary;

    // 44×44 keeps the touch target at the accessible minimum on phones.
    return Semantics(
      button: true,
      link: true,
      label: 'Ze Space Interior on ${widget.label}',
      child: Tooltip(
        message: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _open,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hovered ? AppColors.teal : const Color(0x00000000),
                border: Border.all(
                  color: _hovered ? AppColors.teal : idleBorder,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size.square(21),
                  painter: _SocialMarkPainter(
                    network: widget.network,
                    color: _hovered ? AppColors.textOnDark : idleMark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Both marks are authored on a 24×24 grid and scaled to the painted size, so
/// the stroke weight stays identical between them at any icon size.
class _SocialMarkPainter extends CustomPainter {
  const _SocialMarkPainter({required this.network, required this.color});

  final SocialNetwork network;
  final Color color;

  static const double _grid = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _grid;
    canvas.save();
    canvas.scale(scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final frame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.6, 2.6, 18.8, 18.8),
      Radius.circular(network == SocialNetwork.instagram ? 6 : 5),
    );
    canvas.drawRRect(frame, stroke);

    switch (network) {
      case SocialNetwork.facebook:
        // The lowercase "f": a stem that hooks right at the top, crossed by a
        // bar at mid height.
        final f = Path()
          ..moveTo(12.7, 19.4)
          ..lineTo(12.7, 9.9)
          ..cubicTo(12.7, 7.7, 13.9, 6.6, 15.9, 6.6)
          ..lineTo(16.8, 6.6)
          ..moveTo(9.6, 12.5)
          ..lineTo(16.3, 12.5);
        canvas.drawPath(f, stroke);
      case SocialNetwork.instagram:
        canvas.drawCircle(const Offset(12, 12), 4.2, stroke);
        canvas.drawCircle(
          const Offset(16.9, 7.1),
          1.15,
          Paint()..color = color,
        );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SocialMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.network != network;
}
