package com.example.floating_bubble_overlay.src

import android.os.Parcelable
import io.flutter.plugin.common.MethodCall
import kotlinx.parcelize.Parcelize

/** NotificationOptions is the class that contains the options for the service notification.
 * @param id The id of the notification that will be shown when the bubble is running.
 * @param title The title of the notification that will be shown when the bubble is running.
 * @param body The body of the notification that will be shown when the bubble is running.
 * @param icon The icon of the notification that will be shown when the bubble is running.
 * @param channelId The channel id of the notification that will be shown when the bubble is running.
 * @param channelName The channel name of the notification that will be shown when the bubble is running.
 * @param showStopAction Whether the notification shows a button that closes the bubble.
 * @param stopActionLabel The label of the stop button.
 */
@Parcelize
data class NotificationOptions(
    val id: Int?,
    val title: String?,
    val body: String?,
    val icon: String?,
    val channelId: String?,
    val channelName: String?,
    val showStopAction: Boolean?,
    val stopActionLabel: String?,
) : Parcelable {
    companion object {
        /**
         * Get the notification options from the method call.
         * @param call The method call.
         * @return The notification options.
         */
        fun fromMethodCall(call: MethodCall): NotificationOptions {
            return NotificationOptions(
                call.argument(Constants.NOTIFICATION_ID),
                call.argument(Constants.NOTIFICATION_TITLE),
                call.argument(Constants.NOTIFICATION_BODY),
                call.argument(Constants.NOTIFICATION_ICON),
                call.argument(Constants.NOTIFICATION_CHANNEL_ID),
                call.argument(Constants.NOTIFICATION_CHANNEL_NAME),
                call.argument(Constants.NOTIFICATION_SHOW_STOP_ACTION),
                call.argument(Constants.NOTIFICATION_STOP_ACTION_LABEL),
            )
        }
    }
}
