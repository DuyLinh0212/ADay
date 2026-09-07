package com.ngduylinh.aday

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.ngduylinh.aday/home_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val prefs = getSharedPreferences(ADayWidgetReceiver.preferencesName, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putString("themeId", call.argument<String>("themeId") ?: "default")
                        .putInt("taskCount", call.argument<Int>("taskCount") ?: 0)
                        .putInt("completedCount", call.argument<Int>("completedCount") ?: 0)
                        .apply()
                    ADayWidgetReceiver.updateAll(this)
                    result.success(null)
                }
                "requestPin" -> {
                    val manager = getSystemService(AppWidgetManager::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager.isRequestPinAppWidgetSupported) {
                        manager.requestPinAppWidget(ComponentName(this, ADayWidgetReceiver::class.java), null, null)
                        result.success(true)
                    } else result.success(false)
                }
                "setLauncherIcon" -> {
                    setLauncherIcon(call.argument<String>("themeId") ?: "default")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setLauncherIcon(themeId: String) {
        val aliases = listOf(
            "LauncherDefault", "LauncherPurple", "LauncherSunrise",
            "LauncherGreen", "LauncherPink", "LauncherNight"
        )
        val selected = when (themeId) {
            "theme_1" -> "LauncherPurple"
            "theme_2" -> "LauncherSunrise"
            "theme_3" -> "LauncherGreen"
            "theme_4" -> "LauncherPink"
            "theme_5" -> "LauncherNight"
            else -> "LauncherDefault"
        }
        aliases.forEach { alias ->
            packageManager.setComponentEnabledSetting(
                ComponentName(this, "$packageName.$alias"),
                if (alias == selected) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
