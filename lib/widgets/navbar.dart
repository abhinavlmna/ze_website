import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'common/brand_logo.dart';
import 'common/page_scroll.dart';

enum NavTarget { home, about, services, projects, contact }

const Map<NavTarget, String> kNavLabels = <NavTarget, String>{
  NavTarget.home: 'Home',
  NavTarget.about: 'About',
  NavTarget.services: 'Services',
  NavTarget.projects: 'Projects',
  NavTarget.contact: 'Contact',
};

/// Sticky top navigation. Transparent while the hero is under it, then settles
/// onto a solid plate with a hairline rule as soon as the page moves.
class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    required this.onNavigate,
    required this.onToggleMenu,
    required this.menuOpen,
  });

  final void Function(NavTarget target) onNavigate;
  final VoidCallback onToggleMenu;
  final bool menuOpen;

  @override
  Widget build(BuildContext context) {
    final offset = PageScroll.maybeOf(context)?.offset;
    if (offset == null) return const SizedBox.shrink();

    return ValueListenableBuilder<double>(
      valueListenable: offset,
      builder: (context, value, _) {
        final condensed = value > 40;
        // While the menu is open the bar always sits on the light plate so the
        // logo and close button stay legible.
        final solid = condensed || menuOpen;
        final onDark = !solid;

        final duration = context.reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 350);

        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          height: solid ? context.navHeightCollapsed : context.navHeight,
          decoration: BoxDecoration(
            color: solid
                ? AppColors.canvas.withValues(alpha: 0.97)
                : const Color(0x00000000),
            border: Border(
              bottom: BorderSide(
                color: solid ? AppColors.border : const Color(0x00000000),
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth + context.gutter * 2,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.gutter),
                child: Row(
                  children: [
                    _LogoButton(
                      onDark: onDark,
                      condensed: condensed,
                      onTap: () => onNavigate(NavTarget.home),
                    ),
                    const Spacer(),
                    if (context.isDesktop)
                      _DesktopNav(onNavigate: onNavigate, onDark: onDark)
                    else
                      _MenuButton(
                        open: menuOpen,
                        onDark: onDark,
                        onTap: onToggleMenu,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoButton extends StatelessWidget {
  const _LogoButton({
    required this.onDark,
    required this.condensed,
    required this.onTap,
  });

  final bool onDark;
  final bool condensed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final markHeight = context.pick(
      mobile: condensed ? 22.0 : 25.0,
      tablet: condensed ? 25.0 : 28.0,
      desktop: condensed ? 27.0 : 31.0,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: BrandLogo(
          onDark: onDark,
          markHeight: markHeight,
          textSize: context.pick(mobile: 12.5, tablet: 13.5, desktop: 15.0),
        ),
      ),
    );
  }
}

class _DesktopNav extends StatelessWidget {
  const _DesktopNav({required this.onNavigate, required this.onDark});

  final void Function(NavTarget target) onNavigate;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in kNavLabels.entries)
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: _NavItem(
              label: entry.value,
              onDark: onDark,
              onTap: () => onNavigate(entry.key),
            ),
          ),
        const SizedBox(width: 40),
        _WhatsAppPill(onDark: onDark),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.onTap,
    required this.onDark,
  });

  final String label;
  final VoidCallback onTap;
  final bool onDark;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.onDark ? AppColors.textOnDark : AppColors.textPrimary;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppText.navItem(context, color: color),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  height: 1,
                  width: _hovered ? 22 : 0,
                  color: widget.onDark ? AppColors.textOnDark : AppColors.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsAppPill extends StatefulWidget {
  const _WhatsAppPill({required this.onDark});

  final bool onDark;

  @override
  State<_WhatsAppPill> createState() => _WhatsAppPillState();
}

class _WhatsAppPillState extends State<_WhatsAppPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final base =
        widget.onDark ? AppColors.textOnDark : AppColors.textPrimary;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Semantics(
      button: true,
      label: 'Message Ze Space Interior on WhatsApp',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => LinkLauncher.whatsapp(),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.teal : const Color(0x00000000),
              border: Border.all(
                color: _hovered
                    ? AppColors.teal
                    : (widget.onDark
                        ? AppColors.borderOnDark
                        : AppColors.border),
              ),
            ),
            child: Text(
              'WHATSAPP',
              style: AppText.action(
                context,
                color: _hovered ? AppColors.textOnDark : base,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two rules that cross into an X when the menu opens.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.open,
    required this.onDark,
    required this.onTap,
  });

  final bool open;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.textOnDark : AppColors.textPrimary;
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 300);

    return Semantics(
      button: true,
      label: open ? 'Close menu' : 'Open menu',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // 48×48 keeps the touch target comfortable on phones.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 26,
                height: 14,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      top: open ? 6.5 : 1,
                      left: 0,
                      right: 0,
                      child: AnimatedRotation(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        turns: open ? 0.125 : 0,
                        child: Container(height: 1.4, color: color),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      top: open ? 6.5 : 11,
                      left: 0,
                      right: 0,
                      child: AnimatedRotation(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        turns: open ? -0.125 : 0,
                        child: Container(height: 1.4, color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
