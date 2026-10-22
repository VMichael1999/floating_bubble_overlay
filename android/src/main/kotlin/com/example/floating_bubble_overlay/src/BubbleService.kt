package com.example.floating_bubble_overlay.src

import android.app.Notification
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.torrydo.floatingbubbleview.BubbleBehavior
import com.torrydo.floatingbubbleview.FloatingBubble
import com.torrydo.floatingbubbleview.FloatingBubbleService
import com.torrydo.floatingbubbleview.Route

/** BubbleService is the service that will be started when the bubble is started. */
class BubbleService : FloatingBubbleService() {
    private companion object {
        /** Mirrors the index of `CloseBehavior.fixed` on the Dart side. */
        const val CLOSE_BEHAVIOR_FIXED = 1
    }

    private lateinit var bubbleOptions: BubbleOptions
    private lateinit var notificationOptions: NotificationOptions

    /** This method is called when the service is started
     * It initializes the bubble with the options passed to from the intent and starts the service.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            val bubbleOpts = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(Constants.BUBBLE_OPTIONS_INTENT_EXTRA, BubbleOptions::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Constants.BUBBLE_OPTIONS_INTENT_EXTRA)
            }
            
            val notificationOpts = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(Constants.NOTIFICATION_OPTIONS_INTENT_EXTRA, NotificationOptions::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Constants.NOTIFICATION_OPTIONS_INTENT_EXTRA)
            }
            
            if (bubbleOpts != null && notificationOpts != null) {
                bubbleOptions = bubbleOpts
                notificationOptions = notificationOpts
                
                showBubbles()
                showNotification()
            }
        }

        return super.onStartCommand(intent, flags, startId)
    }

    /** This method is called when the service is created.
     * It is setting the initial route of the bubble to be empty to avoid calling setupBubble method automatically.
     */
    override fun initialRoute(): Route {
        return Route.Empty
    }

    /** This method is called when the service is created.
     * It defines the initial configuration of the notification that will be shown when the bubble is running.
     * It works only for android 8 and higher
     */
    override fun initialNotification(): Notification? {
        return null
    }

    /** Defines the notification id */
    override fun notificationId(): Int =
        if (::notificationOptions.isInitialized) notificationOptions.id ?: 1 else 1

    /** Defines the notification channel id */
    override fun channelId(): String =
        if (::notificationOptions.isInitialized) notificationOptions.channelId ?: "floating_bubble_channel" else "floating_bubble_channel"

    /** Defines the notification channel name */
    override fun channelName(): String =
        if (::notificationOptions.isInitialized) notificationOptions.channelName ?: "Floating Bubble" else "Floating Bubble"

    /** This method defines the main setup of the bubble. */
    override fun setupBubble(action: FloatingBubble.Action): FloatingBubble.Builder {
        val bubbleIcon = if (!bubbleOptions.bubbleIcon.isNullOrBlank()) {
            Helpers.getDrawableId(
                this,
                bubbleOptions.bubbleIcon,
                getAppIconResId()
            )
        } else {
            getAppIconResId()
        }

        val closeIcon = Helpers.getDrawableId(
            this,
            bubbleOptions.closeIcon,
            android.R.drawable.ic_menu_close_clear_cancel
        )

        return FloatingBubble.Builder(this)
            .bubble(
                bubbleIcon,
                bubbleOptions.bubbleSize?.toInt() ?: 64,
                bubbleOptions.bubbleSize?.toInt() ?: 64
            )
            .bubbleStyle(null)
            .startLocation(
                bubbleOptions.startLocationX?.toInt() ?: 0,
                bubbleOptions.startLocationY?.toInt() ?: 0
            )
            .enableAnimateToEdge(bubbleOptions.enableAnimateToEdge ?: true)
            .closeBubble(
                closeIcon,
                bubbleOptions.bubbleSize?.toInt() ?: 64,
                bubbleOptions.bubbleSize?.toInt() ?: 64
            )
            .closeBubbleStyle(null)
            .enableCloseBubble(bubbleOptions.enableClose ?: true)
            .bottomBackground(bubbleOptions.enableBottomShadow ?: false)
            .opacity(bubbleOptions.opacity?.toFloat() ?: 1.0f)
            .behavior(
                when (bubbleOptions.closeBehavior) {
                    CLOSE_BEHAVIOR_FIXED -> BubbleBehavior.FIXED_CLOSE_BUBBLE
                    else -> BubbleBehavior.DYNAMIC_CLOSE_BUBBLE
                }
            )
            .distanceToClose(bubbleOptions.distanceToClose?.toInt() ?: 100)
            .addFloatingBubbleListener(BubbleCallbackListener(this, bubbleOptions.openAppOnTap ?: true))
    }

    /** This method defines the notification configuration and shows it. */
    private fun showNotification() {
        val notificationTitle =
            notificationOptions.title ?: Helpers.getApplicationName(this)

        val notificationIcon = if (!notificationOptions.icon.isNullOrBlank()) {
            Helpers.getDrawableId(
                this,
                notificationOptions.icon,
                getAppIconResId()
            )
        } else {
            getAppIconResId()
        }

        val notification = NotificationCompat.Builder(this, channelId())
            .setOngoing(true)
            .setContentTitle(notificationTitle)
            .setContentText(notificationOptions.body)
            .setSmallIcon(notificationIcon)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()

        notify(notification)
    }

    /** This method is called when the app is closed.
     * It stops the service if the keepAliveWhenAppExit option is false.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)

        if (::bubbleOptions.isInitialized && bubbleOptions.keepAliveWhenAppExit != true) {
            stopSelf()
        }
    }

    private fun getAppIconResId(): Int {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            appInfo.icon
        } catch (e: Exception) {
            android.R.drawable.ic_dialog_info
        }
    }
}