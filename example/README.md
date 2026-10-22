# floating_bubble_overlay example

A playground for every feature of the plugin:

- Request and check the overlay and notification permissions.
- Start the bubble with icons from Flutter assets (`assets/bubble.png`, `assets/close.png`).
- Hide / show the bubble without stopping the service.
- Notification with a "Close bubble" button, and the `onClose` callback.
- The bubble appears when you leave the app and hides when you come back.

## Run

```bash
flutter run
```

## Integration tests (device or emulator)

```bash
adb shell appops set com.example.floating_bubble_overlay_example SYSTEM_ALERT_WINDOW allow
flutter test integration_test
```
