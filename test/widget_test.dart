import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/main.dart';
import 'package:colorland/widgets/chunky.dart';

Future<Map<String, ColoringController>> _pumpApp(WidgetTester tester) async {
  final controllers = await tester.runAsync(loadControllers);
  await tester.pumpWidget(MyApp(controllers: controllers!));
  return controllers;
}

Future<ColoringController> _openFox(WidgetTester tester) async {
  final controllers = await _pumpApp(tester);
  await tester.tap(find.text('Fox'));
  await tester.pumpAndSettle();
  return controllers['fox']!;
}

/// Fills the whole picture and waits for the celebration route. The confetti
/// never stops, so this pumps fixed durations instead of pumpAndSettle.
Future<void> _complete(WidgetTester tester, ColoringController c) async {
  for (final r in c.picture.regions) {
    c.select(r.number!);
    c.tap(r);
  }
  await tester.pump(const Duration(milliseconds: 750));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('Home opens the fox canvas', (WidgetTester tester) async {
    await _openFox(tester);

    expect(find.text('0 / 15'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('Home shows the header in dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _pumpApp(tester);

    expect(find.text("Let's color!"), findsOneWidget);
    expect(find.text('NEW PICTURE'), findsOneWidget);
  });

  testWidgets('a category opens its gallery, back returns home', (tester) async {
    await _pumpApp(tester);
    await tester.ensureVisible(find.text('Animals'));
    await tester.tap(find.text('Animals'));
    await tester.pumpAndSettle();

    expect(find.text('Owl'), findsOneWidget);
    expect(find.text('SVG slot'), findsNWidgets(5));

    await tester.tap(find.byType(RoundButton).first);
    await tester.pumpAndSettle();
    expect(find.text("Let's color!"), findsOneWidget);
  });

  testWidgets('canvas tools and the Colors sheet', (tester) async {
    final c = await _openFox(tester);

    await tester.tap(find.byType(RoundButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('Gray'), findsOneWidget);

    await tester.tap(find.text('Red'));
    await tester.pumpAndSettle();
    expect(find.text('Colors'), findsNothing);
    expect(c.selected, 2);

    c.tap(c.picture.regions.firstWhere((r) => r.number == 2));
    await tester.pumpAndSettle();
    expect(find.text('1 / 15'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 15'), findsOneWidget);
    await tester.tap(find.text('Redo'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 15'), findsOneWidget);

    await tester.tap(find.text('Eraser'));
    await tester.pumpAndSettle();
    expect(find.text('Tap to erase'), findsOneWidget);

    await tester.tap(find.text('Hint'));
    await tester.pump();
    expect(c.hint, isTrue);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(c.hint, isFalse);
  });

  testWidgets('finishing celebrates, Again starts over', (tester) async {
    final c = await _openFox(tester);
    await _complete(tester, c);

    expect(find.text('You did it!'), findsOneWidget);
    expect(find.text('Fox is all colored in'), findsOneWidget);

    await tester.tap(find.text('Again'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 15'), findsOneWidget);
  });

  testWidgets('More pictures goes to the gallery', (tester) async {
    final c = await _openFox(tester);
    await _complete(tester, c);

    await tester.tap(find.text('More pictures'));
    await tester.pumpAndSettle();
    expect(find.text('Animals'), findsOneWidget);
    expect(find.byType(CheckBadge), findsOneWidget);
  });
}
