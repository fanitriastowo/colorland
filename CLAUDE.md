# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ColorLand is a Flutter color-by-number app for kids. Each picture is an SVG whose filled paths become tappable regions; a region's number is decided by its fill color's position in that picture's palette.

## Commands

```sh
flutter pub get
flutter analyze                                   # lints: package:flutter_lints/flutter.yaml
flutter test                                      # all tests
flutter test test/coloring_controller_test.dart   # one file
flutter test --plain-name 'fills survive a restart'   # one test by name
flutter test --coverage                           # writes coverage/lcov.info
flutter run -d <device-id>
```

`pubspec.yaml` has a `scripts:` section (`ios`, `android`, `coverage`) holding shell one-liners to boot a simulator/emulator (the Android one expects an AVD named `Pixel_10a`) and run the app, or render an HTML coverage report. The README has the iOS one spelled out.

End-to-end flows use Maestro (`.maestro/*.yaml`, app id `com.example.colorland`): `maestro test .maestro/`. `coloring.yaml` taps the fox canvas by screen percentage and asserts the `done / total` counter, so changes to the fox SVG, its palette, or canvas layout can break it. `free_color.yaml` does the same with the Egg (2 regions) to reach free-color mode.

## Architecture

All code is in `lib/`; there is no state-management package — just `ChangeNotifier` + `ListenableBuilder`.

- **`assets/catalog.json`** — the picture catalog (categories → pictures with `id`, `name`, `svg` file name, `palette` of `{"color": "#RRGGBB", "name"}`). Adding a picture = drop the SVG in `assets/pictures/` and add an entry here; no Dart changes. A picture without `svg` is a placeholder.
- **`coloring/picture.dart`** — catalog loading and SVG parsing.
  - `loadCatalog()` (called by `loadControllers()` at startup) fills the global `categories`; it is empty until then, so tests that read `categories` directly must `await loadCatalog()` first. `freePalette` is the fixed color set for free mode.
  - `ColoringPicture.parse` does **not** use a general SVG parser: a regex matches only `<path d="..." style="fill:#RRGGBB"`. A path whose fill matches `palette[n-1]` becomes region number `n`; any other color becomes a *fixed* region (line art like eyes/nose, drawn in the line color, not tappable). SVGs must therefore use exactly that attribute form, and palette colors must match the SVG fills exactly — in debug builds `parse` throws if a palette color never appears in the SVG.
  - Region ids are the path's index in paint order. Number label positions are precomputed (grid-sampled "pole of inaccessibility", accounting for regions painted on top).
- **`coloring/coloring_controller.dart`** — per-picture state: `filled` region ids, `painted` (free-mode color overrides), selected number, eraser/hint modes, undo/redo history, and transient animation markers (`wrongId`, `popId`) cleared by timers. Auto-advances to the lowest unfinished number.
  - **Free mode** is simply `isComplete`: taps repaint regions with `paint`, the eraser removes paint (never un-fills), hints are off. Undo history stores each region's before/after `(filled, color)`, so undoing out of free mode unwinds paint first. Always read a region's fill color via `colorOf(r)`.
  - `loadControllers()` builds one controller for every picture with an asset and persists to `SharedPreferences` on every change: `fills.<pictureId>` (region ids) and `paint.<pictureId>` (`id:ARGBhex`). Saved ids that no longer match a non-fixed region are dropped (so editing an SVG can silently reset progress).
- **`coloring/artwork_view.dart`** — `CustomPainter` rendering of a picture. `interactive: true` (canvas) adds hit-testing (topmost non-fixed path wins), color fade tweens, pop/shake/hint animations, haptics and number labels; `interactive: false` is the static thumbnail used on home/gallery/celebration.
- **`screens/`** — Home → Gallery (per category) → Canvas → Celebration. The `Map<String, ColoringController>` created in `main()` is passed down through every screen constructor. Open the canvas via `openCanvas()`, which calls `controller.open()` *before* pushing the route so other screens' listeners aren't notified mid-build. Canvas pushes Celebration only when a picture *becomes* complete (not on free-mode changes); Celebration's "Color it my way" reopens the canvas in free mode.
- **`theme.dart`** — light/dark `AppTheme`, palette constants (`AppColors`, `AppDarkColors`, `ArtColors` for the drawing), and an `AppExtraColors` `ThemeExtension`. Font is Fredoka (bundled).
- **`widgets/chunky.dart`** — shared UI primitives (chunky buttons, custom-painted line icons, progress bar, etc.).

## Tests

- `test/coloring_controller_test.dart` builds `ColoringPicture` directly from hand-made `Path`s — use this for controller logic without assets.
- `test/widget_test.dart` loads the real assets via `tester.runAsync(loadControllers)` and calls `SharedPreferences.setMockInitialValues({})` in `setUp`. The celebration screen's confetti never stops animating, so don't use `pumpAndSettle()` once a picture is completed — pump fixed durations instead.
