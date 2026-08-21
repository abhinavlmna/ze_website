import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/constants/app_colors.dart';
import 'package:untitled/widgets/hero.dart';
import 'package:untitled/widgets/hero_process.dart';

const String kHeadline = 'Spaces Designed\nWith Character.';
const IconData kDeliveryIcon = Icons.local_shipping_outlined;

Widget _harness() => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: HeroSection(onExploreWork: () {}, onGetInTouch: () {}),
        ),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2400));
}

Future<void> _settleMotion(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Opacity of the crossfade layer a widget sits in.
double _layerOpacity(WidgetTester tester, Finder of) {
  return tester
      .widget<Opacity>(find.ancestor(of: of, matching: find.byType(Opacity)).first)
      .opacity;
}

Future<void> _goToSlide(WidgetTester tester, int slide) async {
  final finder = find.bySemanticsLabel('Show slide $slide of 2');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settleMotion(tester);
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(1440, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
  });

  testWidgets('the headline belongs to slide one, the process to slide two',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    expect(find.byType(HeroProcess), findsOneWidget);
    expect(_layerOpacity(tester, find.text(kHeadline)), 1.0);
    expect(_layerOpacity(tester, find.byType(HeroProcess)), 0.0);

    await _goToSlide(tester, 2);

    expect(_layerOpacity(tester, find.text(kHeadline)), 0.0);
    expect(_layerOpacity(tester, find.byType(HeroProcess)), 1.0);
    expect(find.text('Material Delivery & Execution'), findsOneWidget);
  });

  testWidgets('a badge lifts and swells while hovered', (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);
    await _goToSlide(tester, 2);

    final badge = find.byIcon(kDeliveryIcon);
    AnimatedScale scaleOf() => tester.widget<AnimatedScale>(
          find.ancestor(of: badge, matching: find.byType(AnimatedScale)).first,
        );
    AnimatedSlide slideOf() => tester.widget<AnimatedSlide>(
          find.ancestor(of: badge, matching: find.byType(AnimatedSlide)).first,
        );
    BoxDecoration decorationOf() => tester
        .widget<AnimatedContainer>(
          find
              .ancestor(of: badge, matching: find.byType(AnimatedContainer))
              .first,
        )
        .decoration! as BoxDecoration;

    expect(scaleOf().scale, 1.0);
    expect(slideOf().offset, Offset.zero);
    // No teal at rest — every badge is a plain outline until hovered.
    expect(decorationOf().color!.a, 0.0);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(badge));
    await tester.pump();

    expect(scaleOf().scale, greaterThan(1.0));
    expect(slideOf().offset.dy, lessThan(0));
    expect(decorationOf().color, AppColors.teal);

    // And settles back once the pointer leaves.
    await mouse.moveTo(const Offset(5, 5));
    await tester.pump();

    expect(scaleOf().scale, 1.0);
    expect(slideOf().offset, Offset.zero);
  });

  testWidgets('badges are inert — a tap does nothing', (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);
    await _goToSlide(tester, 2);

    await tester.tap(find.byIcon(kDeliveryIcon), warnIfMissed: false);
    await _settleMotion(tester);

    // Still on the second slide, and nothing was pushed over the page.
    expect(_layerOpacity(tester, find.byType(HeroProcess)), 1.0);
    expect(find.byType(HeroSection), findsOneWidget);
  });

  testWidgets('a swipe starting on a badge still reaches the carousel',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);
    await _goToSlide(tester, 2);

    // Drag right, back towards the first slide, starting on a badge. The badge
    // reports hover but must not claim the drag.
    await tester.fling(
      find.byIcon(kDeliveryIcon),
      const Offset(400, 0),
      1200,
      warnIfMissed: false,
    );
    await _settleMotion(tester);

    expect(_layerOpacity(tester, find.text(kHeadline)), 1.0);
  });
}
