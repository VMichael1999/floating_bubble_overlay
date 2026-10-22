package com.example.floating_bubble_overlay.src

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

/** BubbleBackground is an optional background drawn behind the bubble or close icon.
 * @param shape The shape index, mirrors `BubbleShape` on the Dart side.
 * @param color The ARGB fill color.
 * @param imageAsset The APK path of a Flutter asset drawn as the background.
 * @param padding The space between the edge of the background and the icon (dp).
 * @param cornerRadius The corner radius for rounded squares (dp).
 * @param borderColor The ARGB border color.
 * @param borderWidth The border width (dp).
 */
@Parcelize
data class BubbleBackground(
    val shape: Int,
    val color: Int?,
    val imageAsset: String?,
    val padding: Double,
    val cornerRadius: Double,
    val borderColor: Int?,
    val borderWidth: Double,
) : Parcelable {
    companion object {
        const val SHAPE_CIRCLE = 0
        const val SHAPE_SQUARE = 1
        const val SHAPE_ROUNDED_SQUARE = 2

        /**
         * Get the background from the map sent by the method channel.
         * @param map The serialized background, or null.
         * @param resolveAsset Maps a Flutter asset name to its path inside the APK.
         * @return The background, or null if [map] is null.
         */
        fun fromMap(map: Map<*, *>?, resolveAsset: (String) -> String): BubbleBackground? {
            if (map == null) return null

            // ARGB colors above 0x7FFFFFFF arrive as Long.
            fun color(key: String) = (map[key] as? Number)?.toLong()?.toInt()
            fun number(key: String, default: Double) = (map[key] as? Number)?.toDouble() ?: default

            return BubbleBackground(
                shape = (map["shape"] as? Number)?.toInt() ?: SHAPE_CIRCLE,
                color = color("color"),
                imageAsset = (map["imageAsset"] as? String)?.let(resolveAsset),
                padding = number("padding", 6.0),
                cornerRadius = number("cornerRadius", 12.0),
                borderColor = color("borderColor"),
                borderWidth = number("borderWidth", 0.0),
            )
        }
    }
}
