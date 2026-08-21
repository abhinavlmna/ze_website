import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/widgets/hero.dart';
import 'package:untitled/widgets/hero_carousel.dart'
    show HeroSlideCaption, kHeroSlideInterval;

const String kFirst = '100% CUSTOMIZED DESIGNS';
const String kSecond = 'PROJECT COMPLETION IN 45 WORKING DAYS';
const String kHeadline = 'Spaces Designed\nWith Character.';

Widget _harness({bool reduceMotion = false}) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: HeroSection(onExploreWork: () {}, onGetInTouch: () {}),
        ),
      ),
    );

/// Runs out the 2.2s entrance. The hero's scroll cue repeats forever, so
/// [WidgetTester.pumpAndSettle] can never return here — advance by hand.
///
/// Deliberately stops short of the first auto-advance, which is timed from the
/// moment this entrance completes.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2400));
}

/// Enough for a swipe, a jump or a crossfade to come to rest — and short
/// enough not to run into the next auto-advance.
Future<void> _settleMotion(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Runs the clock past one hold, then far enough for the transition it
/// triggers to finish.
Future<void> _waitForAutoAdvance(WidgetTester tester) async {
  await tester.pump(kHeroSlideInterval);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// The indicator is pinned to the bottom of the hero, which the test font's
/// metrics can push below the fold — scroll it in before tapping.
Future<void> _tapIndicator(WidgetTester tester, int slide) async {
  final finder = find.bySemanticsLabel('Show slide $slide of 2');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

/// The opacity of the caption's own crossfade layer — the nearest [Opacity]
/// ancestor, inside the entrance fade the hero wraps everything in.
double _captionOpacity(WidgetTester tester, String text) {
  return tester
      .widget<Opacity>(
        find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
      )
      .opacity;
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

  testWidgets('both slides and captions are laid out', (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text(kFirst), findsOneWidget);
    expect(find.text(kSecond), findsOneWidget);

    // Only the first caption is visible on load.
    expect(_captionOpacity(tester, kFirst), 1.0);
    expect(_captionOpacity(tester, kSecond), 0.0);
  });

  testWidgets('the first hold starts only once the hero has arrived',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    // Just short of a full hold after the entrance: still on the first frame.
    await tester.pump(kHeroSlideInterval - const Duration(milliseconds: 400));
    expect(_captionOpacity(tester, kFirst), 1.0);
  });

  testWidgets('a swipe starting over the headline still moves the carousel',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    // Drag from the headline. warnIfMissed is off precisely because the
    // headline *should* miss: the copy is wrapped in an IgnorePointer so the
    // gesture falls through to the carousel underneath it.
    await tester.fling(
      find.text(kHeadline),
      const Offset(-400, 0),
      1200,
      warnIfMissed: false,
    );
    await _settleMotion(tester);

    expect(_captionOpacity(tester, kFirst), 0.0);
    expect(_captionOpacity(tester, kSecond), 1.0);
  });

  testWidgets('tapping an indicator jumps to that slide', (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    await _tapIndicator(tester, 2);
    await _settleMotion(tester);
    expect(_captionOpacity(tester, kSecond), 1.0);

    await _tapIndicator(tester, 1);
    await _settleMotion(tester);
    expect(_captionOpacity(tester, kFirst), 1.0);
  });

  testWidgets('advances on its own, and wraps back round', (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);
    expect(_captionOpacity(tester, kFirst), 1.0);

    await _waitForAutoAdvance(tester);
    expect(_captionOpacity(tester, kSecond), 1.0);

    await _waitForAutoAdvance(tester);
    expect(_captionOpacity(tester, kFirst), 1.0);
  });

  testWidgets('a held drag stops the timer until it is released',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    // Take hold of the photograph and keep hold of it.
    final gesture = await tester.startGesture(const Offset(720, 300));
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();

    // Well past a hold — nothing should have moved on its own.
    await tester.pump(kHeroSlideInterval * 2);
    await tester.pump(const Duration(milliseconds: 150));
    expect(_captionOpacity(tester, kSecond), 0.0);

    await gesture.up();
    await _settle(tester);

    // Released, the carousel picks up where it left off.
    await _waitForAutoAdvance(tester);
    expect(_captionOpacity(tester, kSecond), 1.0);
  });

  testWidgets('reduced motion leaves the carousel still', (tester) async {
    await tester.pumpWidget(_harness(reduceMotion: true));
    await _settle(tester);

    await _waitForAutoAdvance(tester);
    await _waitForAutoAdvance(tester);
    expect(_captionOpacity(tester, kFirst), 1.0);
    expect(_captionOpacity(tester, kSecond), 0.0);
  });

  testWidgets('caption row keeps a stable height across slides',
      (tester) async {
    await tester.pumpWidget(_harness());
    await _settle(tester);

    final before = tester.getSize(find.byType(HeroSlideCaption));
    await _tapIndicator(tester, 2);
    await _settleMotion(tester);

    expect(tester.getSize(find.byType(HeroSlideCaption)), before);
  });
}
