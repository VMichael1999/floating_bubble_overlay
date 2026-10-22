// Runs on a real device or emulator. Grant the overlay permission first:
//   adb shell appops set com.example.floating_bubble_overlay_example SYSTEM_ALERT_WINDOW allow
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final bubble = FloatingBubbleOverlay.instance;

  Future<void> settle() => Future<void>.delayed(const Duration(seconds: 1));

  setUp(() async {
    await bubble.stopBubble();
    await settle();
  });

  tearDown(() async {
    await bubble.stopBubble();
  });

  testWidgets('overlay permission is granted', (_) async {
    expect(await bubble.hasOverlayPermission(), isTrue);
  });

  testWidgets('start, hide, show and stop', (_) async {
    var closes = 0;
    expect(
      await bubble.startBubble(
        bubbleOptions: const BubbleOptions(
          bubbleIconAsset: 'assets/bubble.png',
          closeIconAsset: 'assets/close.png',
          closeIconSize: 56,
        ),
        notificationOptions: const NotificationOptions(showStopAction: true),
        onClose: () => closes++,
      ),
      isTrue,
    );
    await settle();
    expect(await bubble.isRunning(), isTrue);
    expect(await bubble.isBubbleVisible(), isTrue);

    // Starting twice is rejected.
    expect(await bubble.startBubble(), isFalse);

    expect(await bubble.hideBubble(), isTrue);
    expect(await bubble.isBubbleVisible(), isFalse);
    expect(await bubble.hideBubble(), isFalse);
    expect(await bubble.isRunning(), isTrue);

    expect(await bubble.showBubble(), isTrue);
    expect(await bubble.isBubbleVisible(), isTrue);

    expect(await bubble.stopBubble(), isTrue);
    await settle();
    expect(await bubble.isRunning(), isFalse);
    expect(await bubble.isBubbleVisible(), isFalse);

    // Stopping from the app is not a user close.
    expect(closes, 0);
  });

  testWidgets('can start again after stopping', (_) async {
    expect(await bubble.startBubble(), isTrue);
    await settle();
    expect(await bubble.stopBubble(), isTrue);
    await settle();
    expect(await bubble.startBubble(), isTrue);
    await settle();
    expect(await bubble.isRunning(), isTrue);
  });

  testWidgets('hide and show fail when not running', (_) async {
    expect(await bubble.hideBubble(), isFalse);
    expect(await bubble.showBubble(), isFalse);
    expect(await bubble.stopBubble(), isFalse);
  });
}
