package com.example.astraea

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val PRIVACY_CHANNEL = "com.example.astraea/privacy"
        private const val KAIROS_CHANNEL = "com.example.astraea/kairos"
        // Keep these values identical to Kairos' explicit app-to-app intent.
        private const val KAIROS_ACTION = "dev.echoes.astraea.action.LOCAL_SYNC"
        private const val KAIROS_PAYLOAD_EXTRA = "dev.echoes.astraea.extra.PAYLOAD"
        // Accepted for one transition cycle so an older Kairos build can still
        // deliver a task after Astraea is upgraded first.
        private const val LEGACY_KAIROS_ACTION =
            "com.example.astraea.action.IMPORT_KAIROS_TASK"
        private const val LEGACY_KAIROS_PAYLOAD_EXTRA =
            "com.example.astraea.extra.KAIROS_TASK"
        private const val MAX_KAIROS_PAYLOAD_BYTES = 64 * 1024
        private const val SENSITIVE_CLIPBOARD_FLAG = "android.content.extra.IS_SENSITIVE"
    }

    private var kairosChannel: MethodChannel? = null
    private var kairosDartReady = false
    private var pendingKairosTask: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRIVACY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        val secure = call.arguments as? Boolean ?: false
                        if (secure) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    "copySensitive" -> {
                        val value = call.arguments as? String
                        if (value == null) {
                            result.error("invalid_argument", "Expected text to copy", null)
                        } else {
                            copySensitive(value)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        kairosChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, KAIROS_CHANNEL)
        kairosChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "ready" -> {
                    kairosDartReady = true
                    deliverPendingKairosTask()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        queueKairosIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        queueKairosIntent(intent)
    }

    private fun queueKairosIntent(intent: Intent?) {
        val action = intent?.action ?: return
        val extra = when (action) {
            KAIROS_ACTION -> KAIROS_PAYLOAD_EXTRA
            LEGACY_KAIROS_ACTION -> LEGACY_KAIROS_PAYLOAD_EXTRA
            else -> return
        }
        val payload = intent.getStringExtra(extra) ?: return
        if (payload.toByteArray(Charsets.UTF_8).size > MAX_KAIROS_PAYLOAD_BYTES) return
        pendingKairosTask = payload
        deliverPendingKairosTask()
    }

    private fun deliverPendingKairosTask() {
        val payload = pendingKairosTask ?: return
        if (!kairosDartReady) return
        pendingKairosTask = null
        kairosChannel?.invokeMethod("kairosTask", payload)
    }

    private fun copySensitive(value: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Astraea private key", value)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            clip.description.extras = PersistableBundle().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    putBoolean(android.content.ClipDescription.EXTRA_IS_SENSITIVE, true)
                } else {
                    putBoolean(SENSITIVE_CLIPBOARD_FLAG, true)
                }
            }
        }
        clipboard.setPrimaryClip(clip)

        // Limit how long a private key remains available to other foreground
        // apps on Android versions that don't clear sensitive clips quickly.
        Handler(Looper.getMainLooper()).postDelayed({
            val current = clipboard.primaryClip?.getItemAt(0)?.coerceToText(this)?.toString()
            if (current == value) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) clipboard.clearPrimaryClip()
                else clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
            }
        }, 60_000L)
    }
}
