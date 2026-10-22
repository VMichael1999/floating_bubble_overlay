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
  final String channelId;

  /// The channel name of the service notification.
  final String channelName;

  const NotificationOptions({
    this.id = 101,
    this.title,
    this.body,
    this.icon,
    this.channelId = 'bubble_notification',
    this.channelName = 'Bubble Notification',
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
    };
  }
}
