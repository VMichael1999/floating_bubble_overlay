import 'package:flutter/foundation.dart' show VoidCallback;

import 'src/method_channel/floating_bubble_platform_interface.dart';
import 'src/models/models.dart';

export 'src/enums/enums.dart';
export 'src/models/models.dart';

/// The main class of the plugin.
///
/// Only Android is supported. On other platforms every method completes with `false`.
class FloatingBubbleOverlay {
  /// Private constructor to prevent instantiation.
  FloatingBubbleOverlay._();

  /// Singleton Pattern
  static final FloatingBubbleOverlay instance = FloatingBubbleOverlay._();

  /// Request permission to draw over other apps (overlay permission).
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  ///
  /// If the permission is already granted, this method will return `true` without asking the user.
  ///
  /// In Android versions prior to `Android 6.0 (M)`, this method will return `true` without asking the user.
  Future<bool> requestOverlayPermission() {
    return FloatingBubbleOverlayPlatform.instance.requestOverlayPermission();
  }

  /// Check if draw over other apps (overlay) permission is granted or not.
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  ///
  /// In Android versions prior to `Android 6.0 (M)`, this method will always return `true`.
  Future<bool> hasOverlayPermission() {
    return FloatingBubbleOverlayPlatform.instance.hasOverlayPermission();
  }

  /// Request post notifications permission (Used to customize the service notification)
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  ///
  /// The user can be asked for the permission only twice, if the user denied
  /// the permission twice, the function would not be able to ask for the
  /// permission anymore and it will return false, however, the user can still
  /// grant the permission manually from the app settings page.
  ///
  /// In Android versions prior to `Android 13 (Tiramisu)`, this method will return `true` without asking the user.
  Future<bool> requestPostNotificationsPermission() {
    return FloatingBubbleOverlayPlatform.instance
        .requestPostNotificationsPermission();
  }

  /// Check if the post notifications permission is granted or not.
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  ///
  /// In Android versions prior to `Android 13 (Tiramisu)`, this method will always return `true`.
  Future<bool> hasPostNotificationsPermission() {
    return FloatingBubbleOverlayPlatform.instance
        .hasPostNotificationsPermission();
  }

  /// Check if the bubble is currently running.
  ///
  /// Returns `true` if the bubble is running, `false` otherwise.
  ///
  /// The bubble is considered running if it is visible on the screen.
  ///
  /// If the bubble is not running, you can start it by calling [startBubble].
  ///
  /// If the bubble is running, you can stop it by calling [stopBubble].
  Future<bool> isRunning() {
    return FloatingBubbleOverlayPlatform.instance.isRunning();
  }

  /// Start the bubble.
  ///
  /// Returns `true` if the bubble is started successfully, `false` otherwise.
  ///
  /// If the bubble is already running or the permission is not granted, this method will return `false`.
  ///
  /// [bubbleOptions] is an optional parameter that allows you to customize the bubble.
  ///
  /// [notificationOptions] is an optional parameter that customizes the foreground service notification.
  ///
  /// [onTap] is an optional callback that will be called when the bubble is tapped.
  ///
  /// [onTapDown] is an optional callback that will be called when the bubble is tapped down (pressed), it will receive the `x` and `y` coordinates of the bubble when it is tapped down (pressed).
  ///
  /// [onTapUp] is an optional callback that will be called when the bubble is tapped up (released), it will receive the `x` and `y` coordinates of the bubble when it is tapped up (released).
  ///
  /// [onMove] is an optional callback that will be called when the bubble is moved, it will receive the new `x` and `y` coordinates of the bubble after it is moved.
  ///
  /// [onClose] is an optional callback that will be called when the user closes the bubble,
  /// either by dragging it to the close button or with the notification stop button.
  /// It is not called when the app calls [stopBubble].
  ///
  /// Callbacks are only delivered while the Flutter app is alive. If the bubble outlives the app
  /// (see [BubbleOptions.keepAliveWhenAppExit]), events that happen after the app is closed are lost.
  Future<bool> startBubble({
    BubbleOptions? bubbleOptions,
    NotificationOptions? notificationOptions,
    VoidCallback? onTap,
    Function(double x, double y)? onTapDown,
    Function(double x, double y)? onTapUp,
    Function(double x, double y)? onMove,
    VoidCallback? onClose,
  }) {
    return FloatingBubbleOverlayPlatform.instance.startBubble(
      bubbleOptions: bubbleOptions,
      notificationOptions: notificationOptions,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onMove: onMove,
      onClose: onClose,
    );
  }

  /// Stop the bubble.
  ///
  /// Returns `true` if the bubble is stopped successfully, `false` otherwise.
  ///
  /// If the bubble is not running, this method will return `false`.
  Future<bool> stopBubble() {
    return FloatingBubbleOverlayPlatform.instance.stopBubble();
  }

  /// Hide the bubble without stopping the service.
  ///
  /// The service and its notification stay alive, so the bubble can be shown again
  /// instantly with [showBubble], keeping its callbacks.
  ///
  /// Returns `false` if the bubble is not running or is already hidden.
  Future<bool> hideBubble() {
    return FloatingBubbleOverlayPlatform.instance.hideBubble();
  }

  /// Show the bubble again after [hideBubble].
  ///
  /// Returns `false` if the bubble is not running or is already visible.
  Future<bool> showBubble() {
    return FloatingBubbleOverlayPlatform.instance.showBubble();
  }

  /// Check if the bubble is running and currently visible (not hidden with [hideBubble]).
  Future<bool> isBubbleVisible() {
    return FloatingBubbleOverlayPlatform.instance.isBubbleVisible();
  }
}
