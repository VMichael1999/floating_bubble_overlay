<img src="doc/fondo.png" width="100%" alt="Dash Bubble Banner" />

<h2 align="center">
  Floating Bubble Overlay
</h2>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform">
  </a>
  <a href="#">
    <img alt="Version" src="https://img.shields.io/badge/Version-1.0.6-blue">
  </a>
  <br>
</p>

---

## 💡 Overview

**Floating Bubble Overlay** is a Flutter plugin that shows a floating bubble (chat head) on top of other apps, similar to Facebook Messenger.
It is built on top of [Floating-Bubble-View](https://github.com/TorryDo/Floating-Bubble-View).

- ✔ Tap the bubble → brings your app to the foreground (configurable with `openAppOnTap`)
- ✔ Drag the bubble → shows a close "X" zone (`following` or `fixed`)
- ✔ Custom bubble and close icons (falls back to your app icon)
- ✔ Tap down / tap up / move callbacks
- ✔ Customizable foreground service notification

> **Note:** Only **Android** is supported (API 21+). Android does not let other platforms draw over apps, so on iOS / web every method simply returns `false`.

<br>

<p align="center">
<img src="doc/demo.gif" width="30%" alt="Floating Bubble Overlay Demo" />
</p>

---

## 🔧 Setup

Add the dependency:

```yaml
dependencies:
  floating_bubble_overlay: ^1.0.6
```

Android `minSdk` must be **21** or higher (`android/app/build.gradle`).

The plugin's manifest already declares, and you **do not** need to add them yourself:

- `SYSTEM_ALERT_WINDOW`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`
- the `BubbleService` foreground service (`foregroundServiceType="specialUse"`, with the subtype property required by Android 14+)

### Custom icons

`bubbleIcon`, `closeIcon` and the notification `icon` are **drawable resource names without extension**, placed in your **app**:

```
android/app/src/main/res/drawable/my_bubble.png   →   bubbleIcon: 'my_bubble'
```

If the resource is not found, the app icon (or a default close icon) is used.

---

## 💻 Usage

```dart
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';

final bubble = FloatingBubbleOverlay.instance;

// 1. Permissions
if (!await bubble.hasOverlayPermission()) {
  await bubble.requestOverlayPermission();
}
await bubble.requestPostNotificationsPermission(); // Android 13+

// 2. Start
final started = await bubble.startBubble(
  bubbleOptions: const BubbleOptions(
    bubbleIcon: 'my_bubble',
    bubbleSize: 64,
    opacity: 1,
    closeBehavior: CloseBehavior.following,
    keepAliveWhenAppExit: false,
  ),
  notificationOptions: const NotificationOptions(
    title: 'Bubble is running',
    body: 'Tap the bubble to come back',
  ),
  onTap: () => print('tapped'),
  onMove: (x, y) => print('moved to $x, $y'),
);

// 3. Stop
await bubble.stopBubble();
```

`startBubble` returns `false` if the overlay permission is missing or the bubble is already running (the callbacks of the running bubble are kept).

---

## 🎨 BubbleOptions

| Option | Description | Default |
|-------|-------------|---------|
| `bubbleIcon` | Drawable name of the bubble icon | app icon |
| `closeIcon` | Drawable name of the close icon | system close icon |
| `startLocationX` / `startLocationY` | Initial position (dp) | `0` / `200` |
| `bubbleSize` | Bubble width and height (dp), must be `> 0` | `60` |
| `opacity` | Transparency, `0.0` → `1.0` | `1.0` |
| `enableClose` | Show the close "X" while dragging | `true` |
| `closeBehavior` | `CloseBehavior.following` (X follows the bubble) or `CloseBehavior.fixed` (X fixed at the bottom) | `following` |
| `distanceToClose` | Distance (dp) at which the bubble snaps to the "X" | `100` |
| `enableAnimateToEdge` | Snap the bubble to the screen edge on release | `true` |
| `enableBottomShadow` | Gradient behind the close button | `true` |
| `keepAliveWhenAppExit` | Keep the bubble when the app is swiped away | `false` |
| `openAppOnTap` | Bring the app to the foreground when the bubble is tapped | `true` |

## 🔔 NotificationOptions

`id` (default `101`), `title` (defaults to the app name), `body`, `icon` (drawable name), `channelId`, `channelName`.

---

## 📱 Compatibility

| Platform | Support |
|---------|---------|
| Android (API 21+) | ✔ |
| iOS / Web / Desktop | ❌ methods return `false` |

---

## 🧑‍💻 Author

Developed and maintained by **Michael Anthony Valdiviezo Maza**.
Licensed under the MIT license. Built on [Floating-Bubble-View](https://github.com/TorryDo/Floating-Bubble-View) by TorryDo.
