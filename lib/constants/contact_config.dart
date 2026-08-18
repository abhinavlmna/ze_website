import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Single source of truth for everything the outside world can reach.
///
/// Change a value here and it updates the navbar, hero, CTA, contact section
/// and footer at once — nothing below is duplicated anywhere else in the app.
class ContactConfig {
  ContactConfig._();

  // ---- Brand ---------------------------------------------------------------
  static const String companyName = 'ZE SPACE INTERIOR';
  static const String companyNameTitle = 'Ze Space Interior';
  static const String tagline = 'Interior Design & Furniture Production | Kochi';
  static const String shortTagline = 'Interior Design & Furniture Production';

  // ---- Location ------------------------------------------------------------
  static const String city = 'Kochi';
  static const String state = 'Kerala';
  static const String addressLine = 'Kochi, Kerala';
  static const String addressDetail = 'Ernakulam, Kerala, India';

  // ---- WhatsApp ------------------------------------------------------------
  /// Country code + number, digits only — this is what wa.me expects.
  static const String whatsappCountryCode = '91';
  static const String whatsappNumber = '7025911389';

  /// Human-readable form used in the UI.
  static const String phoneDisplay = '+91 70259 11389';

  static String get whatsappUrl =>
      'https://wa.me/$whatsappCountryCode$whatsappNumber';

  /// Opens WhatsApp with an optional pre-filled first message.
  static String whatsappUrlWithMessage(String message) {
    final text = Uri.encodeComponent(message);
    return '$whatsappUrl?text=$text';
  }

  static const String whatsappDefaultMessage =
      "Hello Ze Space Interior, I'd like to talk about an interior project.";

  // ---- Instagram -----------------------------------------------------------
  static const String instagramHandle = '@aa__d_h_i';
  static const String instagramUrl = 'https://www.instagram.com/aa__d_h_i';

  // ---- Email ---------------------------------------------------------------
  static const String email = 'abhinavkk61@gmail.com';
  static const String emailSubject = 'Interior design enquiry';

  static String get mailtoUrl =>
      'mailto:$email?subject=${Uri.encodeComponent(emailSubject)}';

  // ---- Copyright -----------------------------------------------------------
  static const String copyright =
      '© 2026 Ze Space Interior. All rights reserved.';
}

/// Thin wrapper around [launchUrl] so every outbound link behaves the same way
/// and a failure never throws into the widget tree.
class LinkLauncher {
  LinkLauncher._();

  static Future<void> open(String url, {bool newTab = true}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: newTab ? '_blank' : '_self',
      );
    } catch (error) {
      debugPrint('Could not open $url: $error');
    }
  }

  static Future<void> whatsapp([String? message]) => open(
        message == null || message.trim().isEmpty
            ? ContactConfig.whatsappUrlWithMessage(
                ContactConfig.whatsappDefaultMessage,
              )
            : ContactConfig.whatsappUrlWithMessage(message),
      );

  static Future<void> instagram() => open(ContactConfig.instagramUrl);

  /// Mail links replace the current context rather than opening a blank tab
  /// that would be left behind after the mail client takes over.
  static Future<void> email() =>
      open(ContactConfig.mailtoUrl, newTab: false);
}
