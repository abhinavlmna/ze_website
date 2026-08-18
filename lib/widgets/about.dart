import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import 'common/buttons.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

const List<String> _principles = <String>[
  'Every space has its own character',
  'Every client has a unique vision',
  'Function and aesthetics, held together',
  'Quality carried through to the last detail',
];

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.onDiscover});

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
                const Reveal(child: _AboutImages()),
                SizedBox(height: context.isMobile ? 44 : 56),
                _AboutCopy(onDiscover: onDiscover),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 5, child: Reveal(child: _AboutImages())),
                const SizedBox(width: 88),
                Expanded(
                  flex: 6,
                  child: _AboutCopy(onDiscover: onDiscover),
                ),
              ],
            ),
    );
  }
}

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
                child: Container(width: 56, height: 2, color: AppColors.teal),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AboutCopy extends StatelessWidget {
  const _AboutCopy({required this.onDiscover});

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
        SizedBox(height: context.isMobile ? 24 : 30),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
          delay: const Duration(milliseconds: 220),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
        SizedBox(height: context.isMobile ? 34 : 44),
        const Reveal(
          delay: Duration(milliseconds: 280),
          child: _PrincipleGrid(),
        ),
        SizedBox(height: context.isMobile ? 34 : 44),
        Reveal(
          delay: const Duration(milliseconds: 340),
          child: ArrowLink(
            label: 'Discover Ze Space',
            onPressed: onDiscover,
          ),
        ),
      ],
    );
  }
}

class _PrincipleGrid extends StatelessWidget {
  const _PrincipleGrid();

  @override
  Widget build(BuildContext context) {
    final columns = context.isMobile ? 1 : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 24.0;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 20,
          children: [
            for (final principle in _principles)
              SizedBox(
                width: itemWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 1,
                      margin: const EdgeInsets.only(top: 12, right: 14),
                      color: AppColors.teal,
                    ),
                    Expanded(
                      child: Text(
                        principle,
                        style: AppText.bodySmall(
                          context,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
