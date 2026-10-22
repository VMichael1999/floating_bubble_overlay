import 'package:flutter/painting.dart' show Color;

import '../enums/enums.dart';
import 'bubble_background.dart';

/// [BubbleOptions] is a class that contains all the customizable options for the bubble passed to the `FloatingBubbleOverlay.startBubble` method.
class BubbleOptions {
  /// The icon of the bubble: the name of a drawable resource of the Android app, without extension.
  ///
  /// Defaults to the app icon. Ignored when [bubbleIconAsset] is set.
  final String? bubbleIcon;

  /// The icon of the close button: the name of a drawable resource of the Android app, without extension.
  ///
  /// Ignored when [closeIconAsset] is set.
  final String? closeIcon;

  /// A Flutter asset (declared in `pubspec.yaml`) used as the bubble icon, e.g. `assets/bubble.png`.
  ///
  /// Takes precedence over [bubbleIcon]. Falls back to [bubbleIcon] or the app icon if it cannot be loaded.
  final String? bubbleIconAsset;

  /// A Flutter asset (declared in `pubspec.yaml`) used as the close icon, e.g. `assets/close.png`.
  ///
  /// Takes precedence over [closeIcon].
  final String? closeIconAsset;

  /// The size of the close button (dp). Defaults to [bubbleSize].
  final double? closeIconSize;

  /// An optional background (shape, color, image, border) drawn behind the bubble icon.
  ///
  /// Without it the icon is drawn as is, so transparent PNGs show only the artwork.
  final BubbleBackground? bubbleBackground;

  /// An optional background drawn behind the close icon.
  final BubbleBackground? closeIconBackground;

  /// Tints the close icon with this color, e.g. to recolor the default "X"
  /// without creating an image. Works best with single-color icons.
  final Color? closeIconColor;

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
    this.bubbleIconAsset,
    this.closeIconAsset,
    this.closeIconSize,
    this.bubbleBackground,
    this.closeIconBackground,
    this.closeIconColor,
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
       assert(opacity >= 0 && opacity <= 1, 'opacity must be between 0 and 1'),
       assert(
         closeIconSize == null || closeIconSize > 0,
         'closeIconSize must be greater than 0',
       );

  /// Serializes the options for the native side.
  Map<String, dynamic> toMap() {
    return {
      'bubbleIcon': bubbleIcon,
      'closeIcon': closeIcon,
      'bubbleIconAsset': bubbleIconAsset,
      'closeIconAsset': closeIconAsset,
      'closeIconSize': closeIconSize,
      'bubbleBackground': bubbleBackground?.toMap(),
      'closeIconBackground': closeIconBackground?.toMap(),
      'closeIconColor': closeIconColor?.toARGB32(),
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
