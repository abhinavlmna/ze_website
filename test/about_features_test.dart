import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/constants/app_colors.dart';
import 'package:untitled/widgets/about.dart';

const List<IconData> kFeatureIcons = <IconData>[
  Icons.auto_awesome_outlined,
  Icons.verified_outlined,
  Icons.workspace_premium_outlined,
  Icons.hourglass_top_rounded,
  Icons.headset_mic_outlined,
];

Widget _harness() => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AboutSection(onDiscover: () {}),
        ),
      ),
    );

void _sizeTo(WidgetTester tester, Size size) {
  final view = tester.view;
  view.physicalSize = size;
  view.devicePixelRatio = 1.0;
  addTearDown(view.reset);
}

/// Number of distinct rows the five cards were laid out on.
int _rowCount(WidgetTester tester) {
  final tops = <double>{};
  for (final icon in kFeatureIcons) {
    tops.add(tester.getTopLeft(find.byIcon(icon)).dy.roundToDouble());
  }
  return tops.length;
}

/// The plate behind an icon — the first decorated ancestor it has.
BoxDecoration _plateOf(WidgetTester tester, IconData icon) {
  return tester
      .widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byIcon(icon),
              matching: find.byType(DecoratedBox),
            )
            .first,
      )
      .decoration as BoxDecoration;
}

void main() {
  testWidgets('the grid lays out without overflow at every breakpoint',
      (tester) async {
    // 320 wide is the narrowest supported phone, where the cards step down to
    // their compact metrics; 1440 is the widest the content ever gets.
    const cases = <({Size size, int rows})>[
      (size: Size(320, 900), rows: 3), // two across, 2 + 2 + 1
      (size: Size(390, 900), rows: 3), // two across
      (size: Size(768, 1200), rows: 2), // three across, 3 + 2
      (size: Size(1440, 900), rows: 2), // three across, beside the copy
    ];

    for (final testCase in cases) {
      _sizeTo(tester, testCase.size);
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'overflowed at ${testCase.size.width}px wide',
      );
      expect(
        _rowCount(tester),
        testCase.rows,
        reason: 'wrong column count at ${testCase.size.width}px wide',
      );

      // And the content itself survived the narrowest case.
      expect(find.text('Bespoke Grade'), findsOneWidget);
      expect(find.text('ESTABLISHED'), findsOneWidget);
    }
  });

  testWidgets('a card lifts and turns teal while hovered', (tester) async {
    _sizeTo(tester, const Size(1440, 900));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    const icon = Icons.verified_outlined;
    final restingTop = tester.getTopLeft(find.byIcon(icon)).dy;

    expect(_plateOf(tester, icon).color, AppColors.tealWash);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byIcon(icon)));
    await tester.pumpAndSettle();

    expect(_plateOf(tester, icon).color, AppColors.teal);
    expect(
      tester.getTopLeft(find.byIcon(icon)).dy,
      lessThan(restingTop),
      reason: 'the card should lift under the pointer',
    );

    // And settles all the way back when the pointer leaves.
    await mouse.moveTo(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(_plateOf(tester, icon).color, AppColors.tealWash);
    expect(tester.getTopLeft(find.byIcon(icon)).dy, restingTop);
  });

  testWidgets('hovering one card leaves its neighbours alone', (tester) async {
    _sizeTo(tester, const Size(1440, 900));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(find.byIcon(kFeatureIcons.first)));
    await tester.pumpAndSettle();

    expect(_plateOf(tester, kFeatureIcons.first).color, AppColors.teal);
    expect(_plateOf(tester, kFeatureIcons[1]).color, AppColors.tealWash);
  });
}
