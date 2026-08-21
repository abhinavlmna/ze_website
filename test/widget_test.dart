import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/constants/contact_config.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('renders the hero statement and desktop navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ZeSpaceApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.textContaining('Spaces Designed'), findsOneWidget);
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Contact'), findsWidgets);
  });

  testWidgets('lays out without overflow on a 320px phone',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ZeSpaceApp());
    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Spaces Designed'), findsOneWidget);
  });

  testWidgets('hamburger opens the full-screen mobile menu',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ZeSpaceApp());
    await tester.pump(const Duration(seconds: 3));

    // "05" only appears as the fifth row of the overlay menu.
    expect(find.text('05'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('05'), findsOneWidget);
    expect(find.bySemanticsLabel('Close menu'), findsOneWidget);

    // Choosing a destination closes it again.
    // The footer carries the same labels, so target the overlay's own row.
    await tester.tap(find.text('Services').last);
    await tester.pumpAndSettle();
    expect(find.text('05'), findsNothing);
  });

  test('outbound links are built from the central config', () {
    expect(ContactConfig.whatsappUrl, 'https://wa.me/919567230909');
    expect(ContactConfig.telUrl, 'tel:+914843141824');
    expect(ContactConfig.mailtoUrl, startsWith('mailto:zespace7070@gmail.com'));
    expect(
      ContactConfig.instagramUrl,
      startsWith('https://www.instagram.com/ze_space_interior'),
    );
    expect(
      ContactConfig.facebookUrl,
      'https://www.facebook.com/share/1B48514bYA/?mibextid=wwXIfr',
    );
  });

  testWidgets('contact section offers both social links',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ZeSpaceApp());
    await tester.pump(const Duration(seconds: 3));

    expect(
      find.bySemanticsLabel('Ze Space Interior on Facebook'),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel('Ze Space Interior on Instagram'),
      findsWidgets,
    );
  });
}
