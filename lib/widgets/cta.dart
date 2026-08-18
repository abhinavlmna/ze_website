import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'common/buttons.dart';
import 'common/reveal.dart';
import 'common/section.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key, required this.onGetInTouch});

  final VoidCallback onGetInTouch;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.slateDeep, AppColors.slate],
        ),
      ),
      child: Section(
        top: fluid(context, min: 80, max: 130),
        bottom: fluid(context, min: 80, max: 130),
        maxWidth: 960,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Reveal(
              child: Text(
                'Let’s Create a Space That Feels Like Yours.',
                textAlign: TextAlign.center,
                style: AppText.h2(context, color: AppColors.textOnDark),
              ),
            ),
            SizedBox(height: context.isMobile ? 20 : 26),
            Reveal(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Have a space in mind? Let’s talk about your vision.',
                textAlign: TextAlign.center,
                style: AppText.body(
                  context,
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ),
            SizedBox(height: context.isMobile ? 34 : 46),
            Reveal(
              delay: const Duration(milliseconds: 180),
              child: Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  ActionButton(
                    label: 'WhatsApp Us',
                    tone: ButtonTone.solidLight,
                    onPressed: () => LinkLauncher.whatsapp(),
                    semanticLabel:
                        'Message Ze Space Interior on WhatsApp at '
                        '${ContactConfig.phoneDisplay}',
                  ),
                  ActionButton(
                    label: 'Get in Touch',
                    tone: ButtonTone.outlineOnDark,
                    onPressed: onGetInTouch,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
