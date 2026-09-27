import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../coloring/artwork_view.dart';
import '../coloring/coloring_controller.dart';
import '../coloring/picture.dart';
import '../theme.dart';
import '../widgets/chunky.dart';
import 'canvas_screen.dart';
import 'gallery_screen.dart';

class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key, required this.controller, required this.controllers});

  final ColoringController controller;
  final Map<String, ColoringController> controllers;

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> with TickerProviderStateMixin {
  late final _bob = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  void _again() {
    widget.controller.reset();
    openCanvas(context, widget.controller, controllers: widget.controllers, replace: true);
  }

  void _morePictures() {
    final id = widget.controller.picture.info.id;
    final category = categories.firstWhere((c) => c.pictures.any((p) => p.id == id));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => GalleryScreen(category: category, controllers: widget.controllers),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = colors.onPrimary;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Confetti(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 16),
              child: Column(
                spacing: 22,
                children: [
                  Text(
                    'You did it!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: fg),
                  ),
                  AnimatedBuilder(
                    animation: _bob,
                    builder: (context, child) {
                      final t = Curves.easeInOut.transform(_bob.value);
                      return Transform.translate(
                        offset: Offset(0, -8 * t),
                        child: Transform.rotate(angle: (-3 + 2 * t) * math.pi / 180, child: child),
                      );
                    },
                    child: Container(
                      width: 300,
                      height: 290,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: colors.primaryContainer, offset: const Offset(0, 10))],
                      ),
                      child: ArtworkView(widget.controller),
                    ),
                  ),
                  Text(
                    '${widget.controller.picture.info.name} is all colored in',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: fg),
                  ),
                  const Spacer(),
                  Row(
                    spacing: 14,
                    children: [
                      Expanded(
                        flex: 10,
                        child: _bigButton(
                          label: 'Again',
                          icon: LineIcon(AppIcons.refresh, size: 24, color: colors.onSurface),
                          bg: colors.surface,
                          fg: colors.onSurface,
                          lip: colors.primaryContainer,
                          onTap: _again,
                        ),
                      ),
                      Expanded(
                        flex: 13,
                        child: _bigButton(
                          label: 'More pictures',
                          icon: Icon(Icons.grid_view_rounded, size: 24, color: colors.surface),
                          bg: colors.onSurface,
                          fg: colors.surface,
                          lip: context.extra.darkButtonLip,
                          onTap: _morePictures,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigButton({
    required String label,
    required Widget icon,
    required Color bg,
    required Color fg,
    required Color lip,
    required VoidCallback onTap,
  }) {
    return ChunkyButton(
      onTap: onTap,
      height: 76,
      radius: 28,
      lip: 6,
      pressedLip: 2,
      color: bg,
      lipColor: lip,
      child: Row(
        mainAxisAlignment: .center,
        spacing: 10,
        children: [
          icon,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// 70 pieces falling and spinning forever, each on its own loop.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

typedef _Piece = ({double x, double w, bool round, int color, double period, double offset});

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _elapsed = ValueNotifier(Duration.zero);
  final _random = math.Random();
  late final List<_Piece> _pieces = [
    for (var i = 0; i < 70; i++)
      (
        x: _random.nextDouble(),
        w: 7 + _random.nextDouble() * 8,
        round: _random.nextDouble() < 0.35,
        color: i % 6,
        period: 2.6 + _random.nextDouble() * 2.4,
        offset: _random.nextDouble() * 4,
      ),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) => _elapsed.value = d)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          _pieces,
          _elapsed,
          [
            colors.tertiary,
            colors.secondary,
            context.extra.green,
            colors.tertiaryContainer,
            colors.secondaryContainer,
            Colors.white,
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.elapsed, this.colors) : super(repaint: elapsed);

  final List<_Piece> pieces;
  final ValueNotifier<Duration> elapsed;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = elapsed.value.inMicroseconds / 1e6;
    final paint = Paint();
    for (final p in pieces) {
      final phase = ((t + p.offset) % p.period) / p.period;
      canvas
        ..save()
        ..translate(p.x * size.width, -60 + (size.height + 120) * phase)
        ..rotate(phase * 4 * math.pi);
      paint.color = colors[p.color];
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.w / 2, paint);
      } else {
        final h = p.w * 1.6;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.w, height: h), const Radius.circular(2)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
