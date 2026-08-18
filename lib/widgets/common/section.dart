import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text.dart';
import '../../constants/breakpoints.dart';
import 'reveal.dart';

/// Vertical rhythm + centred editorial measure. Every full-width band on the
/// page goes through here so spacing stays consistent at every breakpoint.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.child,
    this.background,
    this.top,
    this.bottom,
    this.maxWidth = Breakpoints.contentMaxWidth,
  });

  final Widget child;
  final Color? background;
  final double? top;
  final double? bottom;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = context.gutter;
    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.only(
        top: top ?? context.sectionGap,
        bottom: bottom ?? context.sectionGap,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small uppercase label with a hairline rule — the studio's section marker.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.lineColor,
  });

  final String text;
  final Color? color;
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 1,
          margin: const EdgeInsets.only(right: 14, top: 1),
          color: lineColor ?? color ?? AppColors.teal,
        ),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: AppText.eyebrow(context, color: color),
          ),
        ),
      ],
    );
  }
}

/// Label + heading + optional lead paragraph, revealed as one unit.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.label,
    required this.title,
    this.lead,
    this.alignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.onDark = false,
    this.leadMaxWidth = 560,
  });

  final String? label;
  final String title;
  final String? lead;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;
  final bool onDark;
  final double leadMaxWidth;

  @override
  Widget build(BuildContext context) {
    final titleColor = onDark ? AppColors.textOnDark : AppColors.textPrimary;
    final leadColor = onDark ? AppColors.textOnDarkMuted : AppColors.textMuted;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (label != null) ...[
          Reveal(
            child: SectionLabel(
              label!,
              color: onDark ? AppColors.textOnDark : AppColors.teal,
              lineColor: onDark ? AppColors.borderOnDark : AppColors.teal,
            ),
          ),
          SizedBox(height: context.isMobile ? 18 : 24),
        ],
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Text(
            title,
            textAlign: textAlign,
            style: AppText.h2(context, color: titleColor),
          ),
        ),
        if (lead != null) ...[
          SizedBox(height: context.isMobile ? 20 : 26),
          Reveal(
            delay: const Duration(milliseconds: 160),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: leadMaxWidth),
              child: Text(
                lead!,
                textAlign: textAlign,
                style: AppText.body(context, color: leadColor),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
