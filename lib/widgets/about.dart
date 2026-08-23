import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import 'common/buttons.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

// const List<String> _principles = <String>[
//   'Every space has its own character',
//   'Every client has a unique vision',
//   'Function and aesthetics, held together',
//   'Quality carried through to the last detail',
// ];

class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
    required this.onDiscover,
  });

  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    final stacked = !context.isDesktop;

    return Section(
      background: AppColors.canvas,
      child: stacked
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Not wrapped in a Reveal — the grid stages its own header and
          // then walks the cards in, and a Reveal around the whole block
          // would fade that choreography in as one flat lump.
          const PremiumFeaturesGrid(),
          SizedBox(
            height: context.isMobile ? 42 : 52,
          ),
          _AboutCopy(
            onDiscover: onDiscover,
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ---------------------------------------------------------
          // LEFT SIDE - PREMIUM FEATURES
          // ---------------------------------------------------------
          const Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PremiumFeaturesGrid(),
            ),
          ),

          const SizedBox(width: 64),

          // ---------------------------------------------------------
          // RIGHT SIDE - ABOUT CONTENT
          // ---------------------------------------------------------
          Expanded(
            flex: 6,
            child: _AboutCopy(
              onDiscover: onDiscover,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PREMIUM FEATURES GRID
// ===========================================================================

/// The studio's credentials, set as a small spec grid beside the about copy.
///
/// Sized from the width it is actually handed rather than from a breakpoint:
/// the block sits at roughly half a desktop row, at full tablet width and at
/// full mobile width, and the type has to hold at all three.
class PremiumFeaturesGrid extends StatelessWidget {
  const PremiumFeaturesGrid({
    super.key,
  });

  static const List<_FeatureItem> features = [
    _FeatureItem(
      label: 'ESTABLISHED',
      value: '2011',
      badge: '20+ YRS',
      icon: Icons.auto_awesome_outlined,
    ),
    _FeatureItem(
      label: 'MATERIALS',
      value: 'Bespoke Grade',
      badge: 'LUXURY',
      icon: Icons.verified_outlined,
    ),
    _FeatureItem(
      label: 'WARRANTY',
      value: '10 Years Full',
      badge: 'PROTECTED',
      icon: Icons.workspace_premium_outlined,
    ),
    _FeatureItem(
      label: 'COMPLETION',
      value: '45 Work Days',
      badge: 'EXPRESS',
      icon: Icons.hourglass_top_rounded,
    ),
    // _FeatureItem(
    //   label: 'DELIVERY',
    //   value: '300+ / Month',
    //   badge: 'SCALE',
    //   icon: Icons.architecture_rounded,
    // ),
    _FeatureItem(
      label: 'CONCIERGE',
      value: 'Lifelong Care',
      badge: '24/7',
      icon: Icons.headset_mic_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // The cap sits outside the LayoutBuilder so the metrics below are measured
    // against the width the grid actually gets, not the width it was offered.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 580,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = _GridMetrics.forWidth(constraints.maxWidth);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PremiumGridHeader(),
              SizedBox(height: metrics.compact ? 26 : 32),
              GridView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                // The cards lift and cast a shadow on hover; the top row would
                // be shaved off against the viewport edge if this clipped.
                clipBehavior: Clip.none,
                itemCount: features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: metrics.columns,
                  crossAxisSpacing: metrics.gap,
                  mainAxisSpacing: metrics.gap,
                  mainAxisExtent: metrics.cardHeight,
                ),
                itemBuilder: (context, index) {
                  // A diagonal wave rather than a straight run: the cards
                  // settle outwards from the top-left corner, which reads as
                  // one gesture instead of five separate ones.
                  final wave = index ~/ metrics.columns +
                      index % metrics.columns;

                  return Reveal(
                    delay: Duration(milliseconds: 150 + 70 * wave),
                    duration: const Duration(milliseconds: 720),
                    distance: 20,
                    scale: 0.965,
                    child: _FeatureCard(
                      item: features[index],
                      metrics: metrics,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
// GRID METRICS
// ===========================================================================

/// Every measurement the cards need, resolved once per layout.
///
/// Keeping it here rather than inside the card means the grid can reserve an
/// exact row height up front, so all five cards agree on where the icon, the
/// value and the rule sit — the thing that makes a spec grid read as a grid.
class _GridMetrics {
  const _GridMetrics({
    required this.columns,
    required this.gap,
    required this.compact,
    required this.cardHeight,
    required this.padding,
    required this.iconBox,
    required this.labelSize,
    required this.labelGap,
    required this.valueSize,
    required this.ruleGap,
    required this.badgeSize,
  });

  factory _GridMetrics.forWidth(double width) {
    // Three across only once a third column would still leave each card wide
    // enough for its value to sit on one line.
    final columns = width >= 520 ? 3 : 2;
    final gap = width >= 520 ? 16.0 : 12.0;
    final cardWidth = (width - gap * (columns - 1)) / columns;
    final compact = cardWidth < 160;

    final padding = compact ? 14.0 : 18.0;
    final iconBox = compact ? 32.0 : 38.0;
    // Tight enough that the plate reads as belonging to the text under it
    // rather than floating in its own half of the card.
    final iconGap = compact ? 14.0 : 18.0;
    final labelSize = compact ? 8.5 : 9.5;
    final labelGap = compact ? 4.0 : 6.0;
    final valueSize = (cardWidth * 0.125).clamp(15.0, 21.0);
    final ruleGap = compact ? 8.0 : 10.0;

    return _GridMetrics(
      columns: columns,
      gap: gap,
      compact: compact,
      padding: padding,
      iconBox: iconBox,
      labelSize: labelSize,
      labelGap: labelGap,
      valueSize: valueSize,
      ruleGap: ruleGap,
      badgeSize: compact ? 7.0 : 8.0,
      cardHeight: padding * 2 +
          iconBox +
          iconGap +
          labelSize * labelHeight +
          labelGap +
          valueSize * valueHeight +
          ruleGap +
          1 + // the rule itself
          2, // rounding headroom, absorbed by the card's spacer
    );
  }

  /// Line heights, shared with the card so the reserved space and the rendered
  /// text stay in step.
  static const double labelHeight = 1.4;
  static const double valueHeight = 1.16;

  final int columns;
  final double gap;

  /// True for the narrow two-up layout, where everything steps down a size.
  final bool compact;

  final double cardHeight;
  final double padding;
  final double iconBox;
  final double labelSize;
  final double labelGap;
  final double valueSize;
  final double ruleGap;
  final double badgeSize;

  double get iconSize => iconBox * 0.52;
}

// ===========================================================================
// PREMIUM GRID HEADER
// ===========================================================================

class _PremiumGridHeader extends StatelessWidget {
  const _PremiumGridHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(
          child: SectionLabel('The Ze Space standard'),
        ),
        SizedBox(height: context.isMobile ? 14 : 18),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Text(
            'Crafted to Perfection.',
            style: AppText.h3(context),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// FEATURE MODEL
// ===========================================================================

class _FeatureItem {
  const _FeatureItem({
    required this.label,
    required this.value,
    required this.badge,
    required this.icon,
  });

  /// The quiet uppercase caption — what the number is.
  final String label;

  /// The fact itself, and the loudest thing on the card.
  final String value;

  final String badge;
  final IconData icon;
}

// ===========================================================================
// FEATURE CARD
// ===========================================================================

/// One credential.
///
/// Flat and orthogonal at rest — hairline border, no shadow, square corners,
/// in step with the buttons and the services grid. Everything that answers the
/// cursor is driven from a single controller, so the lift, the border, the
/// plate, the badge and the rule all move as one rather than as five
/// animations that happen to have been given the same duration.
class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.item,
    required this.metrics,
  });

  final _FeatureItem item;
  final _GridMetrics metrics;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final CurvedAnimation _hover = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeOut,
  );

  @override
  void dispose() {
    _hover.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered, {required bool reduceMotion}) {
    if (reduceMotion) {
      _controller.value = hovered ? 1 : 0;
      return;
    }
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read here rather than in the callbacks, so the card subscribes to the
    // preference at the point the framework expects it to.
    final reduceMotion = context.reduceMotion;

    return MouseRegion(
      // Informational, not actionable — so no click cursor and no tap target.
      onEnter: (_) => _setHovered(true, reduceMotion: reduceMotion),
      onExit: (_) => _setHovered(false, reduceMotion: reduceMotion),
      child: AnimatedBuilder(
        animation: _hover,
        builder: (context, _) => _build(context, _hover.value),
      ),
    );
  }

  Widget _build(BuildContext context, double t) {
    final m = widget.metrics;
    final item = widget.item;

    return Transform.translate(
      offset: Offset(0, -6 * t),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: Color.lerp(AppColors.border, AppColors.teal, t)!,
          ),
          boxShadow: [
            // Absent at rest, so the grid stays as flat as the rest of the
            // page; it is the lift that the shadow explains.
            BoxShadow(
              color: AppColors.slateDeep.withValues(alpha: 0.10 * t),
              blurRadius: 28,
              offset: Offset(0, 12 * t),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(m.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconPlate(
                    icon: item.icon,
                    metrics: m,
                    t: t,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _FeatureBadge(
                        text: item.badge,
                        metrics: m,
                        t: t,
                      ),
                    ),
                  ),
                ],
              ),

              // Holds the gap the metrics reserved, and quietly absorbs any
              // rounding surplus instead of overflowing the row.
              const Spacer(),

              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.eyebrow(
                  context,
                  color: AppColors.textMuted,
                ).copyWith(
                  fontSize: m.labelSize,
                  height: _GridMetrics.labelHeight,
                  letterSpacing: 1.9,
                ),
              ),

              SizedBox(height: m.labelGap),

              // Serif, and the only large thing on the card — the same voice
              // the section headings use, so the fact reads as a statement
              // rather than as data. Scaled down instead of wrapped, so the
              // rule underneath stays on one line across the whole row.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: AppText.serif,
                    fontSize: m.valueSize,
                    fontWeight: FontWeight.w500,
                    height: _GridMetrics.valueHeight,
                    letterSpacing: -0.1,
                    color: Color.lerp(
                      AppColors.textPrimary,
                      AppColors.tealDeep,
                      t,
                    ),
                  ),
                ),
              ),

              SizedBox(height: m.ruleGap),

              // The same hairline-that-grows as the arrow links, so the hover
              // vocabulary is shared across the page.
              Container(
                height: 1,
                width: 18 + 22 * t,
                color: Color.lerp(AppColors.border, AppColors.teal, t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filled plate behind the icon. Square rather than circular — the geometry of
/// the page is orthogonal and the cards follow it.
class _IconPlate extends StatelessWidget {
  const _IconPlate({
    required this.icon,
    required this.metrics,
    required this.t,
  });

  final IconData icon;
  final _GridMetrics metrics;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: metrics.iconBox,
      height: metrics.iconBox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.tealWash, AppColors.teal, t),
        border: Border.all(
          color: Color.lerp(
            AppColors.teal.withValues(alpha: 0.22),
            AppColors.teal,
            t,
          )!,
        ),
      ),
      child: Icon(
        icon,
        size: metrics.iconSize,
        color: Color.lerp(AppColors.tealDeep, AppColors.surface, t),
      ),
    );
  }
}

/// Micro-tag in the top-right corner. Deliberately the smallest type on the
/// card: it qualifies the value, it does not compete with it.
class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.text,
    required this.metrics,
    required this.t,
  });

  final String text;
  final _GridMetrics metrics;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.compact ? 5 : 7,
        vertical: metrics.compact ? 2.5 : 3.5,
      ),
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.sand, AppColors.tealWash, t),
        border: Border.all(
          color: Color.lerp(
            AppColors.border,
            AppColors.teal.withValues(alpha: 0.55),
            t,
          )!,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppText.eyebrow(context).copyWith(
          fontSize: metrics.badgeSize,
          height: 1.2,
          letterSpacing: 1.1,
          color: Color.lerp(AppColors.textMuted, AppColors.tealDeep, t),
        ),
      ),
    );
  }
}

