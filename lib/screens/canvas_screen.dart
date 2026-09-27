import 'dart:async';

import 'package:flutter/material.dart';

import '../coloring/artwork_view.dart';
import '../coloring/coloring_controller.dart';
import '../theme.dart';
import '../widgets/chunky.dart';
import 'celebration_screen.dart';

/// Opens the canvas for [c]. Selection is reset here, before the route
/// builds, so listeners on other screens aren't notified mid-build.
void openCanvas(
  BuildContext context,
  ColoringController c, {
  required Map<String, ColoringController> controllers,
  bool replace = false,
}) {
  c.open();
  final route = MaterialPageRoute<void>(
    builder: (_) => CanvasScreen(controller: c, controllers: controllers),
  );
  final nav = Navigator.of(context);
  replace ? nav.pushReplacement(route) : nav.push(route);
}

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key, required this.controller, required this.controllers});

  final ColoringController controller;
  final Map<String, ColoringController> controllers;

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  Timer? _doneTimer;

  ColoringController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onChange);
  }

  @override
  void dispose() {
    c.removeListener(_onChange);
    _doneTimer?.cancel();
    super.dispose();
  }

  void _onChange() {
    if (!c.isComplete || _doneTimer != null) return;
    _doneTimer = Timer(const Duration(milliseconds: 750), () {
      _doneTimer = null;
      if (!mounted || !c.isComplete) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => CelebrationScreen(controller: c, controllers: widget.controllers),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ListenableBuilder(
            listenable: c,
            builder: (context, _) => Column(
              spacing: 14,
              children: [
                _topBar(context),
                Expanded(child: _artCard(context)),
                _toolRow(context),
                _paletteBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        RoundButton(
          onTap: () => Navigator.of(context).pop(),
          child: const LineIcon(AppIcons.back, strokeWidth: 2.8),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 6,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    c.picture.info.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${c.done} / ${c.total}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              ProgressBar(
                value: c.progress,
                height: 12,
                radius: 8,
                track: context.colors.surface,
                innerBorder: context.extra.dotGrid,
                animate: true,
              ),
            ],
          ),
        ),
        RoundButton(
          onTap: () => _showColorsSheet(context),
          child: const _PaletteIcon(),
        ),
      ],
    );
  }

  Widget _artCard(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [BoxShadow(color: context.extra.lip, offset: const Offset(0, 6))],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: CustomPaint(painter: _DotGridPainter(context.extra.dotGrid)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ArtworkView(c, interactive: true),
          ),
          if (c.eraser)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.tertiary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Tap to erase',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onTertiary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolRow(BuildContext context) {
    final colors = context.colors;
    return Row(
      spacing: 10,
      children: [
        _tool(context, 'Undo', AppIcons.undo, c.undo, enabled: c.canUndo),
        _tool(context, 'Redo', AppIcons.redo, c.redo, enabled: c.canRedo),
        _tool(
          context,
          'Eraser',
          AppIcons.eraser,
          c.toggleEraser,
          strokeWidth: 2.4,
          bg: c.eraser ? colors.tertiary : null,
          fg: c.eraser ? colors.onTertiary : null,
        ),
        _tool(
          context,
          'Hint',
          AppIcons.hint,
          c.showHint,
          strokeWidth: 2.4,
          bg: c.hint ? colors.primary : null,
          fg: c.hint ? colors.onPrimary : null,
        ),
      ],
    );
  }

  Widget _tool(
    BuildContext context,
    String label,
    List<String> icon,
    VoidCallback onTap, {
    bool enabled = true,
    double strokeWidth = 2.6,
    Color? bg,
    Color? fg,
  }) {
    final color = fg ?? context.colors.onSurface;
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: ChunkyButton(
          onTap: onTap,
          height: 70,
          radius: 24,
          color: bg ?? context.colors.surface,
          lipColor: context.extra.lip,
          child: Column(
            mainAxisAlignment: .center,
            spacing: 3,
            children: [
              LineIcon(icon, strokeWidth: strokeWidth, color: color),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paletteBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [BoxShadow(color: context.extra.lip, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: [
          for (final n in c.picture.numbers)
            GestureDetector(
              onTap: () => c.select(n),
              child: _Swatch(
                c,
                n,
                size: 66,
                fontSize: 28,
                selected: !c.eraser && c.selected == n,
              ),
            ),
        ],
      ),
    );
  }

  void _showColorsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      barrierColor: ArtColors.line.withValues(alpha: 0.4),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        curve: Cubic(0.2, 0.9, 0.3, 1),
      ),
      builder: (context) => ListenableBuilder(
        listenable: c,
        builder: (context, _) => _ColorsSheet(c),
      ),
    );
  }
}

