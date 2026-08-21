import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import '../data/hero_slides.dart';
import 'common/buttons.dart';
import 'hero_carousel.dart';
import 'hero_process.dart';

/// Full-bleed opening statement: a swipeable pair of photographs, each carrying
/// its own promise, over one headline and two ways in.
class HeroSection extends StatefulWidget {
  const HeroSection({
    super.key,
    required this.onExploreWork,
    required this.onGetInTouch,
  });

  final VoidCallback onExploreWork;
  final VoidCallback onGetInTouch;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  final PageController _pages = PageController();

  /// The live, fractional page position. Published separately from the
  /// controller so the photographs, the caption and the indicator can all track
  /// a swipe as it happens rather than snapping once the page settles.
  final ValueNotifier<double> _page = ValueNotifier<double>(0);

  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pages.addListener(_syncPage);
  }

  void _syncPage() {
    if (!_pages.hasClients || !_pages.position.hasContentDimensions) return;
    _page.value = _pages.page ?? _page.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Decode every slide up front. A PageView only builds the page you can see,
    // so without this the second photograph starts loading at the instant it is
    // swiped in — and the swipe lands on an empty plate.
    for (final slide in kHeroSlides) {
      precacheImage(AssetImage(slide.image), context);
    }

    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _pages.removeListener(_syncPage);
    _pages.dispose();
    _page.dispose();
    _entrance.dispose();
    super.dispose();
  }

  double _step(double start, double end) {
    return Curves.easeOutCubic.transform(
      ((_entrance.value - start) / (end - start)).clamp(0.0, 1.0),
    );
  }

  Widget _rise(double start, double end, Widget child, {double distance = 26}) {
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, inner) {
        final t = _step(start, end);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * distance),
            child: inner,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = math.max(
      math.min(context.screenHeight, 1000.0),
      context.isMobile ? 600.0 : 640.0,
    );

    // A minimum rather than a fixed height: on short or zoomed-in viewports the
    // hero grows with its content instead of clipping it.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: HeroCarousel(
              controller: _pages,
              page: _page,
              entrance: _entrance,
            ),
          ),
          const Positioned.fill(child: _HeroScrim()),
          _HeroContent(
            rise: _rise,
            page: _page,
            onExploreWork: widget.onExploreWork,
            onGetInTouch: widget.onGetInTouch,
          ),
          // Pinned to the frame rather than sitting in the column: the hero
          // copy is already taller than a laptop viewport, and the calls to
          // action must not be pushed any further down.
          Positioned(
            left: 0,
            right: 0,
            bottom: context.isMobile ? 20 : 44,
            child: _rise(
              0.5,
              0.9,
              Center(
                child: HeroSlideIndicator(controller: _pages, page: _page),
              ),
            ),
          ),
          if (!context.isMobile)
            Positioned(
              right: context.gutter,
              bottom: 44,
              // Decorative: never intercept a swipe meant for the carousel.
              child: IgnorePointer(child: _rise(0.75, 1.0, const _ScrollCue())),
            ),
        ],
      ),
    );
  }
}

class _HeroScrim extends StatelessWidget {
  const _HeroScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Diagonal scrim: darkest under the headline, clearing towards the
          // top-right so the photograph still reads as a photograph.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.slateDeep.withValues(alpha: 0.80),
                  AppColors.slateDeep.withValues(alpha: 0.44),
                  AppColors.slateDeep.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
          // Separate top wash so the transparent navigation stays legible over
          // a bright ceiling or window.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.slateDeep.withValues(alpha: 0.55),
                  AppColors.slateDeep.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.22],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.rise,
    required this.page,
    required this.onExploreWork,
    required this.onGetInTouch,
  });

  final Widget Function(double start, double end, Widget child,
      {double distance}) rise;
  final ValueListenable<double> page;
  final VoidCallback onExploreWork;
  final VoidCallback onGetInTouch;

  @override
  Widget build(BuildContext context) {
    final gutter = context.gutter;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Breakpoints.contentMaxWidth + gutter * 2,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: gutter,
            right: gutter,
            top: context.navHeight + 24,
            bottom: context.pick(mobile: 72.0, tablet: 84.0, desktop: 104.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [

                rise(0.05, 0.35, HeroSlideCaption(page: page)),
                SizedBox(height: context.isMobile ? 22 : 30),
                rise(
                  0.12,
                  0.5,
                  HeroSlideSwap(
                    page: page,
                    builder: (context, index) => index == 0
                        ? const IgnorePointer(child: _Headline())
                        : const HeroProcess(),
                  ),
                  distance: 34,
                ),
                SizedBox(height: context.isMobile ? 24 : 32),
                rise(
                  0.24,
                  0.62,
                  IgnorePointer(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        'Thoughtfully designed interiors and precisely crafted '
                        'furniture, created around the way you live and work.',
                        style: AppText.body(
                          context,
                          color: AppColors.textOnDark.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.isMobile ? 32 : 44),
                rise(
                  0.36,
                  0.75,
                  context.isMobile
                      // Full-width and stacked on phones: a single clean column
                      // of touch targets rather than two ragged pills.
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ActionButton(
                              label: 'Explore Our Work',
                              tone: ButtonTone.solidLight,
                              expand: true,
                              onPressed: onExploreWork,
                            ),
                            const SizedBox(height: 12),
                            ActionButton(
                              label: 'Get in Touch',
                              tone: ButtonTone.outlineOnDark,
                              expand: true,
                              onPressed: onGetInTouch,
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          children: [
                            ActionButton(
                              label: 'Explore Our Work',
                              tone: ButtonTone.solidLight,
                              onPressed: onExploreWork,
                            ),
                            ActionButton(
                              label: 'Get in Touch',
                              tone: ButtonTone.outlineOnDark,
                              onPressed: onGetInTouch,
                            ),
                          ],
                        ),
                ),
                if (context.isMobile) ...[
                  const SizedBox(height: 28),
                  rise(
                    0.5,
                    0.9,
                    IgnorePointer(
                      child: Text(
                        ContactConfig.addressLine.toUpperCase(),
                        style: AppText.eyebrow(
                          context,
                          color: AppColors.textOnDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: 'Spaces Designed\nWith Character'),
            TextSpan(text: '.', style: TextStyle(color: AppColors.coral)),
          ],
        ),
        style: AppText.display(context, color: AppColors.textOnDark),
      ),
    );
  }
}

class _ScrollCue extends StatefulWidget {
  const _ScrollCue();

  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends State<_ScrollCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.reduceMotion && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: Text(
            'SCROLL',
            style: AppText.eyebrow(
              context,
              color: AppColors.textOnDark.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          width: 1,
          child: Stack(
            children: [
              Container(
                width: 1,
                color: AppColors.textOnDark.withValues(alpha: 0.28),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  return Positioned(
                    top: t * 40,
                    child: Opacity(
                      opacity: (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0),
                      child: Container(
                        width: 1,
                        height: 16,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
