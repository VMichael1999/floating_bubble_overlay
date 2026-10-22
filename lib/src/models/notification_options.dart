/// Options for the foreground service notification shown while the bubble is running.
class NotificationOptions {
  /// The id of the service notification.
  final int id;

  /// The title of the service notification.
  final String? title;

  /// The body of the service notification.
  final String? body;

  /// The icon of the service notification.
  final String? icon;

  /// The channel id of the service notification.
  ///
  /// Android does not let apps change the importance of an existing channel, so
  /// use a new id if a previous version of your app already created this channel.
  final String channelId;

  /// The channel name of the service notification.
  final String channelName;

  /// Whether to show a button in the notification that closes the bubble.
  ///
  /// Closing the bubble this way triggers the `onClose` callback.
  final bool showStopAction;

  /// The label of the stop button shown when [showStopAction] is `true`.
  final String stopActionLabel;

  const NotificationOptions({
    this.id = 101,
    this.title,
    this.body,
    this.icon,
    this.channelId = 'bubble_notification',
    this.channelName = 'Bubble Notification',
    this.showStopAction = false,
    this.stopActionLabel = 'Stop',
  });

  /// Serializes the options for the native side.
  Map<String, dynamic> toMap() {
    return {
      'notificationId': id,
      'notificationTitle': title,
      'notificationBody': body,
      'notificationIcon': icon,
      'notificationChannelId': channelId,
      'notificationChannelName': channelName,
      'notificationShowStopAction': showStopAction,
      'notificationStopActionLabel': stopActionLabel,
    };
  }
}
