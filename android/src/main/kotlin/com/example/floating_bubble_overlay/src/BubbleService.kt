package com.example.floating_bubble_overlay.src

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.torrydo.floatingbubbleview.BubbleBehavior
import com.torrydo.floatingbubbleview.FloatingBubble
import com.torrydo.floatingbubbleview.FloatingBubbleService
import com.torrydo.floatingbubbleview.Route

/** BubbleService is the service that will be started when the bubble is started. */
class BubbleService : FloatingBubbleService() {
    companion object {
        /** Mirrors the index of `CloseBehavior.fixed` on the Dart side. */
        private const val CLOSE_BEHAVIOR_FIXED = 1

        /** Intent action used by the notification "stop" button. */
        const val ACTION_STOP = "com.example.floating_bubble_overlay.action.STOP"

        /** The running service, if any. The plugin and the service share the same process. */
        @Volatile
        var instance: BubbleService? = null
            private set

        /** Set by [BubbleManager.stopBubble] so that [onDestroy] does not report an app-initiated stop as a user close. */
        @Volatile
        var stopRequestedByApp = false
    }

    private lateinit var bubbleOptions: BubbleOptions
    private lateinit var notificationOptions: NotificationOptions

    /** Whether the bubble is currently shown (it can be hidden with [hide] without stopping the service). */
    var isBubbleVisible = false
        private set

    override fun onCreate() {
        // FloatingBubbleService.onCreate throws if the overlay permission was revoked, which happens
        // when Android restarts the service after the permission has been removed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            stopSelf()
            return
        }
        super.onCreate()
        instance = this
        stopRequestedByApp = false
    }

    /** This method is called when the service is started
     * It initializes the bubble with the options passed to from the intent and starts the service.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (instance !== this) return START_NOT_STICKY

        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }

        val bubbleOpts = intent?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelableExtra(Constants.BUBBLE_OPTIONS_INTENT_EXTRA, BubbleOptions::class.java)
            } else {
                @Suppress("DEPRECATION")
                it.getParcelableExtra(Constants.BUBBLE_OPTIONS_INTENT_EXTRA)
            }
        }

        val notificationOpts = intent?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelableExtra(Constants.NOTIFICATION_OPTIONS_INTENT_EXTRA, NotificationOptions::class.java)
            } else {
                @Suppress("DEPRECATION")
                it.getParcelableExtra(Constants.NOTIFICATION_OPTIONS_INTENT_EXTRA)
            }
        }

        if (bubbleOpts == null || notificationOpts == null) {
            // Nothing to show (e.g. a restart without the original intent): do not linger as an empty service.
            if (!::bubbleOptions.isInitialized) stopSelf()
            return START_NOT_STICKY
        }

        if (!::bubbleOptions.isInitialized) {
            bubbleOptions = bubbleOpts
            notificationOptions = notificationOpts

            // The overlay must be visible before going foreground (Android 15+ background start rules).
            show()
            showNotification()
        }

        // If Android kills the process, restart the service with the same options so the bubble comes back.
        return START_REDELIVER_INTENT
    }

    override fun onDestroy() {
        if (instance === this) {
            instance = null
            isBubbleVisible = false
            if (!stopRequestedByApp) {
                LocalBroadcastManager.getInstance(this).sendBroadcast(Intent(Constants.ON_CLOSE))
            }
            stopRequestedByApp = false
            super.onDestroy()
        }
        // Otherwise onCreate bailed out before FloatingBubbleService was initialized: nothing to clean up.
    }

    /** Shows the bubble again after [hide]. */
    fun show() {
        showBubbles()
        isBubbleVisible = true
    }

    /** Hides the bubble while keeping the service (and its notification) alive. */
    fun hide() {
        removeBubbles()
        isBubbleVisible = false
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

    /** Creates a low importance channel so the persistent notification is silent. */
    override fun createNotificationChannel(channelId: String, channelName: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW).apply {
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    /** This method defines the main setup of the bubble. */
    override fun setupBubble(action: FloatingBubble.Action): FloatingBubble.Builder {
        val bubbleSize = bubbleOptions.bubbleSize?.toInt() ?: 64
        val closeSize = bubbleOptions.closeIconSize?.toInt() ?: bubbleSize

        val builder = FloatingBubble.Builder(this)

        val bubbleBitmap = Helpers.loadFlutterAsset(this, bubbleOptions.bubbleIconAsset)
        val bubbleIcon = Helpers.getDrawableId(this, bubbleOptions.bubbleIcon, getAppIconResId())
        val bubbleBackground = bubbleOptions.bubbleBackground
        val bubbleComposed = bubbleBackground?.let { background ->
            val px = Helpers.dpToPx(bubbleSize)
            (bubbleBitmap ?: IconComposer.drawableToBitmap(this, bubbleIcon, px))
                ?.let { IconComposer.compose(this, it, px, background) }
        }
        when {
            bubbleComposed != null -> builder.bubble(bubbleComposed, bubbleSize, bubbleSize)
            bubbleBitmap != null -> builder.bubble(bubbleBitmap, bubbleSize, bubbleSize)
            else -> builder.bubble(bubbleIcon, bubbleSize, bubbleSize)
        }

        val closeBitmap = Helpers.loadFlutterAsset(this, bubbleOptions.closeIconAsset)
        val closeIcon = Helpers.getDrawableId(
            this,
            bubbleOptions.closeIcon,
            android.R.drawable.ic_menu_close_clear_cancel
        )
        val closePx = Helpers.dpToPx(closeSize)
        val closeBackground = bubbleOptions.closeIconBackground
        val closeComposed = closeBackground?.let { background ->
            (closeBitmap ?: IconComposer.drawableToBitmap(this, closeIcon, closePx))
                ?.let { IconComposer.compose(this, it, closePx, background) }
        }
        when {
            closeComposed != null -> builder.closeBubble(closeComposed)
            closeBitmap != null -> builder.closeBubble(Bitmap.createScaledBitmap(closeBitmap, closePx, closePx, true))
            else -> builder.closeBubble(closeIcon, closeSize, closeSize)
        }

        return builder
            .bubbleStyle(null)
            .startLocation(
                bubbleOptions.startLocationX?.toInt() ?: 0,
                bubbleOptions.startLocationY?.toInt() ?: 0
            )
            .enableAnimateToEdge(bubbleOptions.enableAnimateToEdge ?: true)
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

        val notificationIcon = Helpers.getDrawableId(this, notificationOptions.icon, getAppIconResId())

        val builder = NotificationCompat.Builder(this, channelId())
            .setOngoing(true)
            .setContentTitle(notificationTitle)
            .setContentText(notificationOptions.body)
            .setSmallIcon(notificationIcon)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(Notification.CATEGORY_SERVICE)

        // Tapping the notification brings the app to the foreground.
        packageManager.getLaunchIntentForPackage(packageName)?.let { launchIntent ->
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            builder.setContentIntent(
                PendingIntent.getActivity(this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE)
            )
        }

        if (notificationOptions.showStopAction == true) {
            val stopIntent = Intent(this, BubbleService::class.java).setAction(ACTION_STOP)
            builder.addAction(
                0,
                notificationOptions.stopActionLabel ?: "Stop",
                PendingIntent.getService(this, 1, stopIntent, PendingIntent.FLAG_IMMUTABLE)
            )
        }

        notify(builder.build())
    }

    /** This method is called when the app is closed.
     * It stops the service if the keepAliveWhenAppExit option is false.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)

        if (::bubbleOptions.isInitialized && bubbleOptions.keepAliveWhenAppExit != true) {
            stopRequestedByApp = true
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
