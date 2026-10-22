## 1.1.1
- Fix the README banner not showing on pub.dev in dark mode.
- Show the banner and the demo GIF as screenshots on pub.dev.

## 1.1.0
### New
- `BubbleOptions.bubbleIconAsset` / `closeIconAsset`: use images from your Flutter `assets/` as icons.
- `BubbleOptions.closeIconSize`: the close icon no longer has to match the bubble size.
- `BubbleOptions.bubbleBackground` / `closeIconBackground`: optional background behind the icon (`BubbleShape.circle`, `square`, `roundedSquare`) with a color, an image asset, padding and a border. Without it, icons are drawn as before.
- `BubbleOptions.closeIconColor`: recolor the close icon (e.g. the default "X") without creating an image.
- `hideBubble()`, `showBubble()` and `isBubbleVisible()`: hide the bubble without stopping the service.
- `onClose` callback in `startBubble`: called when the user closes the bubble (drag to close or notification button).
- `NotificationOptions.showStopAction` / `stopActionLabel`: optional "Stop" button in the notification.
- Tapping the notification now opens the app.

### Fixes
- If Android killed the app process, the service came back without the bubble and `startBubble` returned `false` until the app was restarted. The bubble is now restored with the same options.
- Crash (`Unable to create service`) when Android restarted the service after the overlay permission was revoked.
- The notification channel used default importance (could make a sound); it is now created with low importance. Existing channels keep their importance: use a new `channelId` to get the new behavior.
- Removed the JitPack repository the plugin injected into host apps.

### Other
- Example app: app icon / asset icon switch, background shape and fill options, close icon styles, Flutter asset icons, hide/show, `onClose`, notification stop button, and the "bubble only while in background" pattern. Restored the missing light theme.
- Integration tests running on a device/emulator and GitHub Actions CI with a 90% minimum coverage (Dart code is at 100%) and Codecov reports.
- README badges: pub.dev version and points, CI, coverage, license, platform and Flutter version.
- Repository links now point to github.com/VMichael1999/floating_bubble_overlay.
- README: events, API table, Google Play policy notes and troubleshooting.

## 1.0.6
- **Fix:** `CloseBehavior`, `BubbleOptions` and `NotificationOptions` are now exported from `package:floating_bubble_overlay/floating_bubble_overlay.dart`.
- **Fix:** `CloseBehavior.following` was silently behaving as `fixed`; both values now map explicitly to the native behaviors.
- **Fix:** native crashes (`lateinit` not initialized) when a method is called without an attached Activity; the bubble can now be queried/started/stopped without one.
- **Fix:** pending permission requests could be overwritten or never completed; concurrent requests now fail fast with an error.
- **Fix:** the Dart callbacks of a running bubble were replaced even when `startBubble` returned `false`.
- **Fix:** manifest now declares the `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` required by Android 14+.
- **Fix:** no longer imports `dart:io` (works when compiled for web; returns `false` on unsupported platforms).
- **New:** `BubbleOptions.openAppOnTap` to disable bringing the app to the foreground on tap.
- `BubbleOptions` / `NotificationOptions` constructors are `const`; `bubbleSize` must be `> 0`.
- Removed the placeholder iOS implementation (the plugin is Android-only).
- Rewrote the README to match the real API, and fixed the native/Dart tests.

## 1.0.5
- Initial release.
- Android floating bubble overlay based on Floating-Bubble-View.
- Drag-to-close behavior with bottom close target.
- Tap on bubble can bring the app to foreground (when enabled).
- Supports custom bubble and close icons, size, opacity, and close behavior.