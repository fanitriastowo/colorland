# colorland

coloring image app from SVG image with path tracing

## Getting Started

This project is a starting point for a Flutter application.

## Run on iOS

Requires macOS, Xcode (with the iOS Simulator), and the Flutter SDK.

```sh
flutter pub get
open -a Simulator
flutter run            # or: flutter devices, then flutter run -d <device-id>
```

Or paste this into a shell (same as `scripts: ios` in `pubspec.yaml`). It
reuses a booted simulator, or boots the last available iPhone/iPad, then runs
the app on it:

```sh
BOOTED_ID=$(xcrun simctl list devices | grep "Booted" | head -n 1 | sed -E 's/.*([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}).*/\1/')
if [ -z "$BOOTED_ID" ]; then
  LAST_ID=$(xcrun simctl list devices | grep -E "iPhone|iPad" | grep -v "unavailable" | tail -n 1 | sed -E 's/.*([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}).*/\1/')
  xcrun simctl boot "$LAST_ID"
  open -a Simulator
  flutter run -d "$LAST_ID"
else
  flutter run -d "$BOOTED_ID"
fi
```

To run on a physical iPhone, open `ios/Runner.xcworkspace` in Xcode, set a
signing Team under Runner → Signing & Capabilities, then
`flutter run -d <device-id>`.

