package com.ngduylinh.aday

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
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
            val themeId = prefs.getString("themeId", "default") ?: "default"
            val remaining = prefs.getInt("taskCount", 0)
            val completed = prefs.getInt("completedCount", 0)
            val total = remaining + completed
            val percent = if (total > 0) (completed * 100) / total else prefs.getInt("percent", 0)
            val dateLabel = prefs.getString("dateLabel", "Hôm nay") ?: "Hôm nay"

            val isDark = themeId == "theme_3"
            val bgRes = when (themeId) {
                "theme_1" -> R.drawable.aday_widget_bg_theme_1
                "theme_2" -> R.drawable.aday_widget_bg_theme_2
                "theme_3" -> R.drawable.aday_widget_bg_theme_3
                "theme_4" -> R.drawable.aday_widget_bg_theme_4
                "theme_5" -> R.drawable.aday_widget_bg_theme_5
                else -> R.drawable.aday_widget_bg_default
            }
            val cardBg = if (isDark) R.drawable.aday_widget_card_dark else R.drawable.aday_widget_card_light
            val titleColor = if (isDark) 0xFFFFFFFF.toInt() else 0xFF0A3768.toInt()
            val subColor = if (isDark) 0xFF94A3B8.toInt() else 0xFF6683A5.toInt()
            val accentColor = when (themeId) {
                "theme_1" -> 0xFF7D6CE0.toInt()
                "theme_2" -> 0xFFE58A23.toInt()
                "theme_3" -> 0xFF22D3EE.toInt()
                "theme_4" -> 0xFFE06C61.toInt()
                "theme_5" -> 0xFF1E7F55.toInt()
                else -> 0xFF168AF2.toInt()
            }

            return RemoteViews(context.packageName, R.layout.aday_home_widget).apply {
                setInt(R.id.widget_root, "setBackgroundResource", bgRes)
                setInt(R.id.widget_left_card, "setBackgroundResource", cardBg)
                setInt(R.id.widget_right_card, "setBackgroundResource", cardBg)

                setTextColor(R.id.widget_title, titleColor)
                setTextColor(R.id.widget_subtitle, subColor)
                setTextColor(R.id.widget_quote, titleColor)
                setTextColor(R.id.widget_progress_label, subColor)
                setTextColor(R.id.widget_percent, titleColor)
                setTextColor(R.id.widget_completed, accentColor)
                setTextColor(R.id.widget_remaining, subColor)
                setTextColor(R.id.widget_date, titleColor)
                setTextColor(R.id.widget_tasks_header, titleColor)
                setTextColor(R.id.widget_footer, subColor)

                setTextViewText(R.id.widget_percent, "$percent%")
                setTextViewText(R.id.widget_completed, "$completed / $total nhiệm vụ")
                setTextViewText(R.id.widget_remaining, "$remaining việc còn lại")
                setTextViewText(R.id.widget_date, dateLabel)
                setProgressBar(R.id.widget_progress_bar, 100, percent, false)

                // Task 1
                val t1Title = prefs.getString("task1Title", null)
                if (!t1Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_task1_container, View.VISIBLE)
                    setTextViewText(R.id.widget_task1_title, t1Title)
                    setTextColor(R.id.widget_task1_title, titleColor)
                    setTextViewText(R.id.widget_task1_time, prefs.getString("task1Time", "Cả ngày"))
                    setTextColor(R.id.widget_task1_time, subColor)
                    val t1Done = prefs.getBoolean("task1Done", false)
                    setInt(R.id.widget_task1_check, "setBackgroundResource",
                        if (t1Done) R.drawable.aday_widget_check_done else R.drawable.aday_widget_check_todo)
                }

                // Task 2
                val t2Title = prefs.getString("task2Title", null)
                if (!t2Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_task2_container, View.VISIBLE)
                    setTextViewText(R.id.widget_task2_title, t2Title)
                    setTextColor(R.id.widget_task2_title, titleColor)
                    setTextViewText(R.id.widget_task2_time, prefs.getString("task2Time", "Cả ngày"))
                    setTextColor(R.id.widget_task2_time, subColor)
                    val t2Done = prefs.getBoolean("task2Done", false)
                    setInt(R.id.widget_task2_check, "setBackgroundResource",
                        if (t2Done) R.drawable.aday_widget_check_done else R.drawable.aday_widget_check_todo)
                }

                // Task 3
                val t3Title = prefs.getString("task3Title", null)
                if (!t3Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_task3_container, View.VISIBLE)
                    setTextViewText(R.id.widget_task3_title, t3Title)
                    setTextColor(R.id.widget_task3_title, titleColor)
                    setTextViewText(R.id.widget_task3_time, prefs.getString("task3Time", "Cả ngày"))
                    setTextColor(R.id.widget_task3_time, subColor)
                    val t3Done = prefs.getBoolean("task3Done", false)
                    setInt(R.id.widget_task3_check, "setBackgroundResource",
                        if (t3Done) R.drawable.aday_widget_check_done else R.drawable.aday_widget_check_todo)
                }

                setOnClickPendingIntent(
                    R.id.widget_root,
                    android.app.PendingIntent.getActivity(
                        context,
                        0,
                        Intent(context, MainActivity::class.java),
                        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }
        }
    }
}

