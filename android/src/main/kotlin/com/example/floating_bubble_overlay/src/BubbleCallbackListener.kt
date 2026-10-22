package com.example.floating_bubble_overlay.src

import android.content.Intent
import android.content.pm.PackageManager
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.torrydo.floatingbubbleview.FloatingBubble

class BubbleCallbackListener(
    private val bubbleService: BubbleService,
    private val openAppOnTap: Boolean = true,
) : FloatingBubble.Listener {

    /** This method is called when the bubble is tapped.
     * It brings the host app to foreground (when enabled) and sends a broadcast to the app to handle the tap.
     */
    override fun onClick() {
        // 1) Bring the host app to foreground ONLY on click
        if (openAppOnTap) try {
            val pm: PackageManager = bubbleService.packageManager
            val launchIntent = pm.getLaunchIntentForPackage(bubbleService.packageName)
            launchIntent?.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
            if (launchIntent != null) {
                bubbleService.startActivity(launchIntent)
            }
        } catch (_: Exception) {
            // ignore; still notify Flutter side
        }

        // 2) Notify Flutter side that bubble was tapped (existing behavior)
        val intent = Intent(Constants.ON_TAP)
        LocalBroadcastManager.getInstance(bubbleService).sendBroadcast(intent)
    }

    /** This method is called when the bubble is tapped down (pressed).
     * It sends a broadcast to the app to handle the move down.
     */
    override fun onDown(x: Float, y: Float) {
        val intent = Intent(Constants.ON_TAP_DOWN)
        putCoordinatesInIntent(intent, x, y)
        LocalBroadcastManager.getInstance(bubbleService).sendBroadcast(intent)
    }

    /** This method is called when the bubble is tapped up (released).
     * It sends a broadcast to the app to handle the move up.
     */
    override fun onUp(x: Float, y: Float) {
        val intent = Intent(Constants.ON_TAP_UP)
        putCoordinatesInIntent(intent, x, y)
        LocalBroadcastManager.getInstance(bubbleService).sendBroadcast(intent)
    }

    /** This method is called when the bubble is moved.
     * It sends a broadcast to the app to handle the move.
     */
    override fun onMove(x: Float, y: Float) {
        val intent = Intent(Constants.ON_MOVE)
        putCoordinatesInIntent(intent, x, y)
        LocalBroadcastManager.getInstance(bubbleService).sendBroadcast(intent)
    }

    /** This method is used to put the coordinates in the intent as extras. */
    private fun putCoordinatesInIntent(intent: Intent, x: Float, y: Float) {
        intent.putExtra(Constants.X_AXIS_VALUE, Helpers.pxToDp(x.toDouble()))
        intent.putExtra(Constants.Y_AXIS_VALUE, Helpers.pxToDp(y.toDouble()))
    }
}