/// This class contains all the constants used in the plugin.
class Constants {
  /// Private constructor to prevent instantiation.
  Constants._(); // coverage:ignore-line

  // Method Channel
  static const methodChannel = 'floating_bubble_overlay';

  // Miscellaneous
  static const errorLogName = 'FloatingBubbleOverlay';
  static const xAxisValue = 'xAxisValue';
  static const yAxisValue = 'yAxisValue';

  // Native Methods Names
  static const requestOverlayPermission = 'requestOverlayPermission';
  static const hasOverlayPermission = 'hasOverlayPermission';
  static const requestPostNotificationsPermission =
      'requestPostNotificationsPermission';
  static const hasPostNotificationsPermission =
      'hasPostNotificationsPermission';
  static const isRunning = 'isRunning';
  static const startBubble = 'startBubble';
  static const stopBubble = 'stopBubble';
  static const hideBubble = 'hideBubble';
  static const showBubble = 'showBubble';
  static const isBubbleVisible = 'isBubbleVisible';
  static const onTap = 'onTap';
  static const onTapDown = 'onTapDown';
  static const onTapUp = 'onTapUp';
  static const onMove = 'onMove';
  static const onClose = 'onClose';
}
