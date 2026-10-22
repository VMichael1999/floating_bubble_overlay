package com.example.floating_bubble_overlay

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.localbroadcastmanager.content.LocalBroadcastManager

import com.example.floating_bubble_overlay.src.BroadcastListener
import com.example.floating_bubble_overlay.src.BubbleManager
import com.example.floating_bubble_overlay.src.BubbleOptions
import com.example.floating_bubble_overlay.src.Constants
import com.example.floating_bubble_overlay.src.NotificationOptions

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class FloatingBubbleOverlayPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private var activityBinding: ActivityPluginBinding? = null
    private var appContext: Context? = null
    private var channel: MethodChannel? = null
    private var broadcastListener: BroadcastListener? = null
    private var bubbleManager: BubbleManager? = null
    private var flutterAssets: FlutterPlugin.FlutterAssets? = null

    /** Result of the permission request that is currently waiting for the user's answer. */
    private var pendingResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        appContext = context
        flutterAssets = binding.flutterAssets

        val methodChannel = MethodChannel(binding.binaryMessenger, Constants.METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        channel = methodChannel

        bubbleManager = BubbleManager(context)

        val listener = BroadcastListener(methodChannel)
        broadcastListener = listener
        val intentFilter = IntentFilter().apply {
            addAction(Constants.ON_TAP)
            addAction(Constants.ON_TAP_DOWN)
            addAction(Constants.ON_TAP_UP)
            addAction(Constants.ON_MOVE)
            addAction(Constants.ON_CLOSE)
        }
        LocalBroadcastManager.getInstance(context).registerReceiver(listener, intentFilter)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val manager = bubbleManager
            if (manager == null) {
                result.error(Constants.ERROR_TAG, "The plugin is not attached to a Flutter engine.", null)
                return
            }

            when (call.method) {

                Constants.REQUEST_OVERLAY_PERMISSION -> {
                    if (!reservePendingResult(result)) return
                    if (manager.requestOverlayPermission() == true) releasePendingResult()?.success(true)
                }

                Constants.HAS_OVERLAY_PERMISSION ->
                    result.success(manager.hasOverlayPermission())

                Constants.REQUEST_POST_NOTIFICATIONS_PERMISSION -> {
                    if (!reservePendingResult(result)) return
                    if (manager.requestPostNotificationsPermission() == true) releasePendingResult()?.success(true)
                }

                Constants.HAS_POST_NOTIFICATIONS_PERMISSION ->
                    result.success(manager.hasPostNotificationsPermission())

                Constants.IS_RUNNING ->
                    result.success(manager.isRunning())

                Constants.START_BUBBLE -> result.success(
                    manager.startBubble(
                        BubbleOptions.fromMethodCall(call) { asset ->
                            flutterAssets?.getAssetFilePathByName(asset) ?: asset
                        },
                        NotificationOptions.fromMethodCall(call)
                    )
                )

                Constants.STOP_BUBBLE ->
                    result.success(manager.stopBubble())

                Constants.HIDE_BUBBLE ->
                    result.success(manager.hideBubble())

                Constants.SHOW_BUBBLE ->
                    result.success(manager.showBubble())

                Constants.IS_BUBBLE_VISIBLE ->
                    result.success(manager.isBubbleVisible())

                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            // A failed permission request must not leave a dangling pending result.
            if (pendingResult === result) pendingResult = null
            result.error(Constants.ERROR_TAG, e.message, null)
        }
    }

    /** Stores [result] until the permission dialog/screen answers. Fails fast if another request is pending. */
    private fun reservePendingResult(result: MethodChannel.Result): Boolean {
        if (pendingResult != null) {
            result.error(
                Constants.ERROR_TAG,
                "Another permission request is already in progress.",
                null
            )
            return false
        }
        pendingResult = result
        return true
    }

    private fun releasePendingResult(): MethodChannel.Result? {
        val result = pendingResult
        pendingResult = null
        return result
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null

        val context = appContext
        val listener = broadcastListener
        if (context != null && listener != null) {
            LocalBroadcastManager.getInstance(context).unregisterReceiver(listener)
        }
        broadcastListener = null
        bubbleManager = null
        appContext = null
        flutterAssets = null
        pendingResult = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun attachActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
        bubbleManager?.activity = binding.activity
    }

    private fun detachActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        bubbleManager?.activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != Constants.OVERLAY_PERMISSION_REQUEST_CODE) return false

        releasePendingResult()?.success(bubbleManager?.hasOverlayPermission() ?: false)
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != Constants.POST_NOTIFICATIONS_PERMISSION_REQUEST_CODE) return false

        releasePendingResult()?.success(bubbleManager?.hasPostNotificationsPermission() ?: false)
        return true
    }
}
