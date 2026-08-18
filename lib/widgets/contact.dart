import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text.dart';
import '../constants/breakpoints.dart';
import '../constants/contact_config.dart';
import 'common/buttons.dart';
import 'common/reveal.dart';
import 'common/section.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stacked = !context.isDesktop;

    return Section(
      background: AppColors.sand,
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ContactDetails(),
                SizedBox(height: context.isMobile ? 52 : 64),
                const Reveal(child: _EnquiryForm()),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _ContactDetails()),
                SizedBox(width: 88),
                Expanded(flex: 6, child: Reveal(child: _EnquiryForm())),
              ],
            ),
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          label: 'Contact',
          title: 'Start a Conversation',
          lead:
              'Tell us about the space — where it is, how it will be used, and '
              'what you would like it to feel like. We will take it from there.',
          leadMaxWidth: 460,
        ),
        SizedBox(height: context.isMobile ? 40 : 52),
        Reveal(
          delay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ContactConfig.companyNameTitle,
                style: AppText.h3(context),
              ),
              const SizedBox(height: 8),
              Text(
                ContactConfig.addressLine,
                style: AppText.bodySmall(context),
              ),
              const SizedBox(height: 4),
              Text(
                ContactConfig.shortTagline,
                style: AppText.bodySmall(context),
              ),
            ],
          ),
        ),
        SizedBox(height: context.isMobile ? 34 : 44),
        Reveal(
          delay: const Duration(milliseconds: 180),
          child: Column(
            children: [
              _ContactRow(
                label: 'WhatsApp',
                value: ContactConfig.phoneDisplay,
                onTap: () => LinkLauncher.whatsapp(),
                isFirst: true,
              ),
              _ContactRow(
                label: 'Email',
                value: ContactConfig.email,
                onTap: () => LinkLauncher.email(),
              ),
              _ContactRow(
                label: 'Instagram',
                value: ContactConfig.instagramHandle,
                onTap: () => LinkLauncher.instagram(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatefulWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isFirst = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Semantics(
      button: true,
      label: '${widget.label}: ${widget.value}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: _hovered ? 10 : 0,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: widget.isFirst
                    ? const BorderSide(color: AppColors.border)
                    : BorderSide.none,
                bottom: BorderSide(
                  color: _hovered ? AppColors.teal : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: context.isMobile ? 112 : 130,
                  child: Text(
                    widget.label.toUpperCase(),
                    style: AppText.eyebrow(
                      context,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.value,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall(
                      context,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedSlide(
                  duration: duration,
                  curve: Curves.easeOut,
                  offset: Offset(_hovered ? 0.2 : 0, _hovered ? -0.2 : 0),
                  child: Icon(
                    Icons.north_east,
                    size: 16,
                    color: _hovered ? AppColors.teal : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Deliberately minimal: three fields that compose a WhatsApp message. No
/// backend, no waiting on an inbox — the enquiry lands where it gets answered.
class _EnquiryForm extends StatefulWidget {
  const _EnquiryForm();

  @override
  State<_EnquiryForm> createState() => _EnquiryFormState();
}

class _EnquiryFormState extends State<_EnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _message = TextEditingController();

  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final buffer = StringBuffer()
      ..writeln('Hello Ze Space Interior,')
      ..writeln()
      ..writeln('Name: ${_name.text.trim()}')
      ..writeln('Contact: ${_contact.text.trim()}');

    final message = _message.text.trim();
    if (message.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(message);
    }

    LinkLauncher.whatsapp(buffer.toString());
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.pick(
        mobile: 26.0,
        tablet: 36.0,
        desktop: 44.0,
      )),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send an enquiry', style: AppText.h3(context)),
            const SizedBox(height: 10),
            Text(
              'Three fields. It opens WhatsApp with your message ready to send.',
              style: AppText.bodySmall(context),
            ),
            const SizedBox(height: 32),
            _Field(
              controller: _name,
              label: 'Name',
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please add your name'
                  : null,
            ),
            const SizedBox(height: 24),
            _Field(
              controller: _contact,
              label: 'Phone or email',
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please add a phone number or email'
                  : null,
            ),
            const SizedBox(height: 24),
            _Field(
              controller: _message,
              label: 'About the space (optional)',
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 34),
            ActionButton(
              label: 'Send via WhatsApp',
              onPressed: _submit,
              expand: context.isMobile,
            ),
            if (_sent) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.check, size: 16, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Opening WhatsApp — press send there to reach us.',
                      style: AppText.bodySmall(context, color: AppColors.teal),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      textInputAction: textInputAction,
      cursorColor: AppColors.teal,
      style: AppText.bodySmall(context, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.bodySmall(context),
        floatingLabelStyle: AppText.eyebrow(context, color: AppColors.teal)
            .copyWith(letterSpacing: 1.6),
        isDense: true,
        // Keeps the label at the top of the multi-line message field.
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.only(bottom: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.teal, width: 1.4),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.coral),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.coral, width: 1.4),
        ),
        errorStyle: AppText.bodySmall(context, color: AppColors.coral)
            .copyWith(fontSize: 12, height: 1.4),
      ),
    );
  }
}
