import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'floating_bubble_method_channel.dart';
import '../models/models.dart';

/// The interface that platform implementations of floating_bubble_overlay must extend.
abstract class FloatingBubbleOverlayPlatform extends PlatformInterface {
  /// Constructs a FloatingBubbleOverlayPlatform.
  FloatingBubbleOverlayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FloatingBubbleOverlayPlatform _instance =
      MethodChannelFloatingBubbleOverlay();

  /// The default instance of [FloatingBubbleOverlayPlatform] to use.
  ///
  /// Defaults to [MethodChannelFloatingBubbleOverlay].
  static FloatingBubbleOverlayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FloatingBubbleOverlayPlatform] when
  /// they register themselves.
  static set instance(FloatingBubbleOverlayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Request permission to draw over other apps.
  Future<bool> requestOverlayPermission() async {
    throw UnimplementedError(
      'requestOverlayPermission() has not been implemented.',
    );
  }

  /// Check if the permission to draw over other apps is granted.
  Future<bool> hasOverlayPermission() async {
    throw UnimplementedError(
      'hasOverlayPermission() has not been implemented.',
    );
  }

  /// Request post notifications permission.
  Future<bool> requestPostNotificationsPermission() async {
    throw UnimplementedError(
      'requestPostNotificationsPermission() has not been implemented.',
    );
  }

  /// Check if the post notifications permission is granted.
  Future<bool> hasPostNotificationsPermission() async {
    throw UnimplementedError(
      'hasPostNotificationsPermission() has not been implemented.',
    );
  }

  /// Check if the bubble is currently running.
  Future<bool> isRunning() async {
    throw UnimplementedError('isRunning() has not been implemented.');
  }

  /// Start the bubble.
  Future<bool> startBubble({
    BubbleOptions? bubbleOptions,
    NotificationOptions? notificationOptions,
    VoidCallback? onTap,
    Function(double x, double y)? onTapDown,
    Function(double x, double y)? onTapUp,
    Function(double x, double y)? onMove,
    VoidCallback? onClose,
  }) async {
    throw UnimplementedError('startBubble() has not been implemented.');
  }

  /// Stop the bubble.
  Future<bool> stopBubble() async {
    throw UnimplementedError('stopBubble() has not been implemented.');
  }

  /// Hide the bubble without stopping the service.
  Future<bool> hideBubble() async {
    throw UnimplementedError('hideBubble() has not been implemented.');
  }

  /// Show the bubble again after [hideBubble].
  Future<bool> showBubble() async {
    throw UnimplementedError('showBubble() has not been implemented.');
  }

  /// Check if the bubble is running and visible.
  Future<bool> isBubbleVisible() async {
    throw UnimplementedError('isBubbleVisible() has not been implemented.');
  }
}
