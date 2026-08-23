import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../data/projects.dart';
import 'common/buttons.dart';
import 'common/photo.dart';
import 'common/reveal.dart';
import 'common/section.dart';

/// Portfolio: a filterable, category-driven gallery.
///
/// The layout is a balanced masonry rather than a fixed grid — every tile takes
/// its photograph's own proportions, so a mixed set of portrait and landscape
/// frames sits together without any of them being squashed or hard-cropped.
/// Columns collapse 3 → 2 → 1 across desktop, tablet and mobile.
class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key, required this.onEnquire});

  final VoidCallback onEnquire;

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _selected = kAllCategoryId;

  void _select(String id) {
    if (id == _selected) return;
    setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    final projects = projectsIn(_selected);

    // Rebuilding under a new key restarts the per-tile reveal, so a change of
    // filter reads as the gallery re-composing itself.
    Widget gallery = _MasonryGallery(
      key: ValueKey<String>(_selected),
      projects: projects,
    );

    if (!context.reduceMotion) {
      // Glides the page below the section up or down as the tile count
      // changes, instead of snapping. Deliberately omitted under reduced
      // motion: RenderAnimatedSize cannot be driven with a zero duration.
      gallery = AnimatedSize(
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: gallery,
      );
    }

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
                      onPressed: widget.onEnquire,
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
            height: context.pick(mobile: 34.0, tablet: 40.0, desktop: 54.0),
          ),
          Reveal(
            delay: const Duration(milliseconds: 120),
            child: _CategoryFilterBar(
              selected: _selected,
              onSelect: _select,
              shownCount: projects.length,
            ),
          ),
          SizedBox(
            height: context.pick(mobile: 34.0, tablet: 42.0, desktop: 56.0),
          ),
          gallery,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selected,
    required this.onSelect,
    required this.shownCount,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final int shownCount;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      _CategoryTab(
        label: 'All',
        count: kProjects.length,
        selected: selected == kAllCategoryId,
        onTap: () => onSelect(kAllCategoryId),
      ),
      for (final category in populatedCategories)
        _CategoryTab(
          label: category.label,
          count: projectsIn(category.id).length,
          selected: selected == category.id,
          onTap: () => onSelect(category.id),
        ),
    ];

    // Wrap rather than a horizontal scroller: on a narrow phone the tabs flow
    // onto a second line instead of hiding categories off-screen.
    final bar = Wrap(
      spacing: context.pick(mobile: 24.0, tablet: 30.0, desktop: 38.0),
      runSpacing: context.isMobile ? 18 : 20,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: tabs,
    );

    final rule = Container(
      margin: EdgeInsets.only(top: context.isMobile ? 20 : 24),
      height: 1,
      color: AppColors.border,
    );

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [bar, rule],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: bar),
            const SizedBox(width: 32),
            _ShownCount(count: shownCount),
          ],
        ),
        rule,
      ],
    );
  }
}

