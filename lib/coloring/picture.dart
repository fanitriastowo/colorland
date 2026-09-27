import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

class PaletteColor {
  const PaletteColor(this.color, this.name);

  final Color color;
  final String name;
}

/// Catalog entry. Pictures without an [asset] are placeholders.
class PictureInfo {
  const PictureInfo(this.id, this.name, {this.asset, this.palette = const []});

  final String id;
  final String name;
  final String? asset;

  /// Number n (1-based) colors every SVG path filled with `palette[n - 1]`.
  final List<PaletteColor> palette;
}

class Category {
  const Category(this.key, this.name, this.pictures);

  final String key;
  final String name;
  final List<PictureInfo> pictures;
}

const fox = PictureInfo(
  'fox',
  'Fox',
  asset: 'assets/pictures/fox.svg',
  palette: [
    PaletteColor(Color(0xFFFF8752), 'Orange'),
    PaletteColor(Color(0xFFD15124), 'Red'),
    PaletteColor(Color(0xFFE7EEF2), 'White'),
    PaletteColor(Color(0xFFA3B8BF), 'Gray'),
  ],
);

List<PictureInfo> _placeholders(List<String> names) =>
    [for (final n in names) PictureInfo(n.toLowerCase(), n)];

final categories = [
  Category('animals', 'Animals', [
    fox,
    ..._placeholders(['Owl', 'Cat', 'Bunny', 'Bear', 'Duck']),
  ]),
  Category('ocean', 'Ocean',
      _placeholders(['Fish', 'Whale', 'Crab', 'Octopus', 'Turtle', 'Seal'])),
  Category('cars', 'Cars',
      _placeholders(['Bus', 'Truck', 'Train', 'Boat', 'Plane', 'Bike'])),
  Category('dinos', 'Dinos',
      _placeholders(['T-Rex', 'Egg', 'Stego', 'Ptero', 'Bronto', 'Trike'])),
  Category('food', 'Food',
      _placeholders(['Apple', 'Cake', 'Pizza', 'Pear', 'Donut', 'Melon'])),
  Category('space', 'Space',
      _placeholders(['Moon', 'Star', 'Rocket', 'Planet', 'Alien', 'Sun'])),
];

/// One SVG path. [number] is null for fixed line art (eyes, nose), which
/// can't be colored and never takes taps.
class Region {
  Region(this.id, this.path, this.number);

  final int id;
  final Path path;
  final int? number;

  bool get fixed => number == null;
}

typedef Label = ({Offset at, double size});

class ColoringPicture {
  ColoringPicture(this.info, this.parts)
      : bounds = parts
            .map((p) => p.path.getBounds())
            .reduce((a, b) => a.expandToInclude(b))
            .inflate(4),
        labels = _computeLabels(parts);

  factory ColoringPicture.parse(PictureInfo info, String svg) {
    final parts = <Region>[];
    final re = RegExp(r'<path d="([^"]+)" style="fill:#([0-9a-fA-F]{6})"');
    for (final m in re.allMatches(svg)) {
      final color = Color(int.parse('FF${m[2]}', radix: 16));
      final i = info.palette.indexWhere((p) => p.color == color);
      parts.add(Region(parts.length, parseSvgPathData(m[1]!), i < 0 ? null : i + 1));
    }
    return ColoringPicture(info, parts);
  }

  static Future<ColoringPicture> load(PictureInfo info) async =>
      ColoringPicture.parse(info, await rootBundle.loadString(info.asset!));

  final PictureInfo info;

  /// All paths in paint order.
  final List<Region> parts;
  final Rect bounds;
  final Map<int, Label> labels;

  Iterable<Region> get regions => parts.where((r) => !r.fixed);

  List<int> get numbers => [for (var n = 1; n <= info.palette.length; n++) n];

  /// "Pole of inaccessibility" on a sampled grid: the visible point of each
  /// region farthest from its edge.
  static Map<int, Label> _computeLabels(List<Region> parts) {
    const n = 18;
    final labels = <int, Label>{};
    for (final r in parts) {
      if (r.fixed) continue;
      final b = r.path.getBounds();
      final sx = b.width / n, sy = b.height / n;
      final ins = <Offset>[], outs = <Offset>[];
      for (var a = -1; a <= n + 1; a++) {
        for (var c = -1; c <= n + 1; c++) {
          final p = Offset(b.left + a * sx, b.top + c * sy);
          final inside = r.path.contains(p) &&
              !parts.skip(r.id + 1).any((o) => o.path.contains(p));
          (inside ? ins : outs).add(p);
        }
      }
      var best = b.center;
      var bestDist = 4.0;
      for (final q in ins) {
        var m = double.infinity;
        for (final o in outs) {
          m = math.min(m, (q - o).distanceSquared);
        }
        m = math.sqrt(m);
        if (m > bestDist) {
          bestDist = m;
          best = q;
        }
      }
      labels[r.id] = (at: best, size: (bestDist * 0.95).clamp(9.0, 22.0));
    }
    return labels;
  }
}
