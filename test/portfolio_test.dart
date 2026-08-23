import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/data/projects.dart';
import 'package:untitled/widgets/common/page_scroll.dart';
import 'package:untitled/widgets/projects.dart';

/// Animations are disabled throughout: the reveal transforms tiles while they
/// settle, which would otherwise make every geometry assertion a race. The
/// widgets honour the platform's reduced-motion preference by rendering their
/// final state immediately, so this also exercises that path.
Widget _harness() {
  final controller = ScrollController();
  final offset = ValueNotifier<double>(0);
  addTearDown(controller.dispose);
  addTearDown(offset.dispose);
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: Scaffold(
          body: PageScroll(
            controller: controller,
            offset: offset,
            child: SingleChildScrollView(
              controller: controller,
              child: ProjectsSection(onEnquire: () {}),
            ),
          ),
        ),
      ),
    ),
  );
}

void _sizeTo(WidgetTester tester, Size size) {
  final view = tester.view;
  view.physicalSize = size;
  view.devicePixelRatio = 1.0;
  addTearDown(view.reset);
}

/// Number of distinct columns the tiles were dealt into.
int _columnCount(WidgetTester tester) {
  final lefts = <double>{};
  for (final element in find.byType(ProjectCard).evaluate()) {
    lefts.add(tester.getTopLeft(find.byWidget(element.widget)).dx.roundToDouble());
  }
  return lefts.length;
}

void main() {
  testWidgets('every project carries a category that exists', (tester) async {
    for (final project in kProjects) {
      expect(
        kProjectCategories.any((c) => c.id == project.categoryId),
        isTrue,
        reason: '"${project.name}" is tagged with an unknown category '
            '"${project.categoryId}"',
      );
    }
  });

  testWidgets('the gallery lays out without overflow at every breakpoint',
      (tester) async {
    const cases = <({Size size, int columns})>[
      (size: Size(320, 1400), columns: 1), // narrowest supported phone
      (size: Size(390, 1400), columns: 1),
      (size: Size(768, 1600), columns: 2), // tablet
      (size: Size(1440, 1600), columns: 3), // desktop
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
        find.byType(ProjectCard),
        findsNWidgets(kProjects.length),
        reason: 'not every project rendered at ${testCase.size.width}px wide',
      );
      expect(
        _columnCount(tester),
        testCase.columns,
        reason: 'wrong column count at ${testCase.size.width}px wide',
      );
    }
  });

  testWidgets('a category tab narrows the gallery to that category',
      (tester) async {
    _sizeTo(tester, const Size(1440, 1600));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNWidgets(kProjects.length));

    final bedrooms = projectsIn('bedrooms');
    expect(bedrooms, isNotEmpty, reason: 'test needs at least one bedroom');

    await tester.tap(find.text('BEDROOMS'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNWidgets(bedrooms.length));
    expect(find.text(bedrooms.first.name), findsOneWidget);

    // And back to everything.
    await tester.tap(find.text('ALL'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNWidgets(kProjects.length));
  });

  testWidgets('tapping a tile opens the lightbox and steps through it',
      (tester) async {
    _sizeTo(tester, const Size(1440, 1600));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProjectCard).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('01  /  ${kProjects.length.toString().padLeft(2, '0')}'),
        findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Next project').first);
    await tester.pumpAndSettle();

    expect(find.text('02  /  ${kProjects.length.toString().padLeft(2, '0')}'),
        findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close').first);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Close'), findsNothing);
  });
}
