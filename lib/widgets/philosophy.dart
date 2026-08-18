import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

/// A full-bleed pause between the portfolio and the workshop — one photograph,
/// one sentence, nothing to click.
class PhilosophySection extends StatelessWidget {
  const PhilosophySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Photo(
            'assets/images/philosophy.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel:
                'A contemporary house at dusk, lit from within',
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.slateDeep.withValues(alpha: 0.88),
                    AppColors.slateDeep.withValues(alpha: 0.78),
                    AppColors.slateDeep.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
        ),
        Section(
          top: fluid(context, min: 96, max: 190),
          bottom: fluid(context, min: 96, max: 190),
          maxWidth: 1180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Reveal(
                child: SectionLabel(
                  'Design Philosophy',
                  color: AppColors.textOnDark,
                  lineColor: AppColors.borderOnDark,
                ),
              ),
              SizedBox(height: context.isMobile ? 30 : 44),
              Reveal(
                delay: const Duration(milliseconds: 120),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'We don’t simply design spaces.\n',
                      ),
                      TextSpan(
                        text:
                            'We shape how they feel, function, and live.',
                        style: TextStyle(
                          color: AppColors.textOnDark.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppText.statement(context),
                ),
              ),
              SizedBox(height: context.isMobile ? 34 : 52),
              Reveal(
                delay: const Duration(milliseconds: 220),
                child: Container(width: 46, height: 1, color: AppColors.teal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
