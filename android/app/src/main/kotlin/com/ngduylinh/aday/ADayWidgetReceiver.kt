package com.ngduylinh.aday

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class ADayWidgetReceiver : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views(context)) }
    }

    companion object {
        const val preferencesName = "aday_home_widget"
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ADayWidgetReceiver::class.java))
            ids.forEach { manager.updateAppWidget(it, views(context)) }
        }
        private fun views(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            val remaining = prefs.getInt("taskCount", 0)
            val completed = prefs.getInt("completedCount", 0)
            val colors = mapOf("theme_1" to 0xFF7D6CE0.toInt(), "theme_2" to 0xFFE58A23.toInt(), "theme_3" to 0xFF25866E.toInt(), "theme_4" to 0xFFE06C61.toInt(), "theme_5" to 0xFF4669AA.toInt())
            val color = colors[prefs.getString("themeId", "default")] ?: 0xFF168AF2.toInt()
            return RemoteViews(context.packageName, R.layout.aday_home_widget).apply {
                setTextViewText(R.id.widget_remaining, "$remaining việc còn lại")
                setTextViewText(R.id.widget_completed, "$completed việc đã xong")
                setInt(R.id.widget_root, "setBackgroundColor", color)
                setOnClickPendingIntent(R.id.widget_root, android.app.PendingIntent.getActivity(context, 0, Intent(context, MainActivity::class.java), android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE))
            }
        }
    }
}