// ===========================================================================
// ABOUT IMAGES
// ===========================================================================

class _AboutImages extends StatelessWidget {
  const _AboutImages();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return SizedBox(
          height: w * (context.isMobile ? 1.16 : 1.22),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: w * 0.14,
                bottom: w * 0.18,
                child: const Photo(
                  'assets/images/about-main.jpg',
                  semanticLabel:
                  'Interior with a timber-clad ceiling, cane sideboard and '
                      'herringbone floor',
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: w * 0.5,
                height: w * 0.38,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.canvas,
                  child: const Photo(
                    'assets/images/about-detail.jpg',
                    semanticLabel:
                    'Warm living room with custom timber table and leather '
                        'ottomans',
                  ),
                ),
              ),
              Positioned(
                left: w * 0.02,
                bottom: w * 0.04,
                child: Container(
                  width: 56,
                  height: 2,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// ABOUT COPY
// ===========================================================================

class _AboutCopy extends StatelessWidget {
  const _AboutCopy({
    required this.onDiscover,
  });

  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          label: 'About the studio',
          title: 'Designed Around You.',
        ),

        SizedBox(
          height: context.isMobile ? 24 : 30,
        ),

        Reveal(
          delay: const Duration(
            milliseconds: 160,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: Text(
              'Ze Space Interior is a Kochi-based interior design and furniture '
                  'production studio, working on spaces that hold aesthetics, '
                  'function and lasting quality in the same frame.',
              style: AppText.body(context),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Reveal(
          delay: const Duration(
            milliseconds: 220,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: Text(
              'We begin by understanding how a space is actually used and what '
                  'the people in it want from it — then translate that into '
                  'interiors that are practical, refined and distinctly personal. '
                  'From concept and design development through to custom furniture '
                  'production, the work stays in one pair of hands.',
              style: AppText.body(context),
            ),
          ),
        ),

        SizedBox(
          height: context.isMobile ? 34 : 44,
        ),

        Reveal(
          delay: const Duration(
            milliseconds: 340,
          ),
          child: ArrowLink(
            label: 'Discover Ze Space',
            onPressed: onDiscover,
          ),
        ),
      ],
    );
  }
}
