import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../data/services.dart';
import 'common/reveal.dart';
import 'common/section.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.pick(mobile: 1, tablet: 2, desktop: 4);

    return Section(
      background: AppColors.sand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: SectionHeading(
                    label: 'Services',
                    title: 'What We Do',
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  child: Reveal(
                    delay: const Duration(milliseconds: 140),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Four disciplines, run as one process — so the drawing, '
                        'the detail and the finished piece of furniture all '
                        'answer to the same idea.',
                        style: AppText.body(context),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            const SectionHeading(
              label: 'Services',
              title: 'What We Do',
              lead:
                  'Four disciplines, run as one process — so the drawing, the '
                  'detail and the finished piece of furniture all answer to '
                  'the same idea.',
            ),
          SizedBox(height: context.pick(mobile: 48.0, tablet: 60.0, desktop: 84.0)),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = context.isDesktop ? 32.0 : 28.0;
              final itemWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: context.isMobile ? 8 : 44,
                children: [
                  for (var i = 0; i < kServices.length; i++)
                    SizedBox(
                      width: itemWidth,
                      child: Reveal(
                        delay: Duration(milliseconds: 90 * (i % columns)),
                        child: _ServiceCard(service: kServices[i]),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.service});

  final ServiceItem service;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 320);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: EdgeInsets.only(top: context.isMobile ? 26 : 32, bottom: 26),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _hovered ? AppColors.teal : AppColors.border,
              width: _hovered ? 1.6 : 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: duration,
              style: AppText.numeral(
                context,
                color: _hovered ? AppColors.teal : AppColors.textMuted,
              ).copyWith(
                color: _hovered
                    ? AppColors.teal
                    : AppColors.textPrimary.withValues(alpha: 0.32),
              ),
              child: Text(widget.service.index),
            ),
            SizedBox(height: context.isMobile ? 18 : 26),
            Text(
              widget.service.title,
              style: AppText.h3(context),
            ),
            const SizedBox(height: 16),
            Text(
              widget.service.description,
              style: AppText.bodySmall(context),
            ),
          ],
        ),
      ),
    );
  }
}
