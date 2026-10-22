package com.example.floating_bubble_overlay.src

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Shader
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.toBitmap
import kotlin.math.max
import kotlin.math.min

/** IconComposer draws an icon on top of an optional [BubbleBackground] into a single bitmap. */
object IconComposer {

    /**
     * Compose [icon] centered over [background].
     * @param context The context, used to load the background image asset.
     * @param icon The icon to draw (kept with its aspect ratio).
     * @param sizePx The width and height of the result in pixels.
     * @param background The background to draw behind the icon.
     * @return A new [sizePx] x [sizePx] bitmap.
     */
    fun compose(context: Context, icon: Bitmap, sizePx: Int, background: BubbleBackground): Bitmap {
        val size = sizePx.toFloat()
        val border = dp(background.borderWidth)
        val half = border / 2f
        val path = shapePath(background, RectF(half, half, size - half, size - half))

        val out = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)

        background.color?.let {
            paint.color = it
            canvas.drawPath(path, paint)
        }

        Helpers.loadFlutterAsset(context, background.imageAsset)?.let { image ->
            canvas.drawPath(path, Paint(paint).apply {
                color = 0xFFFFFFFF.toInt()
                shader = BitmapShader(image, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP).apply {
                    setLocalMatrix(centerCrop(image, size))
                }
            })
        }

        val inset = dp(background.padding) + border
        val available = size - 2 * inset
        if (available > 0) {
            val scale = min(available / icon.width, available / icon.height)
            val width = icon.width * scale
            val height = icon.height * scale
            val left = (size - width) / 2f
            val top = (size - height) / 2f
            canvas.drawBitmap(icon, null, RectF(left, top, left + width, top + height), paint)
        }

        val borderColor = background.borderColor
        if (borderColor != null && border > 0f) {
            canvas.drawPath(path, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeWidth = border
                color = borderColor
            })
        }

        return out
    }

    /** Render a drawable resource (e.g. the app icon) into a [sizePx] x [sizePx] bitmap. */
    fun drawableToBitmap(context: Context, drawableId: Int, sizePx: Int): Bitmap? {
        return try {
            ContextCompat.getDrawable(context, drawableId)?.toBitmap(sizePx, sizePx)
        } catch (e: Exception) {
            null
        }
    }

    private fun shapePath(background: BubbleBackground, rect: RectF): Path = Path().apply {
        when (background.shape) {
            BubbleBackground.SHAPE_SQUARE -> addRect(rect, Path.Direction.CW)
            BubbleBackground.SHAPE_ROUNDED_SQUARE -> {
                val radius = dp(background.cornerRadius)
                addRoundRect(rect, radius, radius, Path.Direction.CW)
            }
            else -> addOval(rect, Path.Direction.CW)
        }
    }

    /** Matrix that scales [image] to cover a [size] x [size] square, centered. */
    private fun centerCrop(image: Bitmap, size: Float): Matrix {
        val scale = max(size / image.width, size / image.height)
        return Matrix().apply {
            setScale(scale, scale)
            postTranslate((size - image.width * scale) / 2f, (size - image.height * scale) / 2f)
        }
    }

    private fun dp(value: Double): Float = (value * Resources.getSystem().displayMetrics.density).toFloat()
}
