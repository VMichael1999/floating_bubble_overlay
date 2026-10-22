import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';
import 'package:floating_bubble_overlay/src/method_channel/dash_bubble_method_channel.dart';
import 'package:floating_bubble_overlay/src/method_channel/dash_bubble_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelDashBubble platform;
  late List<MethodCall> calls;
  late Object? Function(MethodCall) handler;

  setUp(() {
    platform = MethodChannelDashBubble();
    platform.isSupportedPlatform = () => true;
    DashBubblePlatform.instance = platform;
    calls = [];
    handler = (_) => true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
      calls.add(call);
      return handler(call);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });

  Future<void> emit(String method, [Object? args]) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      platform.methodChannel.name,
      platform.methodChannel.codec
          .encodeMethodCall(MethodCall(method, args)),
      (_) {},
    );
  }

  test('returns false on unsupported platforms without calling native', () async {
    platform.isSupportedPlatform = () => false;
    expect(await FloatingBubbleOverlay.instance.isRunning(), isFalse);
    expect(calls, isEmpty);
  });

  test('null native result is treated as false', () async {
    handler = (_) => null;
    expect(await FloatingBubbleOverlay.instance.hasOverlayPermission(), isFalse);
  });

  test('startBubble sends merged options', () async {
    await FloatingBubbleOverlay.instance.startBubble(
      bubbleOptions: const BubbleOptions(
        closeBehavior: CloseBehavior.fixed,
        openAppOnTap: false,
      ),
      notificationOptions: const NotificationOptions(title: 'T'),
    );
    final args = calls.single.arguments as Map;
    expect(calls.single.method, 'startBubble');
    expect(args['closeBehavior'], CloseBehavior.fixed.index);
    expect(args['openAppOnTap'], false);
    expect(args['notificationTitle'], 'T');
    expect(args['notificationId'], 101);
  });

  test('forwards native callbacks', () async {
    var taps = 0;
    double? mx, my;
    await FloatingBubbleOverlay.instance.startBubble(
      onTap: () => taps++,
      onMove: (x, y) {
        mx = x;
        my = y;
      },
    );
    await emit('onTap');
    await emit('onMove', {'xAxisValue': 1.5, 'yAxisValue': 2});
    expect(taps, 1);
    expect([mx, my], [1.5, 2.0]);
  });

  test('rejected startBubble keeps the previous callbacks', () async {
    var first = 0, second = 0;
    await FloatingBubbleOverlay.instance.startBubble(onTap: () => first++);
    handler = (_) => false;
    expect(
      await FloatingBubbleOverlay.instance.startBubble(onTap: () => second++),
      isFalse,
    );
    await emit('onTap');
    expect([first, second], [1, 0]);
  });

  test('BubbleOptions validates values', () {
    expect(() => BubbleOptions(bubbleSize: 0), throwsAssertionError);
    expect(() => BubbleOptions(opacity: 2), throwsAssertionError);
  });
}
