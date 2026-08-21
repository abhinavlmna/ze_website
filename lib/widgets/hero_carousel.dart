import 'dart:async';

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

/// How long a photograph holds before the carousel moves on by itself.
const Duration kHeroSlideInterval = Duration(seconds: 3);

/// Unprompted motion is slower than a deliberate tap — the hero drifts to the
/// next frame rather than snapping to it.
const Duration kHeroAutoAdvance = Duration(milliseconds: 900);

/// The swipeable photograph layer behind the hero copy.
///
/// Deliberately split into three widgets — [HeroCarousel] for the images,
/// [HeroSlideCaption] and [HeroSlideIndicator] for the overlay — because the
/// images sit at the bottom of the hero [Stack] while the copy sits on top of
/// the scrim. All three read the same [page] notifier, so a caption crossfades
/// in step with the finger rather than snapping once the page settles.
///
/// Advances on its own every [kHeroSlideInterval], and hands control straight
/// back to the visitor: a finger or mouse on the photograph stops the timer,
/// which starts over once the gesture ends.
class HeroCarousel extends StatefulWidget {
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
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  Timer? _timer;
  bool _configured = false;
  bool _autoPlay = true;

  @override
  void initState() {
    super.initState();
    widget.entrance.addStatusListener(_onEntrance);
  }

  /// The hold starts once the hero has finished arriving. Counting from the
  /// first frame instead would spend most of the first hold on the entrance
  /// fade, and swap the photograph moments after it became readable.
  void _onEntrance(AnimationStatus status) {
    if (status == AnimationStatus.completed) _restart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nothing moves on its own for a visitor who asked the platform to stop
    // animating things.
    final allowed = !context.reduceMotion;
    if (_configured && allowed == _autoPlay) return;
    _configured = true;
    _autoPlay = allowed;
    if (allowed) {
      _restart();
    } else {
      _stop();
    }
  }

  @override
  void dispose() {
    widget.entrance.removeStatusListener(_onEntrance);
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    if (!_autoPlay || !widget.entrance.isCompleted) return;
    _timer = Timer.periodic(kHeroSlideInterval, (_) => _advance());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _advance() {
    final controller = widget.controller;
    if (!mounted || !controller.hasClients) return;
    // Never interrupt a transition already under way. The next index is read
    // off the current page, and rounding a page that is halfway between two
    // slides would send the carousel back the way it came.
    if (controller.position.isScrollingNotifier.value) return;
    final current = (controller.page ?? 0).round();
    controller.animateToPage(
      (current + 1) % kHeroSlides.length,
      duration: kHeroAutoAdvance,
      curve: Curves.easeInOutCubic,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    // Only a real drag counts as taking over — the carousel's own animations
    // raise these notifications too, with no drag details attached.
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _stop();
    } else if (notification is ScrollEndNotification) {
      // Restart rather than resume, so a visitor who just swiped gets the full
      // interval to look at the frame they chose.
      _restart();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ScrollConfiguration(
        // A hero is swiped on a phone but dragged with a mouse on the web, and
        // Flutter omits mouse from a scrollable's drag devices by default.
        behavior: const _CarouselScrollBehavior(),
        child: PageView.builder(
          controller: widget.controller,
          physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: kHeroSlides.length,
          itemBuilder: (context, index) => _Slide(
            slide: kHeroSlides[index],
            index: index,
            page: widget.page,
            entrance: widget.entrance,
          ),
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

/// Crossfades one widget per slide in a single slot of the hero column.
///
/// Every slide's widget is laid out at once inside a [Stack], so the slot keeps
/// the height of the tallest — whatever is below it then holds still while you
/// swipe, instead of being nudged up and down.
class HeroSlideSwap extends StatelessWidget {
  const HeroSlideSwap({
    super.key,
    required this.page,
    required this.builder,
    this.drift = 26,
  });

  final ValueListenable<double> page;

  /// Builds the content for one slide index.
  final Widget Function(BuildContext context, int index) builder;

  /// How far the content slides sideways as it fades, in logical pixels.
  final double drift;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;

    return ValueListenableBuilder<double>(
      valueListenable: page,
      builder: (context, value, _) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          for (var i = 0; i < kHeroSlides.length; i++)
            _SwapLayer(
              // Twice the rate of the swipe, so the outgoing layer has cleared
              // before the incoming one arrives. A plain linear crossfade
              // leaves both at half opacity mid-swipe, and two centred blocks
              // of type on top of each other are unreadable.
              opacity: (1 - 2 * (value - i).abs()).clamp(0.0, 1.0),
              drift: reduce ? 0 : (i - value) * drift,
              child: builder(context, i),
            ),
        ],
      ),
    );
  }
}

class _SwapLayer extends StatelessWidget {
  const _SwapLayer({
    required this.opacity,
    required this.drift,
    required this.child,
  });

  final double opacity;
  final double drift;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Only a layer that has fully arrived takes pointers — otherwise a
      // half-faded badge underneath the visible one would still light up.
      ignoring: opacity < 1,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(offset: Offset(drift, 0), child: child),
      ),
    );
  }
}

/// The per-slide promise, crossfading as the photographs move.
class HeroSlideCaption extends StatelessWidget {
  const HeroSlideCaption({super.key, required this.page});

  final ValueListenable<double> page;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: HeroSlideSwap(
        page: page,
        builder: (context, index) =>
            _CaptionLine(text: kHeroSlides[index].caption),
      ),
    );
  }
}

class _CaptionLine extends StatelessWidget {
  const _CaptionLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            ).copyWith(
              // The caption sits straight on the photograph, and the second
              // slide runs bright behind it. Emphasis has to come from contrast
              // — an accent hue at this size and tracking reads as dimmer type,
              // not as a highlight.
              shadows: <Shadow>[
                Shadow(
                  color: AppColors.slateDeep.withValues(alpha: 0.85),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
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
