import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'navbar.dart';

/// Full-screen navigation for phones and tablets. Items rise in one after
/// another; the panel itself wipes down from under the bar.
class MobileMenu extends StatelessWidget {
  const MobileMenu({
    super.key,
    required this.animation,
    required this.onNavigate,
  });

  final Animation<double> animation;
  final void Function(NavTarget target) onNavigate;

  @override
  Widget build(BuildContext context) {
    final entries = kNavLabels.entries.toList();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        if (t == 0) return const SizedBox.shrink();

        return IgnorePointer(
          ignoring: t < 0.5,
          child: Opacity(
            opacity: Curves.easeOut.transform(t.clamp(0.0, 1.0)),
            child: Container(
              color: AppColors.canvas,
              padding: EdgeInsets.only(
                top: context.navHeightCollapsed + 28,
                left: context.gutter,
                right: context.gutter,
                bottom: 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      _MenuRow(
                        index: i,
                        progress: t,
                        label: entries[i].value,
                        number: (i + 1).toString().padLeft(2, '0'),
                        onTap: () => onNavigate(entries[i].key),
                      ),
                    const SizedBox(height: 40),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 28),
                    Text(
                      'GET IN TOUCH',
                      style: AppText.eyebrow(context),
                    ),
                    const SizedBox(height: 18),
                    _MenuContactRow(
                      label: ContactConfig.phoneDisplay,
                      caption: 'WhatsApp',
                      onTap: () => LinkLauncher.whatsapp(),
                    ),
                    _MenuContactRow(
                      label: ContactConfig.email,
                      caption: 'Email',
                      onTap: () => LinkLauncher.email(),
                    ),
                    _MenuContactRow(
                      label: ContactConfig.instagramHandle,
                      caption: 'Instagram',
                      onTap: () => LinkLauncher.instagram(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      ContactConfig.addressLine,
                      style: AppText.bodySmall(context),
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.index,
    required this.progress,
    required this.label,
    required this.number,
    required this.onTap,
  });

  final int index;
  final double progress;
  final String label;
  final String number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Stagger: each row finishes a beat after the one above it.
    final start = 0.15 + index * 0.09;
    final local =
        ((progress - start) / (1 - start)).clamp(0.0, 1.0).toDouble();
    final eased = Curves.easeOutCubic.transform(local);

    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: Offset(0, (1 - eased) * 22),
        child: Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        number,
                        style: AppText.eyebrow(
                          context,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      label,
                      style: AppText.h2(context).copyWith(
                        fontSize: fluid(context, min: 32, max: 40),
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

class _MenuContactRow extends StatelessWidget {
  const _MenuContactRow({
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$caption: $label',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    caption,
                    style: AppText.bodySmall(context),
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.bodySmall(
                      context,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.north_east,
                  size: 15,
                  color: AppColors.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
