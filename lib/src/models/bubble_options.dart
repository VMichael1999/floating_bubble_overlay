import '../enums/enums.dart';

/// [BubbleOptions] is a class that contains all the customizable options for the bubble passed to the `FloatingBubbleOverlay.startBubble` method.
class BubbleOptions {
  /// The icon of the bubble.
  final String? bubbleIcon;

  /// The icon of the close button.
  final String? closeIcon;

  /// The initial starting position of the bubble on the x axis (in logical pixels, dp).
  final double startLocationX;

  /// The initial starting position of the bubble on the y axis (in logical pixels, dp).
  final double startLocationY;

  /// The size of the bubble (width and height). Must be greater than 0.
  final double bubbleSize;

  /// The opacity of the bubble and the close button.
  final double opacity;

  /// Whether to show the close button or not.
  final bool enableClose;

  /// How the close button behaves while the bubble is being dragged.
  final CloseBehavior closeBehavior;

  /// The distance between the bubble and the bottom edge of the screen to show the close button.
  final double distanceToClose;

  /// Whether to animate the bubble to the edge of the screen when it is dragged to the edge of the screen or not.
  final bool enableAnimateToEdge;

  /// Whether to show the bottom shadow behind the close button of the bubble or not.
  final bool enableBottomShadow;

  /// Whether to keep the bubble alive when the app is closed or not.
  final bool keepAliveWhenAppExit;

  /// Whether tapping the bubble brings the app to the foreground or not.
  final bool openAppOnTap;

  const BubbleOptions({
    this.bubbleIcon,
    this.closeIcon,
    this.startLocationX = 0,
    this.startLocationY = 200,
    this.bubbleSize = 60,
    this.opacity = 1,
    this.enableClose = true,
    this.closeBehavior = CloseBehavior.following,
    this.distanceToClose = 100,
    this.enableAnimateToEdge = true,
    this.enableBottomShadow = true,
    this.keepAliveWhenAppExit = false,
    this.openAppOnTap = true,
  }) : assert(bubbleSize > 0, 'bubbleSize must be greater than 0'),
       assert(opacity >= 0 && opacity <= 1, 'opacity must be between 0 and 1');

  /// Serializes the options for the native side.
  Map<String, dynamic> toMap() {
    return {
      'bubbleIcon': bubbleIcon,
      'closeIcon': closeIcon,
      'startLocationX': startLocationX,
      'startLocationY': startLocationY,
      'bubbleSize': bubbleSize,
      'opacity': opacity,
      'enableClose': enableClose,
      'closeBehavior': closeBehavior.index,
      'distanceToClose': distanceToClose,
      'enableAnimateToEdge': enableAnimateToEdge,
      'enableBottomShadow': enableBottomShadow,
      'keepAliveWhenAppExit': keepAliveWhenAppExit,
      'openAppOnTap': openAppOnTap,
    };
  }
}