/// Number circle in the palette color. The palette bar version animates
/// in when [selected].
class _Swatch extends StatelessWidget {
  const _Swatch(this.c, this.n, {required this.size, required this.fontSize, this.selected = false});

  final ColoringController c;
  final int n;
  final double size;
  final double fontSize;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = c.picture.info.palette[n - 1].color;
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: selected
            ? [
                BoxShadow(color: context.colors.onSurface, spreadRadius: 8),
                BoxShadow(color: context.colors.surface, spreadRadius: 4),
              ]
            : null,
      ),
      foregroundDecoration: selected
          ? null
          : BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ArtColors.line.withValues(alpha: 0.1), width: 2),
            ),
      child: Text(
        '$n',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color.computeLuminance() < 0.3 ? Colors.white : ArtColors.line,
        ),
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, -4 * t),
        child: Transform.scale(scale: 1 + 0.14 * t, child: child),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          if (c.filledOf(n) == c.totalOf(n))
            const Positioned(top: -4, right: -4, child: CheckBadge(size: 26, border: 3)),
        ],
      ),
    );
  }
}

class _ColorsSheet extends StatelessWidget {
  const _ColorsSheet(this.c);

  final ColoringController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        spacing: 14,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: context.extra.handle,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const Text('Colors', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              ChunkyButton(
                onTap: () => Navigator.of(context).pop(),
                circle: true,
                width: 48,
                height: 48,
                lip: 0,
                color: context.colors.surface,
                lipColor: Colors.transparent,
                child: const Center(child: LineIcon(AppIcons.close, size: 22, strokeWidth: 2.8)),
              ),
            ],
          ),
          for (final n in c.picture.numbers) _row(context, n),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int n) {
    final selected = !c.eraser && c.selected == n;
    final got = c.filledOf(n), all = c.totalOf(n);
    return ChunkyButton(
      onTap: () {
        c.select(n);
        Navigator.of(context).pop();
      },
      radius: 26,
      lip: selected ? 0 : 3,
      color: context.colors.surface,
      lipColor: context.extra.lip,
      border: selected
          ? Border.all(color: context.colors.onSurface, width: 3, strokeAlign: BorderSide.strokeAlignOutside)
          : null,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        spacing: 14,
        children: [
          _Swatch(c, n, size: 56, fontSize: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 6,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      c.picture.info.palette[n - 1].name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$got of $all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ProgressBar(value: all == 0 ? 0 : got / all, height: 8, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteIcon extends StatelessWidget {
  const _PaletteIcon();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      size: const Size.square(28),
      painter: _PaletteIconPainter(
        colors.onSurface,
        [colors.tertiary, colors.primary, colors.secondary, context.extra.green],
      ),
    );
  }
}

class _PaletteIconPainter extends CustomPainter {
  _PaletteIconPainter(this.line, this.dots);

  final Color line;
  final List<Color> dots;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    canvas.drawCircle(
      const Offset(12, 12),
      10,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    const at = [Offset(8, 9), Offset(12.5, 6.8), Offset(16.4, 10), Offset(15, 15)];
    for (var i = 0; i < at.length; i++) {
      canvas.drawCircle(at[i], 2, Paint()..color = dots[i]);
    }
  }

  @override
  bool shouldRepaint(_PaletteIconPainter old) => old.line != line;
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 9.0; x < size.width; x += 18) {
      for (var y = 9.0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}
