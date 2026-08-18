import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import 'common/buttons.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

const List<({String title, String body})> _capabilities = [
  (
    title: 'Made to measure',
    body:
        'Pieces built to the millimetre of the space they belong to — not '
        'adjusted to fit around what was available.',
  ),
  (
    title: 'Material integrity',
    body:
        'Timber, veneer, stone and hardware selected for how they age, not '
        'only for how they photograph.',
  ),
  (
    title: 'Finish precision',
    body:
        'Joinery, edges and reveals detailed in drawing and checked again on '
        'the floor before anything is installed.',
  ),
];

class FurnitureSection extends StatelessWidget {
  const FurnitureSection({super.key, required this.onEnquire});

  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    final stacked = !context.isDesktop;

    return Section(
      background: AppColors.canvas,
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FurnitureCopy(onEnquire: onEnquire),
                SizedBox(height: context.isMobile ? 48 : 60),
                const Reveal(child: _FurnitureImages()),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: _FurnitureCopy(onEnquire: onEnquire)),
                const SizedBox(width: 88),
                const Expanded(flex: 6, child: Reveal(child: _FurnitureImages())),
              ],
            ),
    );
  }
}

class _FurnitureCopy extends StatelessWidget {
  const _FurnitureCopy({required this.onEnquire});

  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          label: 'Furniture Production',
          title: 'Designed. Crafted.\nMade for the Space.',
        ),
        SizedBox(height: context.isMobile ? 24 : 30),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              'Producing our own furniture is what keeps a design intact. '
              'Wardrobes, cabinetry, tables and seating are drawn as part of '
              'the interior and then made to those drawings — so proportion, '
              'material and finish carry through from concept to the installed '
              'piece.',
              style: AppText.body(context),
            ),
          ),
        ),
        SizedBox(height: context.isMobile ? 34 : 44),
        ...[
          for (var i = 0; i < _capabilities.length; i++)
            Reveal(
              delay: Duration(milliseconds: 200 + 90 * i),
              child: _CapabilityRow(
                number: '0${i + 1}',
                title: _capabilities[i].title,
                body: _capabilities[i].body,
                isLast: i == _capabilities.length - 1,
              ),
            ),
        ],
        SizedBox(height: context.isMobile ? 30 : 40),
        Reveal(
          delay: const Duration(milliseconds: 480),
          child: ArrowLink(label: 'Discuss a piece', onPressed: onEnquire),
        ),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({
    required this.number,
    required this.title,
    required this.body,
    required this.isLast,
  });

  final String number;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      padding: const EdgeInsets.only(top: 20, bottom: 22),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: AppColors.border),
          bottom: isLast
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                number,
                style: AppText.eyebrow(context, color: AppColors.teal),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bodySmall(
                    context,
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.4),
                ),
                const SizedBox(height: 6),
                Text(body, style: AppText.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FurnitureImages extends StatelessWidget {
  const _FurnitureImages();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return SizedBox(
          height: w * (context.isMobile ? 1.02 : 1.1),
          child: Stack(
            children: [
              Positioned(
                left: w * 0.16,
                top: 0,
                right: 0,
                bottom: w * 0.16,
                child: const Photo(
                  'assets/images/furniture-main.jpg',
                  semanticLabel:
                      'Wall-mounted custom joinery with open shelving in oak',
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                width: w * 0.42,
                height: w * 0.5,
                child: Container(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  color: AppColors.canvas,
                  child: const Photo(
                    'assets/images/furniture-detail.jpg',
                    semanticLabel: 'Hand-finished brass pendant lights',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
