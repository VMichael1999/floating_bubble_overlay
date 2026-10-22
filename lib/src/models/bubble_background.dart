import 'package:flutter/painting.dart' show Color;

import '../enums/enums.dart';

/// An optional background drawn behind the bubble (or close) icon.
///
/// The icon is drawn centered on top of the background, inset by [padding].
/// Use a [color], an [imageAsset], or both (the image is drawn over the color).
///
/// ```dart
/// const BubbleBackground(
///   shape: BubbleShape.circle,
///   color: Color(0xFF0A66C2),
///   padding: 8,
///   borderColor: Color(0xFFFFFFFF),
///   borderWidth: 2,
/// )
/// ```
class BubbleBackground {
  /// The shape of the background.
  final BubbleShape shape;

  /// The fill color of the background.
  final Color? color;

  /// A Flutter asset (declared in `pubspec.yaml`) drawn as the background,
  /// cropped to fill the [shape].
  final String? imageAsset;

  /// Space between the edge of the background and the icon (dp).
  final double padding;

  /// Corner radius (dp), only used by [BubbleShape.roundedSquare].
  final double cornerRadius;

  /// Color of the border. No border is drawn when it is `null` or [borderWidth] is 0.
  final Color? borderColor;

  /// Width of the border (dp).
  final double borderWidth;

  const BubbleBackground({
    this.shape = BubbleShape.circle,
    this.color,
    this.imageAsset,
    this.padding = 6,
    this.cornerRadius = 12,
    this.borderColor,
    this.borderWidth = 0,
  }) : assert(padding >= 0, 'padding must be greater than or equal to 0'),
       assert(
         cornerRadius >= 0,
         'cornerRadius must be greater than or equal to 0',
       ),
       assert(
         borderWidth >= 0,
         'borderWidth must be greater than or equal to 0',
       );

  /// Serializes the background for the native side.
  Map<String, dynamic> toMap() {
    return {
      'shape': shape.index,
      'color': color?.toARGB32(),
      'imageAsset': imageAsset,
      'padding': padding,
      'cornerRadius': cornerRadius,
      'borderColor': borderColor?.toARGB32(),
      'borderWidth': borderWidth,
    };
  }
}
