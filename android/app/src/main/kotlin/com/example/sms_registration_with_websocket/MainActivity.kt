package com.example.sms_registration_with_websocket

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "SignInHelperService"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "startSignInHelperService" -> {
                    startService(Intent(this, SignInHelperService::class.java))
                    result.success("Started!")
                }
                "stopSignInHelperService" -> {
                    stopService(Intent(this, SignInHelperService::class.java))
                    result.success("Stopped!")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