/// "06 Spaces" — quietly re-counts itself whenever the filter changes.
class _ShownCount extends StatelessWidget {
  const _ShownCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 320);

    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey<int>(count),
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          '${count.toString().padLeft(2, '0')}  ${count == 1 ? 'Space' : 'Spaces'}',
          style: AppText.eyebrow(context, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatefulWidget {
  const _CategoryTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 300);

    final color = widget.selected
        ? AppColors.textPrimary
        : _hovered
            ? AppColors.textPrimary
            : AppColors.textMuted;

    // The rule under the label: full width when selected, a stub on hover.
    final underlineFactor = widget.selected
        ? 1.0
        : _hovered
            ? 0.34
            : 0.0;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: '${widget.label}, ${widget.count} projects',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 11, top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: Curves.easeOut,
                      style: AppText.action(context, color: color),
                      child: Text(widget.label.toUpperCase()),
                    ),
                    const SizedBox(width: 6),
                    AnimatedOpacity(
                      duration: duration,
                      opacity: widget.selected ? 1 : 0.55,
                      child: Text(
                        widget.count.toString().padLeft(2, '0'),
                        style: AppText.eyebrow(
                          context,
                          color: widget.selected
                              ? AppColors.teal
                              : AppColors.textMuted,
                        ).copyWith(fontSize: 9.5, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 1.5,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: underlineFactor),
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
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery
// ---------------------------------------------------------------------------

/// Balanced masonry: items are dealt to whichever column is currently shortest,
/// using each photograph's real proportions, so the columns end up close to the
/// same height without anything being cropped to fit.
class _MasonryGallery extends StatefulWidget {
  const _MasonryGallery({super.key, required this.projects});

  final List<Project> projects;

  /// Used while a photograph is still decoding, and for anything that fails to
  /// decode at all.
  static const double fallbackRatio = 4 / 3;

  /// Guard rails on how extreme a single tile may get. A freak panorama or a
  /// very tall portrait would otherwise dictate the whole column's rhythm.
  static const double minRatio = 0.68;
  static const double maxRatio = 1.72;

  @override
  State<_MasonryGallery> createState() => _MasonryGalleryState();
}

class _MasonryGalleryState extends State<_MasonryGallery> {
  @override
  void initState() {
    super.initState();
    _resolveRatios();
  }

  @override
  void didUpdateWidget(_MasonryGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.projects, widget.projects)) _resolveRatios();
  }

  void _resolveRatios() {
    for (final project in widget.projects) {
      if (project.aspectRatio != null) continue;
      ImageRatios.resolve(project.image, () {
        if (mounted) setState(() {});
      });
    }
  }

  double _ratioOf(Project project) {
    final ratio = project.aspectRatio ??
        ImageRatios.ratioOf(project.image) ??
        _MasonryGallery.fallbackRatio;
    return ratio.clamp(_MasonryGallery.minRatio, _MasonryGallery.maxRatio);
  }

  @override
  Widget build(BuildContext context) {
    final columns = context.pick(mobile: 1, tablet: 2, desktop: 3);
    final gap = context.pick(mobile: 40.0, tablet: 30.0, desktop: 38.0);

    if (widget.projects.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        // Height a tile will occupy: the photograph plus its caption block.
        // Only used for balancing, so an estimate of the caption is enough.
        const captionHeight = 104.0;
        final heights = List<double>.filled(columns, 0);
        final buckets = List<List<int>>.generate(columns, (_) => <int>[]);

        for (var i = 0; i < widget.projects.length; i++) {
          var target = 0;
          for (var c = 1; c < columns; c++) {
            if (heights[c] < heights[target] - 0.5) target = c;
          }
          buckets[target].add(i);
          heights[target] +=
              columnWidth / _ratioOf(widget.projects[i]) + captionHeight + gap;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var c = 0; c < columns; c++) ...<Widget>[
              if (c > 0) SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var j = 0; j < buckets[c].length; j++)
                      Padding(
                        padding: EdgeInsets.only(top: j == 0 ? 0 : gap),
                        child: Reveal(
                          // Stagger by position in the column so each column
                          // settles top-down rather than all at once.
                          delay: Duration(milliseconds: 90 * (j + c)),
                          scale: 0.97,
                          child: ProjectCard(
                            project: widget.projects[buckets[c][j]],
                            aspectRatio:
                                _ratioOf(widget.projects[buckets[c][j]]),
                            onTap: () => _openLightbox(
                              context,
                              widget.projects,
                              buckets[c][j],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tile
// ---------------------------------------------------------------------------

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.aspectRatio,
    this.onTap,
  });

  final Project project;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 400);

    return HoverZoom(
      scale: 1.06,
      overlayOnHover: true,
      onTap: onTap,
      builder: (context, hovered, image) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  // Signals that the tile opens — appears only on hover, so it
                  // never sits on top of the photography at rest.
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: IgnorePointer(
                      child: AnimatedSlide(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        offset: hovered ? Offset.zero : const Offset(0, 0.35),
                        child: AnimatedOpacity(
                          duration: duration,
                          opacity: hovered ? 1 : 0,
                          child: Container(
                            width: 42,
                            height: 42,
                            color: AppColors.canvas,
                            child: const Icon(
                              Icons.add,
                              size: 19,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      Text(project.meta, style: AppText.bodySmall(context)),
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
      child: Photo(
        project.image,
        semanticLabel: '${project.name} — ${project.meta}',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lightbox
// ---------------------------------------------------------------------------

void _openLightbox(BuildContext context, List<Project> projects, int index) {
  final reduceMotion = context.reduceMotion;

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.slateDeep.withValues(alpha: 0.96),
    transitionDuration:
        reduceMotion ? Duration.zero : const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => _Lightbox(projects: projects, initial: index),
    transitionBuilder: (context, animation, _, child) {
      final eased = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: eased,
        child: reduceMotion
            ? child
            : ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(eased),
                child: child,
              ),
      );
    },
  );
}

/// Full-bleed viewer. The photograph is shown `contain`ed, so this is the one
/// place on the page where nothing is cropped at all.
class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.projects, required this.initial});

  final List<Project> projects;
  final int initial;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late int _index = widget.initial;

  bool get _canStep => widget.projects.length > 1;

  void _step(int delta) {
    if (!_canStep) return;
    setState(() {
      _index = (_index + delta) % widget.projects.length;
    });
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _step(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _step(1);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projects[_index];
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 340);
    final compact = !context.isDesktop;

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pick(mobile: 20.0, tablet: 36.0, desktop: 56.0),
              vertical: context.isMobile ? 16 : 28,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${(_index + 1).toString().padLeft(2, '0')}  /  '
                        '${widget.projects.length.toString().padLeft(2, '0')}',
                        style: AppText.eyebrow(
                          context,
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                    ),
                    _LightboxButton(
                      icon: Icons.close,
                      semanticLabel: 'Close',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      if (!compact && _canStep) ...[
                        _LightboxButton(
                          icon: Icons.arrow_back,
                          semanticLabel: 'Previous project',
                          onTap: () => _step(-1),
                        ),
                        const SizedBox(width: 24),
                      ],
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: duration,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Padding(
                            key: ValueKey<String>(project.image),
                            padding: EdgeInsets.symmetric(
                              vertical: context.isMobile ? 20 : 28,
                            ),
                            child: Photo(
                              project.image,
                              fit: BoxFit.contain,
                              semanticLabel:
                                  '${project.name} — ${project.meta}',
                            ),
                          ),
                        ),
                      ),
                      if (!compact && _canStep) ...[
                        const SizedBox(width: 24),
                        _LightboxButton(
                          icon: Icons.arrow_forward,
                          semanticLabel: 'Next project',
                          onTap: () => _step(1),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: duration,
                        child: Column(
                          key: ValueKey<String>(project.image),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              project.name,
                              style: AppText.h3(
                                context,
                                color: AppColors.textOnDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              project.year == null
                                  ? project.meta
                                  : '${project.meta}  ·  ${project.year}',
                              style: AppText.bodySmall(
                                context,
                                color: AppColors.textOnDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (compact && _canStep) ...[
                      _LightboxButton(
                        icon: Icons.arrow_back,
                        semanticLabel: 'Previous project',
                        onTap: () => _step(-1),
                      ),
                      const SizedBox(width: 12),
                      _LightboxButton(
                        icon: Icons.arrow_forward,
                        semanticLabel: 'Next project',
                        onTap: () => _step(1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LightboxButton extends StatefulWidget {
  const _LightboxButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  State<_LightboxButton> createState() => _LightboxButtonState();
}

class _LightboxButtonState extends State<_LightboxButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: context.reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.textOnDark
                  : const Color(0x00000000),
              border: Border.all(
                color: _hovered
                    ? AppColors.textOnDark
                    : AppColors.borderOnDark,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _hovered ? AppColors.textPrimary : AppColors.textOnDark,
            ),
          ),
        ),
      ),
    );
  }
}
