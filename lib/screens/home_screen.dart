import 'package:flutter/material.dart';

import '../coloring/artwork_view.dart';
import '../coloring/coloring_controller.dart';
import '../coloring/picture.dart';
import '../theme.dart';
import '../widgets/chunky.dart';
import 'canvas_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controllers});

  final Map<String, ColoringController> controllers;

  @override
  Widget build(BuildContext context) {
    final c = controllers[fox.id]!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 22,
            children: [
              const _Header(),
              ListenableBuilder(
                listenable: c,
                builder: (context, _) => _ContinueCard(c, controllers: controllers),
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 150,
                ),
                children: [
                  for (final cat in categories)
                    _CategoryTile(cat, controllers: controllers),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 2,
        children: [
          const Text(
            "Let's color!",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          Text(
            'Pick a picture',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard(this.c, {required this.controllers});

  final ColoringController c;
  final Map<String, ColoringController> controllers;

  @override
  Widget build(BuildContext context) {
    final eyebrow = c.done == 0
        ? 'New picture'
        : c.isComplete
            ? 'Finished'
            : 'Keep going';
    return ChunkyButton(
      onTap: () => openCanvas(context, c, controllers: controllers),
      color: context.colors.surface,
      lipColor: context.colors.primaryContainer,
      lip: 6,
      pressedLip: 2,
      radius: 32,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 108,
            height: 96,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ArtworkView(c),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 4,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  c.picture.info.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                ProgressBar(value: c.progress, height: 10, radius: 6),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: LineIcon(AppIcons.play, size: 28, fill: true, color: context.colors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.category, {required this.controllers});

  final Category category;
  final Map<String, ColoringController> controllers;

  Color _color(BuildContext context) => switch (category.key) {
        'animals' => context.colors.tertiaryContainer,
        'ocean' => context.colors.secondary,
        'cars' => context.extra.green,
        'dinos' => context.colors.secondaryContainer,
        'food' => context.colors.tertiary,
        _ => context.colors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final fg = context.colors.onPrimary;
    final art = controllers[category.pictures.first.id];
    return ChunkyButton(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GalleryScreen(category: category, controllers: controllers),
      )),
      color: _color(context),
      lipColor: context.extra.lip,
      lip: 6,
      pressedLip: 2,
      radius: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (art != null)
              Positioned(
                right: -6,
                bottom: -4,
                width: 104,
                height: 92,
                child: Opacity(opacity: 0.95, child: ArtworkView(art)),
              )
            else
              Positioned(
                right: 12,
                bottom: 12,
                child: SvgSlot(
                  size: 70,
                  radius: 22,
                  label: 'SVG',
                  color: fg.withValues(alpha: 0.35),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: fg),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.pictures.length} pictures',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ArtColors.line),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
