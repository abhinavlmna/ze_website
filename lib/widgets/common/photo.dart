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

/// Intrinsic width÷height of asset photographs, resolved once and cached for
/// the life of the app.
///
/// The portfolio lays its tiles out from the photographs' own proportions
/// rather than forcing every frame into the same crop, which means the grid
/// needs the ratios *before* it can size anything. Decoding is asynchronous, so
/// callers render a sensible fallback until [ratioOf] starts returning a value.
class ImageRatios {
  ImageRatios._();

  static final Map<String, double> _cache = <String, double>{};
  static final Map<String, List<VoidCallback>> _waiting =
      <String, List<VoidCallback>>{};

  /// The decoded ratio, or null while it is still being resolved.
  static double? ratioOf(String asset) => _cache[asset];

  /// Kicks off decoding for [asset] unless it is already known or in flight.
  /// [onResolved] fires once, after the frame in which the ratio lands.
  ///
  /// Call from `initState`/`didUpdateWidget`, never from `build` — the image
  /// may already sit in Flutter's cache and resolve synchronously.
  static void resolve(String asset, VoidCallback onResolved) {
    if (_cache.containsKey(asset)) return;

    final waiters = _waiting[asset];
    if (waiters != null) {
      waiters.add(onResolved);
      return;
    }
    _waiting[asset] = <VoidCallback>[onResolved];

    final stream = AssetImage(asset).resolve(ImageConfiguration.empty);

    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        _cache[asset] = info.image.width / info.image.height;
        info.dispose();
        stream.removeListener(listener);
        _flush(asset);
      },
      onError: (Object _, StackTrace? __) {
        // A missing or corrupt file must not stall the grid — the tile falls
        // back to its default proportions and the broken-image plate shows.
        stream.removeListener(listener);
        _flush(asset);
      },
    );
    stream.addListener(listener);
  }

  static void _flush(String asset) {
    final waiters = _waiting.remove(asset);
    if (waiters == null || waiters.isEmpty) return;
    // Deferred by a frame so a synchronous resolve can never call setState
    // mid-build or mid-initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final waiter in waiters) {
        waiter();
      }
    });
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
