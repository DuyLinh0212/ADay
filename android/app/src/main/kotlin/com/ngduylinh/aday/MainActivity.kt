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
                    val edit = prefs.edit()
                        .putString("themeId", call.argument<String>("themeId") ?: "default")
                        .putInt("taskCount", call.argument<Int>("taskCount") ?: 0)
                        .putInt("completedCount", call.argument<Int>("completedCount") ?: 0)
                        .putInt("percent", call.argument<Int>("percent") ?: 0)
                        .putString("dateLabel", call.argument<String>("dateLabel") ?: "Hôm nay")

                    listOf(1, 2, 3).forEach { i ->
                        call.argument<String>("task${i}Title")?.let { edit.putString("task${i}Title", it) }
                            ?: edit.remove("task${i}Title")
                        call.argument<Boolean>("task${i}Done")?.let { edit.putBoolean("task${i}Done", it) }
                            ?: edit.remove("task${i}Done")
                        call.argument<String>("task${i}Time")?.let { edit.putString("task${i}Time", it) }
                            ?: edit.remove("task${i}Time")
                    }
                    edit.apply()
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
            "theme_3" -> "LauncherNight"
            "theme_4" -> "LauncherPink"
            "theme_5" -> "LauncherGreen"
            else -> "LauncherDefault"
        }
        // Enable the selected alias first so launchers never observe a moment
        // where the application has no launcher component.
        packageManager.setComponentEnabledSetting(
            ComponentName(this, "$packageName.$selected"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        aliases.filterNot { it == selected }.forEach { alias ->
            packageManager.setComponentEnabledSetting(
                ComponentName(this, "$packageName.$alias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
