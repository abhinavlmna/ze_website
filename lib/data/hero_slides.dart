import 'package:flutter/painting.dart';

/// One frame of the hero carousel: a photograph and the single promise it
/// carries.
class HeroSlide {
  const HeroSlide({
    required this.image,
    required this.caption,
    required this.semanticLabel,
    this.alignment = Alignment.center,
  });

  final String image;

  /// Set uppercase over the photograph.
  final String caption;

  /// Read out in place of the image by screen readers.
  final String semanticLabel;

  /// Which part of the frame survives the full-bleed crop. The source files are
  /// square, so a wide viewport keeps only a horizontal band of each one.
  final Alignment alignment;
}

const List<HeroSlide> kHeroSlides = <HeroSlide>[
  HeroSlide(
    image: 'assets/images/hero-front-view.jpg',
    caption: '100% Customized Designs',
    semanticLabel:
        'A double-height living room in cream and sage, with a sculptural '
        'glass ceiling installation and a green marble coffee table',
    alignment: Alignment(0, 0.05),
  ),
  HeroSlide(
    image: 'assets/images/hero-kitchen.jpg',
    caption: 'Project completion in 45 working days',
    semanticLabel:
        'A handleless grey kitchen with a marble waterfall island and smoked '
        'glass pendant lights',
    alignment: Alignment(0, -0.05),
  ),
];
