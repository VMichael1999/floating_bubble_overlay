import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'floating_bubble_platform_interface.dart';
import '../constants.dart';
import '../models/models.dart';

/// An implementation of [FloatingBubbleOverlayPlatform] that uses method channels.
class MethodChannelFloatingBubbleOverlay extends FloatingBubbleOverlayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(Constants.methodChannel);

  /// Whether the current platform is supported (Android only).
  @visibleForTesting
  bool Function() isSupportedPlatform =
      () => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  VoidCallback? _onTap;
  void Function(double x, double y)? _onTapDown;
  void Function(double x, double y)? _onTapUp;
  void Function(double x, double y)? _onMove;
  VoidCallback? _onClose;

  bool _handlerRegistered = false;

  /// The main wrapper for invoking methods on the method channel.
  ///
  /// This method will catch any [PlatformException] or [MissingPluginException], log the error, and rethrow it.
  ///
  /// returns `false` if the platform is not Android.
  Future<bool> _invokeMethod(String method, [dynamic arguments]) async {
    // If the platform is not Android, return false.
    if (!isSupportedPlatform()) return false;

    try {
      return await methodChannel.invokeMethod<bool>(method, arguments) ?? false;
    } on PlatformException catch (_) {
      logError(
        'PlatformException: $method\n\nPlease report this issue on GitHub via: https://github.com/VMichael1999/floating_bubble_overlay/issues/new',
      );
      rethrow;
    } on MissingPluginException catch (_) {
      logError(
        'MissingPluginException: $method\n\nIf you have not restarted your app after adding the plugin, please do and try again.',
      );
      rethrow;
    }
  }

  /// Registers the single native -> Dart handler the first time it is needed.
  void _ensureHandlerRegistered() {
    if (_handlerRegistered) return;
    _handlerRegistered = true;
    methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case Constants.onTap:
        _onTap?.call();
      case Constants.onTapDown:
        _callWithCoordinates(_onTapDown, call.arguments);
      case Constants.onTapUp:
        _callWithCoordinates(_onTapUp, call.arguments);
      case Constants.onMove:
        _callWithCoordinates(_onMove, call.arguments);
      case Constants.onClose:
        _onClose?.call();
      default:
        throw MissingPluginException(
          'Method ${call.method} is not implemented',
        );
    }
  }

  void _callWithCoordinates(
    void Function(double x, double y)? callback,
    dynamic arguments,
  ) {
    if (callback == null || arguments is! Map) return;
    final x = arguments[Constants.xAxisValue];
    final y = arguments[Constants.yAxisValue];
    if (x is num && y is num) callback(x.toDouble(), y.toDouble());
  }

  /// Invokes the method channel to request permission to draw over other apps.
  @override
  Future<bool> requestOverlayPermission() async {
    return (await _invokeMethod(Constants.requestOverlayPermission));
  }

  /// Invokes the method channel to check if the permission to draw over other apps is granted.
  @override
  Future<bool> hasOverlayPermission() async {
    return (await _invokeMethod(Constants.hasOverlayPermission));
  }

  /// Invokes the method channel to request post notifications permission.
  @override
  Future<bool> requestPostNotificationsPermission() async {
    return (await _invokeMethod(Constants.requestPostNotificationsPermission));
  }

  /// Invokes the method channel to check if the post notifications permission is granted.
  @override
  Future<bool> hasPostNotificationsPermission() async {
    return (await _invokeMethod(Constants.hasPostNotificationsPermission));
  }

  /// Invokes the method channel to check if the bubble is currently running.
  @override
  Future<bool> isRunning() async {
    return (await _invokeMethod(Constants.isRunning));
  }

  /// Invokes the method channel to start the bubble.
  ///
  /// The callbacks are only replaced when the bubble is actually started, so a
  /// rejected call (for example because the bubble is already running) does not
  /// drop the callbacks of the running bubble.
  @override
  Future<bool> startBubble({
    BubbleOptions? bubbleOptions,
    NotificationOptions? notificationOptions,
    VoidCallback? onTap,
    Function(double x, double y)? onTapDown,
    Function(double x, double y)? onTapUp,
    Function(double x, double y)? onMove,
    VoidCallback? onClose,
  }) async {
    final previousOnTap = _onTap;
    final previousOnTapDown = _onTapDown;
    final previousOnTapUp = _onTapUp;
    final previousOnMove = _onMove;
    final previousOnClose = _onClose;

    _ensureHandlerRegistered();
    _onTap = onTap;
    _onTapDown = onTapDown;
    _onTapUp = onTapUp;
    _onMove = onMove;
    _onClose = onClose;

    var started = false;
    try {
      started = await _invokeMethod(Constants.startBubble, {
        ...(bubbleOptions ?? const BubbleOptions()).toMap(),
        ...(notificationOptions ?? const NotificationOptions()).toMap(),
      });
      return started;
    } finally {
      if (!started) {
        _onTap = previousOnTap;
        _onTapDown = previousOnTapDown;
        _onTapUp = previousOnTapUp;
        _onMove = previousOnMove;
        _onClose = previousOnClose;
      }
    }
  }

  /// Invokes the method channel to stop the bubble.
  @override
  Future<bool> stopBubble() async {
    return (await _invokeMethod(Constants.stopBubble));
  }

  /// Invokes the method channel to hide the bubble without stopping the service.
  @override
  Future<bool> hideBubble() async {
    return (await _invokeMethod(Constants.hideBubble));
  }

  /// Invokes the method channel to show the bubble again.
  @override
  Future<bool> showBubble() async {
    return (await _invokeMethod(Constants.showBubble));
  }

  /// Invokes the method channel to check if the bubble is running and visible.
  @override
  Future<bool> isBubbleVisible() async {
    return (await _invokeMethod(Constants.isBubbleVisible));
  }

  /// Logs an error message.
  void logError(String message) {
    log(message, name: Constants.errorLogName);
  }
}
