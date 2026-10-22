import 'package:flutter_test/flutter_test.dart';
import 'package:floating_bubble_overlay/src/method_channel/floating_bubble_method_channel.dart';
import 'package:floating_bubble_overlay/src/method_channel/floating_bubble_platform_interface.dart';

/// A platform that relies on the base class defaults.
class _UnimplementedPlatform extends FloatingBubbleOverlayPlatform {}

void main() {
  test('the default instance uses method channels', () {
    expect(
      FloatingBubbleOverlayPlatform.instance,
      isA<MethodChannelFloatingBubbleOverlay>(),
    );
  });

  test('base methods throw UnimplementedError', () {
    final platform = _UnimplementedPlatform();
    final calls = <Future<bool> Function()>[
      platform.requestOverlayPermission,
      platform.hasOverlayPermission,
      platform.requestPostNotificationsPermission,
      platform.hasPostNotificationsPermission,
      platform.isRunning,
      platform.startBubble,
      platform.stopBubble,
      platform.hideBubble,
      platform.showBubble,
      platform.isBubbleVisible,
    ];
    for (final call in calls) {
      expect(call(), throwsUnimplementedError);
    }
  });

  test('a custom platform can be registered', () {
    final platform = _UnimplementedPlatform();
    FloatingBubbleOverlayPlatform.instance = platform;
    expect(FloatingBubbleOverlayPlatform.instance, same(platform));
  });
}
