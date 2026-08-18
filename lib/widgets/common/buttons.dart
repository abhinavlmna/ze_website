import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text.dart';
import '../../constants/breakpoints.dart';

enum ButtonTone { solid, outline, outlineOnDark, solidLight }

/// Rectangular, letterspaced, quietly animated. No rounded corners — the
/// architecture of the page is orthogonal and the buttons follow it.
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = ButtonTone.solid,
    this.icon,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final ButtonTone tone;
  final IconData? icon;

  /// Stretch to the available width — used in the mobile stacked layout.
  final bool expand;
  final String? semanticLabel;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _hovered = false;

  ({Color background, Color foreground, Color border}) get _colors {
    switch (widget.tone) {
      case ButtonTone.solid:
        return (
          background: _hovered ? AppColors.teal : AppColors.slateDeep,
          foreground: AppColors.textOnDark,
          border: _hovered ? AppColors.teal : AppColors.slateDeep,
        );
      case ButtonTone.solidLight:
        return (
          background: _hovered ? AppColors.slateDeep : AppColors.surface,
          foreground:
              _hovered ? AppColors.textOnDark : AppColors.textPrimary,
          border: _hovered ? AppColors.slateDeep : AppColors.surface,
        );
      case ButtonTone.outline:
        return (
          background:
              _hovered ? AppColors.slateDeep : const Color(0x00000000),
          foreground:
              _hovered ? AppColors.textOnDark : AppColors.textPrimary,
          border: _hovered ? AppColors.slateDeep : AppColors.slateDeep,
        );
      case ButtonTone.outlineOnDark:
        return (
          background:
              _hovered ? AppColors.textOnDark : const Color(0x00000000),
          foreground:
              _hovered ? AppColors.textPrimary : AppColors.textOnDark,
          border: _hovered ? AppColors.textOnDark : AppColors.borderOnDark,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);
    final height = context.isMobile ? 52.0 : 56.0;

    final button = Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOut,
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? 26 : 34,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              mainAxisSize:
                  widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 17, color: colors.foreground),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    widget.label.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: AppText.action(context, color: colors.foreground),
                  ),
                ),
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOut,
                  width: _hovered ? 16 : 10,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 15,
                  color: colors.foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Understated text link: label, a hairline that grows on hover, and an arrow
/// that steps forward with it.
class ArrowLink extends StatefulWidget {
  const ArrowLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.dense = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool dense;

  @override
  State<ArrowLink> createState() => _ArrowLinkState();
}

class _ArrowLinkState extends State<ArrowLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.textPrimary;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 300);

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: widget.dense ? 6 : 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: AppText.action(context, color: color),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOut,
                      width: _hovered ? 20 : 12,
                    ),
                    Icon(Icons.arrow_forward, size: 15, color: color),
                  ],
                ),
                const SizedBox(height: 7),
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  height: 1,
                  width: _hovered ? 74 : 30,
                  color: color.withValues(alpha: _hovered ? 1 : 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
