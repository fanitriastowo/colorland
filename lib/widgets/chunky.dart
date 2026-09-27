import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme.dart';

/// Tappable surface with a solid "3D lip" shadow. Pressing sinks it onto
/// the lip.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.child,
    required this.color,
    required this.lipColor,
    this.onTap,
    this.lip = 4,
    this.pressedLip = 0,
    this.radius = 0,
    this.circle = false,
    this.width,
    this.height,
    this.padding,
    this.border,
  });

  final Widget child;
  final Color color;
  final Color lipColor;
  final VoidCallback? onTap;
  final double lip;
  final double pressedLip;
  final double radius;
  final bool circle;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.onTap != null) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final lip = _pressed ? w.pressedLip : w.lip;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: w.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: w.width,
        height: w.height,
        padding: w.padding,
        transform: Matrix4.translationValues(0, w.lip - lip, 0),
        decoration: BoxDecoration(
          color: w.color,
          shape: w.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: w.circle ? null : BorderRadius.circular(w.radius),
          border: w.border,
          boxShadow: [BoxShadow(color: w.lipColor, offset: Offset(0, lip))],
        ),
        child: w.child,
      ),
    );
  }
}

/// 56px round white button used for back / palette.
class RoundButton extends StatelessWidget {
  const RoundButton({super.key, required this.child, required this.onTap, this.size = 56});

  final Widget child;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      circle: true,
      width: size,
      height: size,
      color: context.colors.surface,
      lipColor: context.extra.lip,
      child: Center(child: child),
    );
  }
}

/// Stroked icon paths on a 24-unit grid, copied from the design prototype.
class AppIcons {
  AppIcons._();

  static const back = ['M15 5l-7 7 7 7'];
  static const check = ['M5 12.5l4.5 4.5L19 7'];
  static const undo = ['M9 14L4 9l5-5', 'M4 9h10.5a5.5 5.5 0 0 1 0 11H11'];
  static const redo = ['M15 14l5-5-5-5', 'M20 9H9.5a5.5 5.5 0 0 0 0 11H13'];
  static const eraser = [
    'M7 21l-4.3-4.3a2.4 2.4 0 0 1 0-3.4l9.6-9.6a2.4 2.4 0 0 1 3.4 0l5.6 5.6a2.4 2.4 0 0 1 0 3.4L13 21',
    'M22 21H7',
    'M5 11l9 9',
  ];
  static const hint = [
    'M9 18h6',
    'M10 22h4',
    'M15.1 14c.2-1 .7-1.7 1.4-2.5A4.7 4.7 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.4 2.5',
  ];
  static const close = ['M6 6l12 12M18 6L6 18'];
  static const refresh = [
    'M3 12a9 9 0 0 1 15.5-6.3L21 8',
    'M21 3v5h-5',
    'M21 12a9 9 0 0 1-15.5 6.3L3 16',
    'M3 21v-5h5',
  ];
  static const play = ['M8 5.5v13a1 1 0 0 0 1.5.86l10.4-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z'];
  static const circle = ['M2 12a10 10 0 1 0 20 0a10 10 0 1 0-20 0'];
}

class LineIcon extends StatelessWidget {
  const LineIcon(
    this.paths, {
    super.key,
    this.size = 26,
    this.color,
    this.strokeWidth = 2.6,
    this.fill = false,
  });

  final List<String> paths;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LineIconPainter(this, color ?? context.colors.onSurface),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  _LineIconPainter(this.icon, this.color);

  final LineIcon icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..color = color
      ..style = icon.fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = icon.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final d in icon.paths) {
      canvas.drawPath(parseSvgPathData(d), paint);
    }
  }

  @override
  bool shouldRepaint(_LineIconPainter old) => old.color != color || old.icon != icon;
}

/// Green check in a circle, shown on finished pictures and swatches.
class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key, required this.size, this.border = 0});

  final double size;
  final double border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.extra.green,
        shape: BoxShape.circle,
        border: border > 0 ? Border.all(color: Colors.white, width: border) : null,
      ),
      alignment: Alignment.center,
      child: LineIcon(
        AppIcons.check,
        size: border > 0 ? 14 : 18,
        strokeWidth: border > 0 ? 4 : 3.2,
        color: Colors.white,
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.height,
    required this.radius,
    this.track,
    this.innerBorder,
    this.animate = false,
  });

  final double value;
  final double height;
  final double radius;
  final Color? track;
  final Color? innerBorder;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    Widget bar(double v) => Container(
          height: height,
          decoration: BoxDecoration(
            color: track ?? context.extra.track,
            borderRadius: BorderRadius.circular(radius),
          ),
          foregroundDecoration: innerBorder == null
              ? null
              : BoxDecoration(
                  border: Border.all(color: innerBorder!, width: 2),
                  borderRadius: BorderRadius.circular(radius),
                ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.extra.green,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        );
    if (!animate) return bar(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
      builder: (context, v, _) => bar(v),
    );
  }
}

/// Dashed rounded box standing in for pictures that don't have an SVG yet.
class SvgSlot extends StatelessWidget {
  const SvgSlot({super.key, required this.size, required this.label, required this.color, this.radius = 26});

  final double size;
  final String label;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color, radius),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color, this.radius);

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(1.25);
    canvas.drawPath(
      dashPath(Path()..addRRect(rrect), dashArray: CircularIntervalList([6.0, 5.0])),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color;
}
