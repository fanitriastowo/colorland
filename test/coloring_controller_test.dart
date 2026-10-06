import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/coloring/picture.dart';

/// Three side-by-side squares: two of color 1, one of color 2.
ColoringController _controller({Iterable<int> filled = const []}) {
  const info = PictureInfo('t', 'Test', palette: [
    PaletteColor(Color(0xFFFF0000), 'Red'),
    PaletteColor(Color(0xFF0000FF), 'Blue'),
  ]);
  Path square(double x) => Path()..addRect(Rect.fromLTWH(x, 0, 50, 50));
  return ColoringController(ColoringPicture(info, [
    Region(0, square(0), 1),
    Region(1, square(60), 1),
    Region(2, square(120), 2),
  ]), filled: filled);
}

void main() {
  test('saved fills seed progress and the first open number', () {
    final c = _controller(filled: [0, 1]);
    expect(c.filled, {0, 1});
    expect(c.selected, 2);
    expect(c.canUndo, isFalse);
    c.dispose();
  });

  test('filling the selected number works, a wrong number does not', () {
    final c = _controller();
    final r = c.picture.parts;
    expect(c.selected, 1);

    c.tap(r[2]);
    expect(c.filled, isEmpty);
    expect(c.wrongId, 2);

    c.tap(r[0]);
    expect(c.filled, {0});
    expect(c.popId, 0);
    c.dispose();
  });

  test('eraser un-fills, and undo/redo walk the history', () {
    final c = _controller();
    final r = c.picture.parts;
    c.tap(r[0]);
    c.toggleEraser();
    c.tap(r[0]);
    expect(c.filled, isEmpty);

    c.undo();
    expect(c.filled, {0});
    c.undo();
    expect(c.filled, isEmpty);
    expect(c.canUndo, isFalse);

    c.redo();
    expect(c.filled, {0});
    expect(c.canRedo, isTrue);

    c.toggleEraser();
    c.tap(r[1]);
    expect(c.canRedo, isFalse, reason: 'a new action drops redo entries');
    c.dispose();
  });

  // testWidgets gives a fake clock for the controller's timers.
  testWidgets('auto-advances to the next unfinished number, then completes', (tester) async {
    final c = _controller();
    final r = c.picture.parts;
    c.tap(r[0]);
    c.tap(r[1]);
    expect(c.selected, 1);
    await tester.pump(const Duration(milliseconds: 350));
    expect(c.selected, 2);

    c.tap(r[2]);
    expect(c.isComplete, isTrue);
    expect(c.progress, 1);
    c.dispose();
  });

  testWidgets('hint turns off the eraser and times out', (tester) async {
    final c = _controller();
    c.toggleEraser();
    c.showHint();
    expect(c.eraser, isFalse);
    expect(c.hint, isTrue);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(c.hint, isFalse);
    c.dispose();
  });

  test('parse numbers palette fills, keeps other fills as line art', () {
    const info = PictureInfo('t', 'Test', palette: [
      PaletteColor(Color(0xFFFF0000), 'Red'),
      PaletteColor(Color(0xFF0000FF), 'Blue'),
    ]);
    const svg = '<svg>'
        '<path d="M0 0H50V50H0Z" style="fill:#ff0000"/>'
        '<path d="M60 0H110V50H60Z" style="fill:#000000"/>'
        '<path d="M120 0H170V50H120Z" style="fill:#0000FF"/>'
        '<path d="M0 0H9V9Z"/>'
        '</svg>';
    final p = ColoringPicture.parse(info, svg);

    expect([for (final r in p.parts) r.number], [1, null, 2]);
    expect(p.parts[1].fixed, isTrue);
    expect([for (final r in p.regions) r.id], [0, 2]);
    expect(p.numbers, [1, 2]);
    expect(p.bounds, const Rect.fromLTRB(-4, -4, 174, 54));
    expect(p.labels.keys, [0, 2]);
    for (final MapEntry(:key, :value) in p.labels.entries) {
      expect(p.parts[key].path.contains(value.at), isTrue);
    }
  });

  test('taps on filled regions, and erasing unfilled ones, do nothing', () {
    final c = _controller();
    final r = c.picture.parts;
    c.tap(r[0]);
    c.tap(r[0]);
    expect(c.canRedo, isFalse);
    c.undo();
    expect(c.canUndo, isFalse, reason: 'the second tap added no history');

    c.toggleEraser();
    c.tap(r[1]);
    expect(c.canUndo, isFalse);
    c.dispose();
  });

  test('totals, select, open and reset', () {
    final c = _controller();
    final r = c.picture.parts;
    expect(c.totalOf(1), 2);
    expect(c.totalOf(2), 1);

    c.toggleEraser();
    c.select(2);
    expect(c.selected, 2);
    expect(c.eraser, isFalse);

    c.select(1);
    c.tap(r[0]);
    c.tap(r[1]);
    expect(c.filledOf(1), 2);
    c.select(1);
    c.toggleEraser();
    c.open();
    expect(c.selected, 2, reason: 'open picks the first unfinished number');
    expect(c.eraser, isFalse);

    c.showHint();
    c.reset();
    expect(c.filled, isEmpty);
    expect(c.canUndo, isFalse);
    expect(c.selected, 1);
    expect(c.hint, isFalse);
    c.dispose();
  });

  testWidgets('a wrong tap shakes briefly', (tester) async {
    final c = _controller();
    c.tap(c.picture.parts[2]);
    expect(c.wrongId, 2);
    await tester.pump(const Duration(milliseconds: 450));
    expect(c.wrongId, isNull);
    c.dispose();
  });

  testWidgets('every catalog picture loads and uses every palette number', (tester) async {
    for (final info in categories.expand((c) => c.pictures)) {
      final picture = await ColoringPicture.load(info);
      expect(picture.regions.map((r) => r.number).toSet(), picture.numbers.toSet(), reason: info.id);
    }
  });
}
