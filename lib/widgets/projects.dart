import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../data/projects.dart';
import 'common/buttons.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

/// Editorial portfolio grid — deliberately asymmetric, with each pair of
/// projects offset against the other so the page reads as a spread rather than
/// as a row of product cards.
class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key, required this.onEnquire});

  final VoidCallback onEnquire;

  static const List<_PairLayout> _pairs = <_PairLayout>[
    _PairLayout(flexA: 7, aspectA: 1.45, flexB: 5, aspectB: 1.0, offsetB: 84),
    _PairLayout(flexA: 5, aspectA: 1.0, flexB: 7, aspectB: 1.45, offsetB: 84),
    _PairLayout(flexA: 6, aspectA: 1.3, flexB: 6, aspectB: 1.3, offsetB: 62),
  ];

  @override
  Widget build(BuildContext context) {
    return Section(
      background: AppColors.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: SectionHeading(
                    label: 'Portfolio',
                    title: 'Selected Work',
                  ),
                ),
                Reveal(
                  delay: const Duration(milliseconds: 160),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ArrowLink(
                      label: 'Start a project',
                      onPressed: onEnquire,
                    ),
                  ),
                ),
              ],
            )
          else
            const SectionHeading(
              label: 'Portfolio',
              title: 'Selected Work',
              lead:
                  'Residential and commercial interiors across Kochi — each one '
                  'planned, detailed and furnished around the people who use it.',
            ),
          SizedBox(
            height: context.pick(mobile: 44.0, tablet: 56.0, desktop: 76.0),
          ),
          if (context.isMobile)
            const _MobileGrid(projects: kProjects)
          else
            const _AsymmetricGrid(projects: kProjects, pairs: _pairs),
        ],
      ),
    );
  }
}

class _PairLayout {
  const _PairLayout({
    required this.flexA,
    required this.aspectA,
    required this.flexB,
    required this.aspectB,
    required this.offsetB,
  });

  final int flexA;
  final double aspectA;
  final int flexB;
  final double aspectB;
  final double offsetB;
}

class _AsymmetricGrid extends StatelessWidget {
  const _AsymmetricGrid({required this.projects, required this.pairs});

  final List<Project> projects;
  final List<_PairLayout> pairs;

  @override
  Widget build(BuildContext context) {
    final gap = context.isDesktop ? 40.0 : 28.0;
    final rowGap = context.isDesktop ? 34.0 : 28.0;
    final rows = <Widget>[];

    for (var i = 0; i < projects.length; i += 2) {
      final layout = pairs[(i ~/ 2) % pairs.length];
      final a = projects[i];
      final b = i + 1 < projects.length ? projects[i + 1] : null;
      // Offsets are gentler on tablet, where columns are narrower.
      final offset = context.isDesktop ? layout.offsetB : layout.offsetB * 0.5;

      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : rowGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: layout.flexA,
                child: Reveal(
                  child: ProjectCard(project: a, aspectRatio: layout.aspectA),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                flex: layout.flexB,
                child: b == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(top: offset),
                        child: Reveal(
                          delay: const Duration(milliseconds: 140),
                          child: ProjectCard(
                            project: b,
                            aspectRatio: layout.aspectB,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _MobileGrid extends StatelessWidget {
  const _MobileGrid({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < projects.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 44),
            child: Reveal(
              child: ProjectCard(
                project: projects[i],
                // Alternating crops keep the single column from feeling like a
                // stack of identical tiles.
                aspectRatio: i.isEven ? 1.28 : 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.aspectRatio,
  });

  final Project project;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 400);

    return HoverZoom(
      scale: 1.06,
      overlayOnHover: true,
      builder: (context, hovered, image) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: aspectRatio, child: image),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: AppText.h3(context)),
                      const SizedBox(height: 8),
                      Text(
                        project.meta,
                        style: AppText.bodySmall(context),
                      ),
                    ],
                  ),
                ),
                if (project.year != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 16),
                    child: Text(
                      project.year!,
                      style: AppText.eyebrow(
                        context,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 1,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: hovered ? 1 : 0),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: const ColoredBox(color: AppColors.teal),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: Photo(project.image, semanticLabel: '${project.name} — ${project.meta}'),
    );
  }
}
