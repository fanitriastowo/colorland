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

final categories = [
  Category('animals', 'Animals', [
    fox,
    PictureInfo(
      'owl',
      'Owl',
      asset: 'assets/pictures/owl.svg',
      palette: [
        PaletteColor(Color(0xFF662113), 'Dark Brown'),
        PaletteColor(Color(0xFFC1694F), 'Brown'),
        PaletteColor(Color(0xFFFFCC4D), 'Yellow'),
        PaletteColor(Color(0xFFFFAC33), 'Orange'),
      ],
    ),
    PictureInfo(
      'cat',
      'Cat',
      asset: 'assets/pictures/cat.svg',
      palette: [
        PaletteColor(Color(0xFF4C5359), 'Gray'),
        PaletteColor(Color(0xFFFFFFFF), 'White'),
        PaletteColor(Color(0xFF93E67F), 'Green'),
        PaletteColor(Color(0xFFF7A4A4), 'Pink'),
      ],
    ),
    PictureInfo(
      'bunny',
      'Bunny',
      asset: 'assets/pictures/bunny.svg',
      palette: [
        PaletteColor(Color(0xFFD1E7F8), 'Light Blue'),
        PaletteColor(Color(0xFF96C8EF), 'Blue'),
        PaletteColor(Color(0xFF5AAAE7), 'Dark Blue'),
        PaletteColor(Color(0xFFFF3F62), 'Pink'),
      ],
    ),
    PictureInfo(
      'bear',
      'Bear',
      asset: 'assets/pictures/bear.svg',
      palette: [
        PaletteColor(Color(0xFFC1694F), 'Brown'),
        PaletteColor(Color(0xFFD99E82), 'Tan'),
        PaletteColor(Color(0xFFE6AAAA), 'Pink'),
        PaletteColor(Color(0xFFDD2E44), 'Red'),
      ],
    ),
    PictureInfo(
      'duck',
      'Duck',
      asset: 'assets/pictures/duck.svg',
      palette: [
        PaletteColor(Color(0xFF3E721D), 'Green'),
        PaletteColor(Color(0xFFFFCC4D), 'Yellow'),
        PaletteColor(Color(0xFFD99E82), 'Tan'),
        PaletteColor(Color(0xFFC1694F), 'Brown'),
        PaletteColor(Color(0xFFE1E8ED), 'White'),
      ],
    ),
  ]),
  Category('ocean', 'Ocean', [
    PictureInfo(
      'fish',
      'Fish',
      asset: 'assets/pictures/fish.svg',
      palette: [
        PaletteColor(Color(0xFFFC8C29), 'Orange'),
        PaletteColor(Color(0xFFBD53B5), 'Purple'),
        PaletteColor(Color(0xFF9DC1E4), 'Blue'),
        PaletteColor(Color(0xFFFFDED5), 'Peach'),
      ],
    ),
    PictureInfo(
      'whale',
      'Whale',
      asset: 'assets/pictures/whale.svg',
      palette: [
        PaletteColor(Color(0xFF4AD0FF), 'Blue'),
        PaletteColor(Color(0xFF99E5FF), 'Light Blue'),
        PaletteColor(Color(0xFF16A5D9), 'Dark Blue'),
        PaletteColor(Color(0xFFFAE8AC), 'Cream'),
      ],
    ),
    PictureInfo(
      'crab',
      'Crab',
      asset: 'assets/pictures/crab.svg',
      palette: [
        PaletteColor(Color(0xFFFF5722), 'Orange'),
        PaletteColor(Color(0xFFAA290B), 'Red'),
        PaletteColor(Color(0xFFD84315), 'Dark Orange'),
      ],
    ),
    PictureInfo(
      'octopus',
      'Octopus',
      asset: 'assets/pictures/octopus.svg',
      palette: [
        PaletteColor(Color(0xFFFF615E), 'Coral'),
        PaletteColor(Color(0xFFFFA8A8), 'Pink'),
        PaletteColor(Color(0xFFA52914), 'Red'),
      ],
    ),
    PictureInfo(
      'turtle',
      'Turtle',
      asset: 'assets/pictures/turtle.svg',
      palette: [
        PaletteColor(Color(0xFF83BF4F), 'Green'),
        PaletteColor(Color(0xFF6EA03F), 'Dark Green'),
        PaletteColor(Color(0xFFC1875D), 'Tan'),
        PaletteColor(Color(0xFF7D593E), 'Brown'),
        PaletteColor(Color(0xFFFFD93B), 'Yellow'),
      ],
    ),
    PictureInfo(
      'seal',
      'Seal',
      asset: 'assets/pictures/seal.svg',
      palette: [
        PaletteColor(Color(0xFF0F597A), 'Dark Blue'),
        PaletteColor(Color(0xFF057091), 'Blue'),
        PaletteColor(Color(0xFF0E91AF), 'Teal'),
        PaletteColor(Color(0xFF1AB9D3), 'Light Blue'),
        PaletteColor(Color(0xFFE07127), 'Orange'),
        PaletteColor(Color(0xFFE0A617), 'Yellow'),
      ],
    ),
  ]),
  Category('cars', 'Cars', [
    PictureInfo(
      'bus',
      'Bus',
      asset: 'assets/pictures/bus.svg',
      palette: [
        PaletteColor(Color(0xFFFFC107), 'Yellow'),
        PaletteColor(Color(0xFFFFF8E1), 'Cream'),
        PaletteColor(Color(0xFF455A64), 'Gray'),
        PaletteColor(Color(0xFF9FA8DA), 'Lilac'),
        PaletteColor(Color(0xFF7986CB), 'Blue'),
        PaletteColor(Color(0xFF64DD17), 'Green'),
      ],
    ),
    PictureInfo(
      'truck',
      'Truck',
      asset: 'assets/pictures/truck.svg',
      palette: [
        PaletteColor(Color(0xFFD3552F), 'Orange'),
        PaletteColor(Color(0xFF9D2524), 'Red'),
        PaletteColor(Color(0xFF4E6874), 'Slate'),
        PaletteColor(Color(0xFF6D858E), 'Gray'),
        PaletteColor(Color(0xFFFFFFFF), 'White'),
      ],
    ),
    PictureInfo(
      'train',
      'Train',
      asset: 'assets/pictures/train.svg',
      palette: [
        PaletteColor(Color(0xFFC1E7D8), 'Mint'),
        PaletteColor(Color(0xFF8599A4), 'Gray'),
        PaletteColor(Color(0xFF9B5C77), 'Purple'),
        PaletteColor(Color(0xFFACD8CB), 'Green'),
      ],
    ),
    PictureInfo(
      'boat',
      'Boat',
      asset: 'assets/pictures/boat.svg',
      palette: [
        PaletteColor(Color(0xFF8599A4), 'Gray'),
        PaletteColor(Color(0xFFC1E7D8), 'Mint'),
        PaletteColor(Color(0xFF9B5C77), 'Purple'),
      ],
    ),
    PictureInfo(
      'plane',
      'Plane',
      asset: 'assets/pictures/plane.svg',
      palette: [
        PaletteColor(Color(0xFFFFCE00), 'Yellow'),
        PaletteColor(Color(0xFF333E48), 'Dark Gray'),
        PaletteColor(Color(0xFF7D868C), 'Gray'),
      ],
    ),
    PictureInfo(
      'bike',
      'Bike',
      asset: 'assets/pictures/bike.svg',
      palette: [
        PaletteColor(Color(0xFFE51B54), 'Red'),
        PaletteColor(Color(0xFF5F7B89), 'Gray'),
        PaletteColor(Color(0xFFCFD7DB), 'Silver'),
        PaletteColor(Color(0xFFA31A53), 'Purple'),
      ],
    ),
  ]),
  Category('dinos', 'Dinos', [
    PictureInfo(
      't-rex',
      'T-Rex',
      asset: 'assets/pictures/t-rex.svg',
      palette: [
        PaletteColor(Color(0xFF77B155), 'Light Green'),
        PaletteColor(Color(0xFF5C913A), 'Green'),
        PaletteColor(Color(0xFF3E701E), 'Dark Green'),
        PaletteColor(Color(0xFFF4900C), 'Orange'),
      ],
    ),
    PictureInfo(
      'egg',
      'Egg',
      asset: 'assets/pictures/egg.svg',
      palette: [
        PaletteColor(Color(0xFFF3F3F3), 'White'),
        PaletteColor(Color(0xFFF0C419), 'Yellow'),
      ],
    ),
    PictureInfo(
      'stego',
      'Stego',
      asset: 'assets/pictures/stegosaurus.svg',
      palette: [
        PaletteColor(Color(0xFF46AF64), 'Green'),
        PaletteColor(Color(0xFF389350), 'Dark Green'),
        PaletteColor(Color(0xFF62CC7E), 'Light Green'),
        PaletteColor(Color(0xFF775C38), 'Brown'),
      ],
    ),
    PictureInfo(
      'ptero',
      'Ptero',
      asset: 'assets/pictures/pterosaurus.svg',
      palette: [
        PaletteColor(Color(0xFF6DAA77), 'Green'),
        PaletteColor(Color(0xFF639E6C), 'Dark Green'),
        PaletteColor(Color(0xFF79B585), 'Light Green'),
      ],
    ),
    PictureInfo(
      'bronto',
      'Bronto',
      asset: 'assets/pictures/apatosaurus.svg',
      palette: [
        PaletteColor(Color(0xFF384276), 'Navy'),
        PaletteColor(Color(0xFF4B5E99), 'Blue'),
        PaletteColor(Color(0xFFD9BBF2), 'Lilac'),
        PaletteColor(Color(0xFF5F196B), 'Purple'),
      ],
    ),
    PictureInfo(
      'trike',
      'Trike',
      asset: 'assets/pictures/triceratops.svg',
      palette: [
        PaletteColor(Color(0xFF98C79C), 'Green'),
        PaletteColor(Color(0xFFABD1AD), 'Light Green'),
        PaletteColor(Color(0xFF87B98F), 'Dark Green'),
        PaletteColor(Color(0xFFD570A7), 'Pink'),
      ],
    ),
  ]),
  Category('food', 'Food', [
    PictureInfo(
      'apple',
      'Apple',
      asset: 'assets/pictures/apple.svg',
      palette: [
        PaletteColor(Color(0xFFDF2B2B), 'Red'),
        PaletteColor(Color(0xFFFFF5CA), 'Cream'),
        PaletteColor(Color(0xFFEAD991), 'Yellow'),
        PaletteColor(Color(0xFF286F0D), 'Green'),
      ],
    ),
    PictureInfo(
      'cake',
      'Cake',
      asset: 'assets/pictures/cake.svg',
      palette: [
        PaletteColor(Color(0xFFF5AD1A), 'Orange'),
        PaletteColor(Color(0xFFF5ECDA), 'Cream'),
        PaletteColor(Color(0xFFEACC53), 'Yellow'),
        PaletteColor(Color(0xFF5B2B20), 'Brown'),
      ],
    ),
    PictureInfo(
      'pizza',
      'Pizza',
      asset: 'assets/pictures/pizza.svg',
      palette: [
        PaletteColor(Color(0xFFEBA824), 'Yellow'),
        PaletteColor(Color(0xFF6E4921), 'Brown'),
        PaletteColor(Color(0xFFE8BC38), 'Gold'),
        PaletteColor(Color(0xFFFFFCF4), 'White'),
        PaletteColor(Color(0xFF3D7C38), 'Green'),
      ],
    ),
    PictureInfo(
      'pear',
      'Pear',
      asset: 'assets/pictures/pear.svg',
      palette: [
        PaletteColor(Color(0xFFF6BB42), 'Yellow'),
        PaletteColor(Color(0xFFFFE7B0), 'Cream'),
        PaletteColor(Color(0xFFEDCA8C), 'Tan'),
      ],
    ),
    PictureInfo(
      'donut',
      'Donut',
      asset: 'assets/pictures/donut.svg',
      palette: [
        PaletteColor(Color(0xFFF27596), 'Pink'),
        PaletteColor(Color(0xFFE01042), 'Red'),
        PaletteColor(Color(0xFF593123), 'Brown'),
      ],
    ),
    PictureInfo(
      'melon',
      'Melon',
      asset: 'assets/pictures/melon.svg',
      palette: [
        PaletteColor(Color(0xFF83C449), 'Green'),
        PaletteColor(Color(0xFFACE075), 'Light Green'),
        PaletteColor(Color(0xFFF0F3CD), 'Cream'),
        PaletteColor(Color(0xFFF9BE78), 'Orange'),
        PaletteColor(Color(0xFFFECF79), 'Yellow'),
      ],
    ),
  ]),
  Category('space', 'Space', [
    PictureInfo(
      'moon',
      'Moon',
      asset: 'assets/pictures/moon.svg',
      palette: [PaletteColor(Color(0xFFFFEB43), 'Yellow'), PaletteColor(Color(0xFFFFC700), 'Gold')],
    ),
    PictureInfo(
      'star',
      'Star',
      asset: 'assets/pictures/star.svg',
      palette: [
        PaletteColor(Color(0xFFF1C40F), 'Yellow'),
        PaletteColor(Color(0xFFF39C12), 'Orange'),
      ],
    ),
    PictureInfo(
      'rocket',
      'Rocket',
      asset: 'assets/pictures/rocket.svg',
      palette: [
        PaletteColor(Color(0xFFB5D5EB), 'Light Blue'),
        PaletteColor(Color(0xFF3A7EB9), 'Blue'),
        PaletteColor(Color(0xFFD48171), 'Red'),
        PaletteColor(Color(0xFFE9DF92), 'Yellow'),
      ],
    ),
    PictureInfo(
      'planet',
      'Planet',
      asset: 'assets/pictures/planet.svg',
      palette: [PaletteColor(Color(0xFF92C9FF), 'Blue'), PaletteColor(Color(0xFF87DFD6), 'Teal')],
    ),
    PictureInfo(
      'alien',
      'Alien',
      asset: 'assets/pictures/alien.svg',
      palette: [
        PaletteColor(Color(0xFFFF9737), 'Orange'),
        PaletteColor(Color(0xFFFFD960), 'Yellow'),
        PaletteColor(Color(0xFF3A5D74), 'Blue'),
      ],
    ),
    PictureInfo(
      'sun',
      'Sun',
      asset: 'assets/pictures/sun.svg',
      palette: [
        PaletteColor(Color(0xFFFFAC33), 'Orange'),
        PaletteColor(Color(0xFFE1E8ED), 'White'),
      ],
    ),
  ]),
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
