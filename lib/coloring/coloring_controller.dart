import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'picture.dart';

/// What one region shows: filled or not, and a free-mode color that
/// overrides its palette color.
typedef RegionState = ({bool filled, Color? color});

/// Color-by-number state for one picture. [filled] and [painted] seed saved
/// progress; undo history starts empty.
///
/// Once every region is filled the picture is in free mode: taps repaint
/// regions with [paint] instead of filling by number.
class ColoringController extends ChangeNotifier {
  ColoringController(
    this.picture, {
    Iterable<int> filled = const [],
    Map<int, Color> painted = const {},
  }) {
    this.filled.addAll(filled);
    this.painted.addAll(painted);
    selected = _firstOpen ?? 1;
  }

  final ColoringPicture picture;

  final Set<int> filled = {};

  /// Free-mode colors by region id.
  final Map<int, Color> painted = {};

  final List<({int id, RegionState from, RegionState to})> _history = [];
  int _ptr = 0;

  late int selected;
  Color paint = freePalette.first.color;
  bool eraser = false;
  bool hint = false;

  /// Region currently playing the wrong-tap shake / fill pop.
  int? wrongId;
  int? popId;

  Timer? _hintTimer, _wrongTimer, _advanceTimer;

  int get total => picture.regions.length;
  int get done => filled.length;
  double get progress => total == 0 ? 0 : done / total;
  bool get isComplete => done == total;
  bool get freeMode => isComplete;
  bool get canUndo => _ptr > 0;
  bool get canRedo => _ptr < _history.length;

  int totalOf(int n) => picture.regions.where((r) => r.number == n).length;
  int filledOf(int n) =>
      picture.regions.where((r) => r.number == n && filled.contains(r.id)).length;

  /// The color region [r] shows when filled.
  Color colorOf(Region r) => painted[r.id] ?? picture.info.palette[r.number! - 1].color;

  int? get _firstOpen {
    for (final n in picture.numbers) {
      if (filledOf(n) < totalOf(n)) return n;
    }
    return null;
  }

  RegionState _stateOf(int id) => (filled: filled.contains(id), color: painted[id]);

  void tap(Region r) {
    final isFilled = filled.contains(r.id);
    if (freeMode) {
      if (eraser) {
        if (painted.containsKey(r.id)) _push(r.id, (filled: true, color: null));
      } else if (colorOf(r) != paint) {
        _push(r.id, (filled: true, color: paint));
      }
      return;
    }
    if (eraser) {
      if (isFilled) _push(r.id, (filled: false, color: null));
      return;
    }
    if (isFilled) return;
    if (r.number != selected) {
      wrongId = r.id;
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 450), () {
        wrongId = null;
        notifyListeners();
      });
      notifyListeners();
      return;
    }
    _push(r.id, (filled: true, color: null));
  }

  void undo() {
    if (!canUndo) return;
    final a = _history[--_ptr];
    _apply(a.id, a.from);
    popId = null;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final a = _history[_ptr++];
    _apply(a.id, a.to);
    popId = a.to.filled ? a.id : null;
    _after();
    notifyListeners();
  }

  void select(int n) {
    selected = n;
    eraser = false;
    notifyListeners();
  }

  /// Picks the free-mode color.
  void selectPaint(Color color) {
    paint = color;
    eraser = false;
    notifyListeners();
  }

  void toggleEraser() {
    eraser = !eraser;
    hint = false;
    notifyListeners();
  }

  void showHint() {
    if (freeMode) return;
    hint = true;
    eraser = false;
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 2500), () {
      hint = false;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Called when the canvas opens.
  void open() {
    selected = _firstOpen ?? selected;
    eraser = false;
    notifyListeners();
  }

  /// "Again": clear fills, free-mode colors and history.
  void reset() {
    filled.clear();
    painted.clear();
    _history.clear();
    _ptr = 0;
    selected = 1;
    eraser = false;
    hint = false;
    popId = null;
    notifyListeners();
  }

  void _push(int id, RegionState to) {
    _history
      ..removeRange(_ptr, _history.length)
      ..add((id: id, from: _stateOf(id), to: to));
    _ptr++;
    _apply(id, to);
    popId = to.filled ? id : null;
    _after();
    notifyListeners();
  }

  void _apply(int id, RegionState s) {
    s.filled ? filled.add(id) : filled.remove(id);
    if (s.color case final color?) {
      painted[id] = color;
    } else {
      painted.remove(id);
    }
  }

  /// Auto-advance to the lowest unfinished number once the selected one is done.
  void _after() {
    if (isComplete || eraser || filledOf(selected) < totalOf(selected)) return;
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 350), () {
      final next = _firstOpen;
      if (next == null) return;
      selected = next;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }
}

/// Loads the catalog and every picture that has an SVG, keyed by picture id,
/// with fills and free-mode colors restored from and saved to shared
/// preferences.
Future<Map<String, ColoringController>> loadControllers() async {
  final prefs = await SharedPreferences.getInstance();
  final controllers = <String, ColoringController>{};
  for (final c in await loadCatalog()) {
    for (final p in c.pictures) {
      if (p.asset == null) continue;
      final picture = await ColoringPicture.load(p);
      // Skip ids that no longer match a region (the SVG changed).
      bool valid(int id) => id < picture.parts.length && !picture.parts[id].fixed;
      final fillsKey = 'fills.${p.id}', paintKey = 'paint.${p.id}';
      final saved = (prefs.getStringList(fillsKey) ?? []).map(int.parse).where(valid);
      final painted = <int, Color>{
        for (final e in prefs.getStringList(paintKey) ?? <String>[])
          if (e.split(':') case [final id, final argb] when valid(int.parse(id)))
            int.parse(id): Color(int.parse(argb, radix: 16)),
      };
      final controller = ColoringController(picture, filled: saved, painted: painted);
      controller.addListener(() {
        prefs.setStringList(fillsKey, [for (final id in controller.filled) '$id']);
        prefs.setStringList(paintKey, [
          for (final MapEntry(:key, :value) in controller.painted.entries)
            '$key:${value.toARGB32().toRadixString(16)}',
        ]);
      });
      controllers[p.id] = controller;
    }
  }
  return controllers;
}
