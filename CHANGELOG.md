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