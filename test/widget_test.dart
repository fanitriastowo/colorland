import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:colorland/coloring/artwork_view.dart';
import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/coloring/picture.dart';
import 'package:colorland/main.dart';
import 'package:colorland/main.dart' as app;
import 'package:colorland/theme.dart';
import 'package:colorland/widgets/chunky.dart';

Future<Map<String, ColoringController>> _pumpApp(WidgetTester tester) async {
  final controllers = await tester.runAsync(loadControllers);
  await tester.pumpWidget(MyApp(controllers: controllers!));
  return controllers;
}

Future<ColoringController> _openFox(WidgetTester tester) async {
  final controllers = await _pumpApp(tester);
  await tester.ensureVisible(find.text('Animals'));
  await tester.tap(find.text('Animals'));
  await tester.pumpAndSettle();
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (_) async => null);
  });

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

  testWidgets('the Home card shows a finished picture and opens its canvas', (tester) async {
    final fox = (await tester.runAsync(loadControllers))!['fox']!;
    fox.filled.addAll(fox.picture.regions.map((r) => r.id));
    await tester.pumpWidget(MyApp(controllers: {'fox': fox}));

    await tester.tap(find.text('FINISHED'));
    await tester.pumpAndSettle();
    expect(find.text('15 / 15'), findsOneWidget);
  });

  testWidgets('a category opens its gallery, back returns home', (tester) async {
    await _pumpApp(tester);
    await tester.ensureVisible(find.text('Animals'));
    await tester.tap(find.text('Animals'));
    await tester.pumpAndSettle();

    expect(find.text('Owl'), findsOneWidget);
    expect(find.text('SVG slot'), findsNothing);

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

  testWidgets('fills survive a restart', (tester) async {
    final c = await _openFox(tester);
    final r = c.picture.regions.first;
    c.select(r.number!);
    c.tap(r);
    await tester.pumpAndSettle();

    final restarted = await tester.runAsync(loadControllers);
    expect(restarted!['fox']!.filled, {r.id});
  });

  testWidgets('More pictures goes to the gallery', (tester) async {
    final c = await _openFox(tester);
    await _complete(tester, c);

    await tester.tap(find.text('More pictures'));
    await tester.pumpAndSettle();
    expect(find.text('Animals'), findsOneWidget);
    expect(find.byType(CheckBadge), findsOneWidget);
  });

  testWidgets('main boots the app', (tester) async {
    await tester.runAsync(app.main);
    await tester.pump();
    expect(find.text("Let's color!"), findsOneWidget);
  });

  testWidgets('tapping the canvas shakes a wrong region and fills a right one', (tester) async {
    final c = await _openFox(tester);
    final rect = tester.getRect(find.byWidgetPredicate((w) => w is ArtworkView && w.interactive));
    final b = c.picture.bounds;
    final scale = rect.width / b.width < rect.height / b.height ? rect.width / b.width : rect.height / b.height;
    final origin = rect.center - b.center * scale;

    // The canvas hit-tests top-down and skips line art, like ArtworkView.
    final p = c.picture.labels.entries.reduce((a, b) => a.value.size > b.value.size ? a : b).value.at;
    final hit = c.picture.parts.reversed.firstWhere((r) => !r.fixed && r.path.contains(p));
    final at = origin + p * scale;

    c.select(hit.number == 1 ? 2 : 1);
    await tester.tapAt(at);
    await tester.pump();
    expect(c.wrongId, hit.id);
    await tester.pumpAndSettle();

    c.select(hit.number!);
    await tester.tapAt(at);
    await tester.pumpAndSettle();
    expect(c.filled, {hit.id});
  });

  testWidgets('palette swatches select, the sheet closes, back leaves the canvas', (tester) async {
    final c = await _openFox(tester);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    expect(c.selected, 3);

    await tester.tap(find.byType(RoundButton).last);
    await tester.pumpAndSettle();
    final close = find.descendant(of: find.byType(BottomSheet), matching: find.byType(ChunkyButton)).first;
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text('Colors'), findsNothing);

    await tester.tap(find.byType(RoundButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Owl'), findsOneWidget);
  });

  testWidgets('dragging off a button cancels the press', (tester) async {
    await _pumpApp(tester);
    await tester.ensureVisible(find.text('Animals'));
    final g = await tester.startGesture(tester.getCenter(find.text('Animals')));
    await tester.pump(kPressTimeout);
    await g.cancel();
    await tester.pumpAndSettle();
    expect(find.text('Owl'), findsNothing);
  });

  testWidgets('pictures without a controller show SVG slots, dark mode repaints', (tester) async {
    final controllers = await tester.runAsync(loadControllers);
    controllers!.remove(categories.first.pictures.first.id);
    await tester.pumpWidget(MyApp(controllers: controllers));
    expect(find.text('SVG'), findsOneWidget);

    await tester.ensureVisible(find.text('Animals'));
    await tester.tap(find.text('Animals'));
    await tester.pumpAndSettle();
    expect(find.text('SVG slot'), findsOneWidget);

    await tester.tap(find.text('Owl'));
    await tester.pumpAndSettle();
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();

    await _complete(tester, controllers['owl']!);
    expect(find.text('You did it!'), findsOneWidget);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pump(const Duration(seconds: 1));
  });

  test('AppExtraColors copies and lerps', () {
    const light = AppExtraColors.light, dark = AppExtraColors.dark;
    expect(light.copyWith().green, light.green);
    expect(light.copyWith(green: dark.green).green, dark.green);
    expect(light.lerp(null, 0.5), same(light));
    expect(light.lerp(dark, 1).track, dark.track);
  });
}
