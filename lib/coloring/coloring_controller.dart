import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'picture.dart';

/// Color-by-number state for one picture. [filled] seeds saved progress;
/// undo history starts empty.
class ColoringController extends ChangeNotifier {
  ColoringController(this.picture, {Iterable<int> filled = const []}) {
    this.filled.addAll(filled);
    selected = _firstOpen ?? 1;
  }

  final ColoringPicture picture;

  final Set<int> filled = {};
  final List<({int id, bool value})> _history = [];
  int _ptr = 0;

  late int selected;
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
  bool get canUndo => _ptr > 0;
  bool get canRedo => _ptr < _history.length;

  int totalOf(int n) => picture.regions.where((r) => r.number == n).length;
  int filledOf(int n) =>
      picture.regions.where((r) => r.number == n && filled.contains(r.id)).length;

  int? get _firstOpen {
    for (final n in picture.numbers) {
      if (filledOf(n) < totalOf(n)) return n;
    }
    return null;
  }

  void tap(Region r) {
    final isFilled = filled.contains(r.id);
    if (eraser) {
      if (isFilled) _push(r.id, false);
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
    _push(r.id, true);
  }

  void undo() {
    if (!canUndo) return;
    final a = _history[--_ptr];
    _apply(a.id, !a.value);
    popId = null;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final a = _history[_ptr++];
    _apply(a.id, a.value);
    popId = a.value ? a.id : null;
    _after();
    notifyListeners();
  }

  void select(int n) {
    selected = n;
    eraser = false;
    notifyListeners();
  }

  void toggleEraser() {
    eraser = !eraser;
    hint = false;
    notifyListeners();
  }

  void showHint() {
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

  /// "Again": clear fills and history.
  void reset() {
    filled.clear();
    _history.clear();
    _ptr = 0;
    selected = 1;
    eraser = false;
    hint = false;
    popId = null;
    notifyListeners();
  }

  void _push(int id, bool value) {
    _history
      ..removeRange(_ptr, _history.length)
      ..add((id: id, value: value));
    _ptr++;
    _apply(id, value);
    popId = value ? id : null;
    _after();
    notifyListeners();
  }

  void _apply(int id, bool value) => value ? filled.add(id) : filled.remove(id);

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

/// Loads every catalog picture that has an SVG, keyed by picture id, with
/// fills restored from and saved to shared preferences.
Future<Map<String, ColoringController>> loadControllers() async {
  final prefs = await SharedPreferences.getInstance();
  final controllers = <String, ColoringController>{};
  for (final c in categories) {
    for (final p in c.pictures) {
      if (p.asset == null) continue;
      final picture = await ColoringPicture.load(p);
      final key = 'fills.${p.id}';
      // Skip ids that no longer match a region (the SVG changed).
      final saved = (prefs.getStringList(key) ?? []).map(int.parse).where(
          (id) => id < picture.parts.length && !picture.parts[id].fixed);
      final controller = ColoringController(picture, filled: saved);
      controller.addListener(
          () => prefs.setStringList(key, [for (final id in controller.filled) '$id']));
      controllers[p.id] = controller;
    }
  }
  return controllers;
}
