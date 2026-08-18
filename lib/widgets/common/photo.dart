import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/breakpoints.dart';

/// An asset photograph that fades in once decoded, over a warm neutral plate
/// so nothing ever flashes white.
class Photo extends StatelessWidget {
  const Photo(
    this.asset, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final String asset;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sand,
      child: Image.asset(
        asset,
        fit: fit,
        alignment: alignment,
        semanticLabel: semanticLabel,
        filterQuality: FilterQuality.medium,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || context.reduceMotion) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }
}

/// Clips its child and scales it gently on hover — the standard behaviour for
/// every project and feature image on the page.
class HoverZoom extends StatefulWidget {
  const HoverZoom({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.05,
    this.overlayOnHover = false,
    this.builder,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  /// Darkens the image slightly while hovered, so overlaid captions stay legible.
  final bool overlayOnHover;

  /// Optional wrapper that also receives the hover state (used for captions).
  final Widget Function(BuildContext context, bool hovered, Widget image)?
      builder;

  @override
  State<HoverZoom> createState() => _HoverZoomState();
}

class _HoverZoomState extends State<HoverZoom> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 700);

    Widget image = ClipRect(
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );

    if (widget.overlayOnHover) {
      image = Stack(
        fit: StackFit.passthrough,
        children: [
          image,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: duration,
                color: AppColors.slateDeep
                    .withValues(alpha: _hovered ? 0.22 : 0.0),
              ),
            ),
          ),
        ],
      );
    }

    final content =
        widget.builder?.call(context, _hovered, image) ?? image;

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}
