import 'package:flutter/material.dart';

import '../theme.dart';
import 'coloring_controller.dart';
import 'picture.dart';

/// Renders a picture with the current fills. Interactive on the canvas
/// (taps, labels, animations); a static render everywhere else.
class ArtworkView extends StatefulWidget {
  const ArtworkView(this.controller, {super.key, this.interactive = false});

  final ColoringController controller;
  final bool interactive;

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> with TickerProviderStateMixin {
  late final _fade = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350), value: 1);
  late final _pop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400), value: 1);
  late final _shake = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420), value: 1);
  late final _hint = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));

  /// Per-region fill color tween, driven by [_fade].
  final Map<int, Color> _from = {}, _to = {};
  int? _lastPop, _lastWrong;
  bool _lastHint = false;

  ColoringController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    for (final r in c.picture.regions) {
      _from[r.id] = _to[r.id] = _target(r);
    }
    if (widget.interactive) c.addListener(_onChange);
  }

  @override
  void dispose() {
    c.removeListener(_onChange);
    _fade.dispose();
    _pop.dispose();
    _shake.dispose();
    _hint.dispose();
    super.dispose();
  }

  Color _target(Region r) {
    if (c.filled.contains(r.id)) return c.picture.info.palette[r.number! - 1].color;
    final tinted = widget.interactive && !c.eraser && r.number == c.selected;
    return tinted ? ArtColors.tint : ArtColors.paper;
  }

  Color _current(int id) => Color.lerp(_from[id], _to[id], Curves.ease.transform(_fade.value))!;

  void _onChange() {
    var changed = false;
    for (final r in c.picture.regions) {
      if (_to[r.id] != _target(r)) changed = true;
    }
    if (changed) {
      for (final r in c.picture.regions) {
        _from[r.id] = _current(r.id);
        _to[r.id] = _target(r);
      }
      _fade.forward(from: 0);
    }
    if (c.popId != _lastPop && c.popId != null) _pop.forward(from: 0);
    if (c.wrongId != _lastWrong && c.wrongId != null) _shake.forward(from: 0);
    if (c.hint != _lastHint) {
      c.hint ? _hint.repeat(count: 3) : _hint.reset();
    }
    _lastPop = c.popId;
    _lastWrong = c.wrongId;
    _lastHint = c.hint;
  }

  void _onTapUp(TapUpDetails d, Size size) {
    final p = _Fit(c.picture.bounds, size).toPicture(d.localPosition);
    for (final r in c.picture.parts.reversed) {
      if (r.fixed || !r.path.contains(p)) continue;
      c.tap(r);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final size = box.biggest;
      final paint = CustomPaint(
        size: size,
        painter: _ArtworkPainter(
          state: this,
          repaint: Listenable.merge([c, _fade, _pop, _shake, _hint]),
        ),
      );
      if (!widget.interactive) return paint;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _onTapUp(d, size),
        child: paint,
      );
    });
  }
}

/// "Contain" fit of the picture bounds into the widget.
class _Fit {
  _Fit(this.bounds, Size size)
      : scale = (size.width / bounds.width) < (size.height / bounds.height)
            ? size.width / bounds.width
            : size.height / bounds.height {
    offset = Offset(
      (size.width - bounds.width * scale) / 2,
      (size.height - bounds.height * scale) / 2,
    );
  }

  final Rect bounds;
  final double scale;
  late final Offset offset;

  Offset toPicture(Offset local) => (local - offset) / scale + bounds.topLeft;

  void apply(Canvas canvas) {
    canvas
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..translate(-bounds.left, -bounds.top);
  }
}

final _popCurve = TweenSequence([
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 45),
  TweenSequenceItem(tween: Tween(begin: 1.07, end: 1.0), weight: 55),
]).chain(CurveTween(curve: Curves.easeOut));

final _shakeCurve = TweenSequence([
  for (final (a, b) in [(0.0, -5.0), (-5.0, 5.0), (5.0, -3.0), (-3.0, 3.0), (3.0, 0.0)])
    TweenSequenceItem(tween: Tween(begin: a, end: b), weight: 1),
]);

class _ArtworkPainter extends CustomPainter {
  _ArtworkPainter({required this.state, required super.repaint});

  final _ArtworkViewState state;

  @override
  void paint(Canvas canvas, Size size) {
    final c = state.c;
    final interactive = state.widget.interactive;
    canvas.save();
    _Fit(c.picture.bounds, size).apply(canvas);

    final fill = Paint();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..color = ArtColors.line;
    final hintT = Curves.easeInOut.transform(1 - (2 * state._hint.value - 1).abs());

    for (final r in c.picture.parts) {
      if (r.fixed) {
        canvas.drawPath(r.path, fill..color = ArtColors.line);
        continue;
      }
      canvas.save();
      if (interactive && r.id == c.wrongId) {
        canvas.translate(_shakeCurve.evaluate(state._shake), 0);
      } else if (interactive && r.id == c.popId) {
        final s = _popCurve.evaluate(state._pop);
        final center = r.path.getBounds().center;
        canvas
          ..translate(center.dx, center.dy)
          ..scale(s)
          ..translate(-center.dx, -center.dy);
      }
      final hinted = interactive &&
          c.hint &&
          !c.eraser &&
          r.number == c.selected &&
          !c.filled.contains(r.id);
      canvas.drawPath(r.path, fill..color = interactive ? state._current(r.id) : state._target(r));
      canvas.drawPath(
        r.path,
        stroke
          ..strokeWidth = hinted ? 2.2 + (7 - 2.2) * hintT : (interactive ? 2.2 : 2.6)
          ..color = hinted ? Color.lerp(ArtColors.line, ArtColors.hint, hintT)! : ArtColors.line,
      );
      canvas.restore();
    }

    if (interactive) {
      for (final r in c.picture.regions) {
        if (c.filled.contains(r.id)) continue;
        final label = c.picture.labels[r.id]!;
        final on = r.number == c.selected && !c.eraser;
        final tp = TextPainter(
          text: TextSpan(
            text: '${r.number}',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: label.size,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              color: on ? ArtColors.line : ArtColors.numberMuted,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, label.at - Offset(tp.width / 2, tp.height / 2));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArtworkPainter old) => true;
}
