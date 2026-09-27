import 'package:flutter/material.dart';

import '../coloring/artwork_view.dart';
import '../coloring/coloring_controller.dart';
import '../coloring/picture.dart';
import '../theme.dart';
import '../widgets/chunky.dart';
import 'canvas_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.category, required this.controllers});

  final Category category;
  final Map<String, ColoringController> controllers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 18,
            children: [
              Row(
                spacing: 14,
                children: [
                  RoundButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const LineIcon(AppIcons.back, strokeWidth: 2.8),
                  ),
                  Text(category.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                ],
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 200,
                ),
                children: [
                  for (final p in category.pictures)
                    if (controllers[p.id] case final c?)
                      ListenableBuilder(
                        listenable: c,
                        builder: (context, _) => _GalleryCard(p, controller: c, controllers: controllers),
                      )
                    else
                      _GalleryCard(p, controllers: controllers),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard(this.picture, {this.controller, required this.controllers});

  final PictureInfo picture;
  final ColoringController? controller;
  final Map<String, ColoringController> controllers;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final tag = c == null
        ? ''
        : c.done == 0
            ? 'New'
            : c.isComplete
                ? 'Done'
                : '${(c.progress * 100).round()}%';
    return ChunkyButton(
      onTap: c == null ? null : () => openCanvas(context, c, controllers: controllers),
      color: context.colors.surface,
      lipColor: context.extra.lip,
      lip: 5,
      pressedLip: 2,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (c != null)
                  SizedBox(width: 150, height: 130, child: ArtworkView(c))
                else
                  SvgSlot(size: 96, label: 'SVG slot', color: context.extra.dashed),
                if (c != null && c.isComplete)
                  const Positioned(top: 8, right: 8, child: CheckBadge(size: 32)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(picture.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
