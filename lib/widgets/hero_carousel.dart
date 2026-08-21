import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../data/hero_slides.dart';
import 'common/page_scroll.dart';
import 'common/photo.dart';

/// How far a photograph lags behind its page while swiping — the depth cue that
/// stops the carousel feeling like a stack of flat cards.
const double _kParallax = 0.12;

const Duration _kJumpDuration = Duration(milliseconds: 620);

/// The swipeable photograph layer behind the hero copy.
///
/// Deliberately split into three widgets — [HeroCarousel] for the images,
/// [HeroSlideCaption] and [HeroSlideIndicator] for the overlay — because the
/// images sit at the bottom of the hero [Stack] while the copy sits on top of
/// the scrim. All three read the same [page] notifier, so a caption crossfades
/// in step with the finger rather than snapping once the page settles.
class HeroCarousel extends StatelessWidget {
  const HeroCarousel({
    super.key,
    required this.controller,
    required this.page,
    required this.entrance,
  });

  final PageController controller;
  final ValueListenable<double> page;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // A hero is swiped on a phone but dragged with a mouse on the web, and
      // Flutter omits mouse from a scrollable's drag devices by default.
      behavior: const _CarouselScrollBehavior(),
      child: PageView.builder(
        controller: controller,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: kHeroSlides.length,
        itemBuilder: (context, index) => _Slide(
          slide: kHeroSlides[index],
          index: index,
          page: page,
          entrance: entrance,
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.slide,
    required this.index,
    required this.page,
    required this.entrance,
  });

  final HeroSlide slide;
  final int index;
  final ValueListenable<double> page;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;

    Widget image = Photo(
      slide.image,
      fit: BoxFit.cover,
      alignment: slide.alignment,
      semanticLabel: slide.semanticLabel,
    );

    if (reduce) return image;

    // Vertical drift as the page scrolls past, carried over from the single
    // photograph this carousel replaced.
    final scrolled = PageScroll.maybeOf(context)?.offset;
    if (scrolled != null) {
      image = ValueListenableBuilder<double>(
        valueListenable: scrolled,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, (value * 0.22).clamp(0.0, 240.0)),
          child: child,
        ),
        child: image,
      );
    }

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[entrance, page]),
          builder: (context, child) {
            final t = Curves.easeOutCubic.transform(entrance.value);
            // The photograph trails its page, and always towards the edge that
            // has already left the viewport — so the lag can never drag an
            // empty edge into frame, and the image needs no overscan to hide
            // one. It stays at its native scale, which these fairly small
            // source files need.
            final lag = (page.value - index) * constraints.maxWidth * _kParallax;
            return Transform.translate(
              offset: Offset(lag, 0),
              child: Transform.scale(
                scale: 1 + 0.06 * (1 - t),
                child: child,
              ),
            );
          },
          child: image,
        ),
      ),
    );
  }
}

/// The per-slide promise, crossfading as the photographs move.
///
/// Every caption is laid out at once inside a [Stack] so the row keeps the
/// height of the longest one — a caption that wraps on a phone then can't nudge
/// the headline below it while you swipe.
class HeroSlideCaption extends StatelessWidget {
  const HeroSlideCaption({super.key, required this.page});

  final ValueListenable<double> page;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;

    return IgnorePointer(
      child: ValueListenableBuilder<double>(
        valueListenable: page,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            for (var i = 0; i < kHeroSlides.length; i++)
              _CaptionLine(
                text: kHeroSlides[i].caption,
                // Twice the rate of the swipe, so the outgoing caption has
                // cleared before the incoming one arrives. A plain linear
                // crossfade leaves both at half opacity mid-swipe, and two
                // centred lines of tracked capitals on top of each other are
                // unreadable.
                opacity: (1 - 2 * (value - i).abs()).clamp(0.0, 1.0),
                drift: reduce ? 0 : (i - value) * 26,
              ),
          ],
        ),
      ),
    );
  }
}

class _CaptionLine extends StatelessWidget {
  const _CaptionLine({
    required this.text,
    required this.opacity,
    required this.drift,
  });

  final String text;
  final double opacity;
  final double drift;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(drift, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 34,
              height: 1,
              margin: const EdgeInsets.only(right: 16, top: 2),
              color: AppColors.textOnDark,
            ),
            Flexible(
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppText.slideCaption(
                  context,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable rules marking the current slide — also the only affordance telling
/// a desktop visitor there is a second photograph at all.
class HeroSlideIndicator extends StatelessWidget {
  const HeroSlideIndicator({
    super.key,
    required this.controller,
    required this.page,
  });

  final PageController controller;
  final ValueListenable<double> page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < kHeroSlides.length; i++)
          Semantics(
            button: true,
            label: 'Show slide ${i + 1} of ${kHeroSlides.length}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.animateToPage(
                  i,
                  duration: _kJumpDuration,
                  curve: Curves.easeOutCubic,
                ),
                // Padding rather than a bare 2px rule, so the touch target
                // clears the 44px minimum on a phone.
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 6,
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: page,
                    builder: (context, value, _) {
                      final t = (1 - (value - i).abs()).clamp(0.0, 1.0);
                      return AnimatedContainer(
                        duration: Duration.zero,
                        width: 20 + 26 * t,
                        height: 2,
                        color: AppColors.textOnDark.withValues(
                          alpha: 0.3 + 0.7 * t,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CarouselScrollBehavior extends MaterialScrollBehavior {
  const _CarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };

  /// No stretch or glow at the ends — the hero should look like a photograph,
  /// not a list that ran out.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
