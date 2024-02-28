package com.example.flutter_application_gif

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "combine_images"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "combineImages") {
                val gifData1 = call.argument<ByteArray>("gifData1")
                val gifData2 = call.argument<ByteArray>("gifData2")
                val text1 = call.argument<String>("text1") ?: ""
                val text2 = call.argument<String>("text2") ?: ""
                val combinedImage = combineImages(gifData1, gifData2, text1, text2)
                if (combinedImage != null) {
                    result.success(combinedImage)
                } else {
                    result.error("COMBINE_IMAGES_ERROR", "Failed to combine images", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun combineImages(gifData1: ByteArray?, gifData2: ByteArray?, text1: String, text2: String): ByteArray? {
        if (gifData1 == null || gifData2 == null) {
            return null
        }

        val bitmap1 = BitmapFactory.decodeByteArray(gifData1, 0, gifData1.size)
        val bitmap2 = BitmapFactory.decodeByteArray(gifData2, 0, gifData2.size)

        val maxWidth = Math.max(bitmap1.width, bitmap2.width)
        val totalHeight = bitmap1.height + bitmap2.height

        val combinedBitmap = Bitmap.createBitmap(maxWidth, totalHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(combinedBitmap)

        canvas.drawBitmap(bitmap1, null, Rect(0, 0, maxWidth, bitmap1.height), null)
        canvas.drawBitmap(bitmap2, null, Rect(0, bitmap1.height, maxWidth, totalHeight), null)

        val paint = Paint()
        paint.textSize = 50f

        canvas.drawText(text1, 10f, (bitmap1.height + 50).toFloat(), paint)
        canvas.drawText(text2, 10f, (bitmap1.height + bitmap2.height + 50).toFloat(), paint)

        val stream = ByteArrayOutputStream()
        combinedBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }
}
