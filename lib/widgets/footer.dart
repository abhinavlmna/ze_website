import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'common/brand_logo.dart';
import 'common/section.dart';
import 'common/social_links.dart';
import 'navbar.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onNavigate});

  final void Function(NavTarget target) onNavigate;

  @override
  Widget build(BuildContext context) {
    final stacked = !context.isDesktop;

    return ColoredBox(
      color: AppColors.slateDeep,
      child: Section(
        top: fluid(context, min: 64, max: 96),
        bottom: fluid(context, min: 36, max: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stacked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FooterBrand(),
                  const SizedBox(height: 44),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _FooterNav(onNavigate: onNavigate)),
                      const SizedBox(width: 24),
                      const Expanded(child: _FooterConnect()),
                    ],
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 6, child: _FooterBrand()),
                  const SizedBox(width: 40),
                  Expanded(flex: 3, child: _FooterNav(onNavigate: onNavigate)),
                  const SizedBox(width: 24),
                  const Expanded(flex: 3, child: _FooterConnect()),
                ],
              ),
            SizedBox(height: fluid(context, min: 44, max: 72)),
            Container(height: 1, color: AppColors.borderOnDark),
            const SizedBox(height: 24),
            if (context.isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ContactConfig.copyright,
                    style: AppText.bodySmall(
                      context,
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ContactConfig.addressDetail,
                    style: AppText.bodySmall(
                      context,
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ContactConfig.copyright,
                      style: AppText.bodySmall(
                        context,
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ),
                  Text(
                    ContactConfig.addressDetail,
                    style: AppText.bodySmall(
                      context,
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandLogo(onDark: true, markHeight: 34, textSize: 16),
        const SizedBox(height: 26),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            ContactConfig.tagline,
            style: AppText.bodySmall(
              context,
              color: AppColors.textOnDarkMuted,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            'Interiors and custom furniture, designed and produced under one '
            'roof in Kochi.',
            style: AppText.bodySmall(
              context,
              color: AppColors.textOnDarkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterNav extends StatelessWidget {
  const _FooterNav({required this.onNavigate});

  final void Function(NavTarget target) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NAVIGATE', style: AppText.eyebrow(context, color: AppColors.teal)),
        const SizedBox(height: 20),
        for (final entry in kNavLabels.entries)
          _FooterLink(
            label: entry.value,
            onTap: () => onNavigate(entry.key),
          ),
      ],
    );
  }
}

class _FooterConnect extends StatelessWidget {
  const _FooterConnect();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONNECT', style: AppText.eyebrow(context, color: AppColors.teal)),
        const SizedBox(height: 20),
        _FooterLink(
          label: 'WhatsApp',
          onTap: () => LinkLauncher.whatsapp(),
          external: true,
        ),
        _FooterLink(
          label: ContactConfig.phoneDisplay,
          onTap: () => LinkLauncher.phone(),
          external: true,
        ),
        _FooterLink(
          label: 'Email',
          onTap: () => LinkLauncher.email(),
          external: true,
        ),
        const SizedBox(height: 22),
        const SocialLinks(onDark: true),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
    this.external = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool external;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
        _hovered ? AppColors.textOnDark : AppColors.textOnDarkMuted;

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
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall(context, color: color),
                  ),
                ),
                if (widget.external) ...[
                  const SizedBox(width: 7),
                  Icon(Icons.north_east, size: 13, color: color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
