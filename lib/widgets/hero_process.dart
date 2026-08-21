import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../data/process_steps.dart';

/// The delivery process as a row of circular badges — what the second slide
/// shows in place of the first slide's headline.
///
/// Sized from the space it is given rather than from breakpoints: five badges
/// and four connectors always have to share one line, so the width each badge
/// can afford is the thing that decides the type size and whether the long or
/// short caption is used.
class HeroProcess extends StatelessWidget {
  const HeroProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const int count = 5;
        assert(kProcessSteps.length == count);

        // Connectors only once there is room for them to read as connectors
        // rather than as clutter between two cramped badges.
        final connector = constraints.maxWidth >= 660 ? 30.0 : 0.0;
        final itemWidth =
            ((constraints.maxWidth - connector * (count - 1)) / count)
                .clamp(50.0, 168.0);
        final diameter = (itemWidth * 0.70).clamp(42.0, 112.0);
        final compact = itemWidth < 108;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var i = 0; i < count; i++) ...<Widget>[
              if (i > 0 && connector > 0)
                _Connector(width: connector, centre: diameter / 2),
              _Badge(
                step: kProcessSteps[i],
                width: itemWidth,
                diameter: diameter,
                compact: compact,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.width, required this.centre});

  final double width;

  /// Distance from the top of the row to the middle of a badge, so the arrow
  /// lines up with the circles rather than with the block of caption below.
  final double centre;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    return Padding(
      padding: EdgeInsets.only(top: centre - size / 2),
      child: SizedBox(
        width: width,
        child: Icon(
          Icons.arrow_right_alt,
          size: size,
          color: AppColors.textOnDark.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _Badge extends StatefulWidget {
  const _Badge({
    required this.step,
    required this.width,
    required this.diameter,
    required this.compact,
  });

  final ProcessStep step;
  final double width;
  final double diameter;
  final bool compact;

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return MouseRegion(
      // Reports hover without claiming the pointer, so a drag that starts on a
      // badge still reaches the carousel underneath it. Both halves matter: the
      // translucent behaviour keeps the region itself out of the way, and the
      // IgnorePointer below covers the icon and caption, whose render objects
      // would otherwise answer the hit test themselves. The badges are
      // deliberately inert, so the cursor stays an arrow too.
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IgnorePointer(
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Lift and swell, expressed as fractions of the badge so the
              // gesture reads the same at every size.
              AnimatedSlide(
                duration: duration,
                curve: Curves.easeOutCubic,
                offset: Offset(0, _hovered ? -0.055 : 0),
                child: AnimatedScale(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  scale: _hovered ? 1.06 : 1.0,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    width: widget.diameter,
                    height: widget.diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Every badge is a plain outline at rest; teal is what
                      // hover means. Fading an already-teal colour up from zero
                      // alpha — rather than lerping out of transparent black —
                      // keeps the fill from dipping through a muddy tone on the
                      // way in.
                      color: AppColors.teal
                          .withValues(alpha: _hovered ? 1.0 : 0.0),
                      border: Border.all(
                        color: _hovered
                            ? AppColors.teal
                            : AppColors.textOnDark.withValues(alpha: 0.42),
                        width: 1.2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.teal
                              .withValues(alpha: _hovered ? 0.45 : 0.0),
                          blurRadius: 28,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      step.icon,
                      size: widget.diameter * 0.40,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.compact ? 10 : 18),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: Curves.easeOutCubic,
                textAlign: TextAlign.center,
                style: AppText.processStep(
                  context,
                  color: AppColors.textOnDark
                      .withValues(alpha: _hovered ? 1.0 : 0.82),
                ),
                child: Text(
                  widget.compact ? step.shortLabel : step.label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
