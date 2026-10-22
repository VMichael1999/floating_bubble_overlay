package com.example.floating_bubble_overlay

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

internal class FloatingBubbleOverlayPluginTest {
  @Test
  fun onMethodCall_beforeAttachedToEngine_returnsError() {
    val plugin = FloatingBubbleOverlayPlugin()
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

    plugin.onMethodCall(MethodCall("isRunning", null), mockResult)

    Mockito.verify(mockResult).error(
      Mockito.eq("FLOATING_BUBBLE_OVERLAY"),
      Mockito.anyString(),
      Mockito.isNull()
    )
  }
}
