import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'common/buttons.dart';
import 'common/page_scroll.dart';
import 'common/photo.dart';

/// Full-bleed opening statement: one photograph, one line of type, two ways in.
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

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          Positioned.fill(child: _ParallaxBackdrop(entrance: _entrance)),
          const Positioned.fill(child: _HeroScrim()),
          _HeroContent(
            rise: _rise,
            onExploreWork: widget.onExploreWork,
            onGetInTouch: widget.onGetInTouch,
          ),
          if (!context.isMobile)
            Positioned(
              right: context.gutter,
              bottom: 44,
              child: _rise(0.75, 1.0, const _ScrollCue()),
            ),
        ],
      ),
    );
  }
}

/// The photograph drifts a quarter of the scroll distance and settles out of a
/// very slow zoom, so the first paint has movement without being showy.
class _ParallaxBackdrop extends StatelessWidget {
  const _ParallaxBackdrop({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    const image = Photo(
      'assets/images/hero.jpg',
      fit: BoxFit.cover,
      alignment: Alignment(0, 0.25),
      semanticLabel:
          'An open-plan contemporary living room with a timber feature wall '
          'and full-height glazing',
    );

    final offset = PageScroll.maybeOf(context)?.offset;
    final reduce = context.reduceMotion;

    return ClipRect(
      child: AnimatedBuilder(
        animation: entrance,
        builder: (context, child) {
          final zoom = reduce
              ? 1.0
              : 1.06 - 0.06 * Curves.easeOutCubic.transform(entrance.value);
          return Transform.scale(scale: zoom, child: child);
        },
        child: offset == null || reduce
            ? image
            : ValueListenableBuilder<double>(
                valueListenable: offset,
                builder: (context, value, child) {
                  final shift = (value * 0.22).clamp(0.0, 240.0);
                  return Transform.translate(
                    offset: Offset(0, shift),
                    child: child,
                  );
                },
                child: image,
              ),
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
    required this.onExploreWork,
    required this.onGetInTouch,
  });

  final Widget Function(double start, double end, Widget child,
      {double distance}) rise;
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
                rise(
                  0.05,
                  0.35,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 1,
                        margin: const EdgeInsets.only(right: 16, top: 2),
                        color: AppColors.textOnDark,
                      ),
                      Flexible(
                        child: Text(
                          '100% Customised Designs'.toUpperCase(),
                          style: AppText.eyebrow(
                            context,
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.isMobile ? 22 : 30),
                rise(
                  0.12,
                  0.5,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(text: 'Spaces Designed\nWith Character'),
                          TextSpan(
                            text: '.',
                            style: TextStyle(color: AppColors.coral),
                          ),
                        ],
                      ),
                      style: AppText.display(
                        context,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                  distance: 34,
                ),
                SizedBox(height: context.isMobile ? 24 : 32),
                rise(
                  0.24,
                  0.62,
                  ConstrainedBox(
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
                    Text(
                      ContactConfig.addressLine.toUpperCase(),
                      style: AppText.eyebrow(
                        context,
                        color: AppColors.textOnDark.withValues(alpha: 0.7),
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
