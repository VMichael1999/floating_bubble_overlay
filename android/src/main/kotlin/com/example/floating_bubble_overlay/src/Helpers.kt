package com.example.floating_bubble_overlay.src

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.content.res.Resources
import android.util.Log

/** Helpers is the class that contains the helper methods for the plugin */
class Helpers {

    companion object {
        /**
         * Get the application name from the context.
         * @param context The context of the application.
         * @return The application name.
         */
        fun getApplicationName(context: Context): String {
            val appInfo = context.applicationInfo
            return context.packageManager.getApplicationLabel(appInfo).toString()
        }

        /**
         * Get the drawable id from the name of the drawable.
         * @param context The context of the application.
         * @param name The name of the drawable.
         * @param default The default drawable id to return if the drawable is not found.
         * @return The drawable id.
         */
        fun getDrawableId(context: Context, name: String?, default: Int): Int {
            if (name.isNullOrBlank()) return default

            val identifier = context.resources.getIdentifier(name, "drawable", context.packageName)

            return if (identifier == 0) {
                Log.w(Constants.ERROR_TAG, "Could not find resource with name $name")
                default
            } else {
                identifier
            }
        }

        /**
         * Decode a Flutter asset bundled in the APK.
         * @param context The context of the application.
         * @param assetPath The asset path inside the APK (already resolved with FlutterAssets).
         * @return The decoded bitmap, or null if [assetPath] is null or cannot be decoded.
         */
        fun loadFlutterAsset(context: Context, assetPath: String?): Bitmap? {
            if (assetPath.isNullOrBlank()) return null

            val bitmap = try {
                context.assets.open(assetPath).use { BitmapFactory.decodeStream(it) }
            } catch (e: Exception) {
                null
            }
            if (bitmap == null) Log.w(Constants.ERROR_TAG, "Could not load Flutter asset $assetPath")
            return bitmap
        }

        /** Convert density-independent pixels (dp) to pixels (px). */
        fun dpToPx(dp: Int): Int {
            return (dp * Resources.getSystem().displayMetrics.density).toInt()
        }

        /** Convert pixels (px) to density-independent pixels (dp).
         * @param px The pixel value to convert.
         * @return The converted dp value.
         */
        fun pxToDp(px: Double): Double {
            return px / Resources.getSystem().displayMetrics.density
        }
    }
}