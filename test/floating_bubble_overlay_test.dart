import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';
import 'package:floating_bubble_overlay/src/method_channel/floating_bubble_method_channel.dart';
import 'package:floating_bubble_overlay/src/method_channel/floating_bubble_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelFloatingBubbleOverlay platform;
  late List<MethodCall> calls;
  late Object? Function(MethodCall) handler;

  setUp(() {
    platform = MethodChannelFloatingBubbleOverlay();
    platform.isSupportedPlatform = () => true;
    FloatingBubbleOverlayPlatform.instance = platform;
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
          platform.methodChannel.codec.encodeMethodCall(
            MethodCall(method, args),
          ),
          (_) {},
        );
  }

  test(
    'returns false on unsupported platforms without calling native',
    () async {
      platform.isSupportedPlatform = () => false;
      expect(await FloatingBubbleOverlay.instance.isRunning(), isFalse);
      expect(calls, isEmpty);
    },
  );

  test('null native result is treated as false', () async {
    handler = (_) => null;
    expect(
      await FloatingBubbleOverlay.instance.hasOverlayPermission(),
      isFalse,
    );
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
    expect(() => BubbleOptions(closeIconSize: 0), throwsAssertionError);
  });

  test('startBubble sends the 1.1.0 options', () async {
    await FloatingBubbleOverlay.instance.startBubble(
      bubbleOptions: const BubbleOptions(
        bubbleIconAsset: 'assets/bubble.png',
        closeIconAsset: 'assets/close.png',
        closeIconSize: 48,
      ),
      notificationOptions: const NotificationOptions(
        showStopAction: true,
        stopActionLabel: 'Detener',
      ),
    );
    final args = calls.single.arguments as Map;
    expect(args['bubbleIconAsset'], 'assets/bubble.png');
    expect(args['closeIconAsset'], 'assets/close.png');
    expect(args['closeIconSize'], 48);
    expect(args['notificationShowStopAction'], true);
    expect(args['notificationStopActionLabel'], 'Detener');
  });

  test('defaults keep previous behavior', () {
    final bubble = const BubbleOptions().toMap();
    final notification = const NotificationOptions().toMap();
    expect(bubble['bubbleIconAsset'], isNull);
    expect(bubble['closeIconSize'], isNull);
    expect(bubble['openAppOnTap'], true);
    expect(notification['notificationShowStopAction'], false);
  });

  test('forwards onClose', () async {
    var closes = 0;
    await FloatingBubbleOverlay.instance.startBubble(onClose: () => closes++);
    await emit('onClose');
    expect(closes, 1);
  });

  test('hide, show and isBubbleVisible call native', () async {
    expect(await FloatingBubbleOverlay.instance.hideBubble(), isTrue);
    expect(await FloatingBubbleOverlay.instance.showBubble(), isTrue);
    expect(await FloatingBubbleOverlay.instance.isBubbleVisible(), isTrue);
    expect(calls.map((c) => c.method), [
      'hideBubble',
      'showBubble',
      'isBubbleVisible',
    ]);
  });

  test('BubbleBackground is serialized inside the options', () async {
    await FloatingBubbleOverlay.instance.startBubble(
      bubbleOptions: const BubbleOptions(
        bubbleBackground: BubbleBackground(
          shape: BubbleShape.roundedSquare,
          color: Color(0xFF0A66C2),
          padding: 8,
          cornerRadius: 16,
          borderColor: Color(0xFFFFFFFF),
          borderWidth: 2,
        ),
        closeIconBackground: BubbleBackground(imageAsset: 'assets/bg.png'),
      ),
    );
    final args = calls.single.arguments as Map;
    expect(args['bubbleBackground'], {
      'shape': BubbleShape.roundedSquare.index,
      'color': 0xFF0A66C2,
      'imageAsset': null,
      'padding': 8,
      'cornerRadius': 16,
      'borderColor': 0xFFFFFFFF,
      'borderWidth': 2,
    });
    expect((args['closeIconBackground'] as Map)['imageAsset'], 'assets/bg.png');
    expect((args['closeIconBackground'] as Map)['shape'], 0);
  });

  test('no background by default', () {
    final map = const BubbleOptions().toMap();
    expect(map['bubbleBackground'], isNull);
    expect(map['closeIconBackground'], isNull);
  });

  test('BubbleBackground validates values', () {
    expect(() => BubbleBackground(padding: -1), throwsAssertionError);
    expect(() => BubbleBackground(borderWidth: -1), throwsAssertionError);
  });

  test('closeIconColor is sent as ARGB', () async {
    await FloatingBubbleOverlay.instance.startBubble(
      bubbleOptions: const BubbleOptions(closeIconColor: Color(0xFFD32F2F)),
    );
    final args = calls.single.arguments as Map;
    expect(args['closeIconColor'], 0xFFD32F2F);
    expect(const BubbleOptions().toMap()['closeIconColor'], isNull);
  });
}
