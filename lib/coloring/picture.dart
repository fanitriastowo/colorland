import 'dart:convert';
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

const catalogAsset = 'assets/catalog.json';

/// The picture catalog, set by [loadCatalog] at startup.
List<Category> get categories => _categories;
List<Category> _categories = const [];

/// Reads the catalog from [catalogAsset]. Adding a picture only needs its SVG
/// in `assets/pictures/` and an entry there.
Future<List<Category>> loadCatalog() async =>
    _categories = parseCatalog(await rootBundle.loadString(catalogAsset));

/// Parses catalog JSON: `{"categories": [{"key", "name", "pictures": [...]}]}`.
/// A picture is `{"id", "name", "svg"?, "palette": [{"color": "#RRGGBB",
/// "name"}]}`; `svg` is a file name in `assets/pictures/`, and a picture
/// without one is a placeholder.
List<Category> parseCatalog(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  return [
    for (final c in json['categories'] as List)
      Category(c['key'] as String, c['name'] as String, [
        for (final p in c['pictures'] as List)
          PictureInfo(
            p['id'] as String,
            p['name'] as String,
            asset: switch (p['svg']) {
              final String svg => 'assets/pictures/$svg',
              _ => null,
            },
            palette: [
              for (final e in (p['palette'] as List?) ?? const [])
                PaletteColor(_hex(e['color'] as String), e['name'] as String),
            ],
          ),
      ]),
  ];
}

Color _hex(String s) {
  final hex = s.startsWith('#') ? s.substring(1) : s;
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
    throw FormatException('Expected a #RRGGBB color', s);
  }
  return Color(int.parse('FF$hex', radix: 16));
}

/// Colors offered in free-color mode, once a picture is finished.
const freePalette = [
  PaletteColor(Color(0xFFFF4D4D), 'Red'),
  PaletteColor(Color(0xFFFF9F40), 'Orange'),
  PaletteColor(Color(0xFFFFD93D), 'Yellow'),
  PaletteColor(Color(0xFF6BCB77), 'Green'),
  PaletteColor(Color(0xFF2EC4B6), 'Teal'),
  PaletteColor(Color(0xFF4D96FF), 'Blue'),
  PaletteColor(Color(0xFF9B5DE5), 'Purple'),
  PaletteColor(Color(0xFFFF7AB6), 'Pink'),
  PaletteColor(Color(0xFFA0643C), 'Brown'),
  PaletteColor(Color(0xFF9AA2B3), 'Gray'),
  PaletteColor(Color(0xFF293241), 'Black'),
  PaletteColor(Color(0xFFFFFFFF), 'White'),
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
    assert(() {
      final used = {for (final r in parts) r.number};
      final missing = [
        for (var n = 1; n <= info.palette.length; n++)
          if (!used.contains(n)) info.palette[n - 1].name,
      ];
      if (missing.isEmpty) return true;
      throw StateError('${info.id}: palette colors not found in the SVG: ${missing.join(', ')}');
    }());
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
