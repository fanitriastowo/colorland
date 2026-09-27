import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/coloring/picture.dart';

/// Three side-by-side squares: two of color 1, one of color 2.
ColoringController _controller() {
  const info = PictureInfo('t', 'Test', palette: [
    PaletteColor(Color(0xFFFF0000), 'Red'),
    PaletteColor(Color(0xFF0000FF), 'Blue'),
  ]);
  Path square(double x) => Path()..addRect(Rect.fromLTWH(x, 0, 50, 50));
  return ColoringController(ColoringPicture(info, [
    Region(0, square(0), 1),
    Region(1, square(60), 1),
    Region(2, square(120), 2),
  ]));
}

void main() {
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
}
