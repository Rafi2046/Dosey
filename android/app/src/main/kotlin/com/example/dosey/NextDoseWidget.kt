package com.example.dosey

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.util.Calendar

/**
 * "Next medicine" home screen widget. The app writes the upcoming doses
 * (already worded, in the app language) as JSON — see HomeWidgetSync.dart —
 * and asks for a redraw whenever the schedule or a dose changes. Here we
 * show the first dose that's still due, and arrange a redraw for when that
 * changes on its own (the dose's time passes).
 */
class NextDoseWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val data = widgetData.getString(DATA_KEY, null)?.let {
            try { JSONObject(it) } catch (e: Exception) { null }
        }
        val now = System.currentTimeMillis()
        val slot = data?.optJSONArray("slots")?.let { slots ->
            (0 until slots.length())
                .map { slots.getJSONObject(it) }
                .firstOrNull { it.getLong("at") + DUE_WINDOW_MS > now }
        }
        val labels = data?.optJSONObject("labels")

        for (id in appWidgetIds) {
            fun build(layout: Int) = RemoteViews(context.packageName, layout).also {
                fill(context, it, slot, labels, now)
            }
            val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+: the launcher picks the layout for the size.
                RemoteViews(
                    mapOf(
                        // Short: one row. Short and wide: the bar with
                        // the dose. Tall enough (~2 rows): the card.
                        SizeF(100f, 40f) to build(R.layout.next_dose_widget_mini),
                        SizeF(220f, 40f) to build(R.layout.next_dose_widget_wide),
                        SizeF(100f, CARD_MIN_HEIGHT) to build(R.layout.next_dose_widget_small),
                        SizeF(220f, CARD_MIN_HEIGHT) to build(R.layout.next_dose_widget_small),
                    ),
                )
            } else {
                val options = appWidgetManager.getAppWidgetOptions(id)
                val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
                val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
                build(
                    when {
                        height >= CARD_MIN_HEIGHT.toInt() -> R.layout.next_dose_widget_small
                        width >= 220 -> R.layout.next_dose_widget_wide
                        else -> R.layout.next_dose_widget_mini
                    },
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
        scheduleNextRedraw(context, slot, now)
    }

    /** Before Android 12: redraw with the right layout after a resize. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    /** Both layouts share view ids, so one filler serves them. */
    private fun fill(
        context: Context,
        views: RemoteViews,
        slot: JSONObject?,
        labels: JSONObject?,
        now: Long,
    ) {
        views.setOnClickPendingIntent(
            R.id.widget_root,
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
        )
        if (slot == null) {
            views.setTextViewText(
                R.id.widget_header,
                labels?.optString("next") ?: context.getString(R.string.widget_name),
            )
            views.setViewVisibility(R.id.widget_time, View.GONE)
            views.setTextViewText(
                R.id.widget_title,
                labels?.optString("empty") ?: context.getString(R.string.widget_open_app),
            )
            views.setTextViewText(R.id.widget_lines, "")
            views.setTextViewText(R.id.widget_summary, "")
            views.setTextViewText(R.id.widget_day, "")
            return
        }
        val at = slot.getLong("at")
        val due = at <= now
        views.setTextViewText(
            R.id.widget_header,
            labels?.optString(if (due) "due" else "next") ?: "",
        )
        // "Due now" in Dosey orange so it stands out.
        views.setTextColor(R.id.widget_header, if (due) ACCENT else MUTED)
        // One line for compact layouts (names when several are due).
        views.setTextViewText(R.id.widget_summary, slot.optString("summary"))
        views.setViewVisibility(R.id.widget_time, View.VISIBLE)
        views.setTextViewText(R.id.widget_time, slot.optString("time"))
        views.setTextViewText(R.id.widget_title, slot.optString("title"))
        val lines = slot.optJSONArray("lines")
        views.setTextViewText(
            R.id.widget_lines,
            (0 until (lines?.length() ?: 0)).joinToString("\n") { lines!!.getString(it) },
        )
        views.setTextViewText(R.id.widget_day, dayLabel(at, slot, labels))
    }

    /** "Today", "Tomorrow", or the date the app wrote. */
    private fun dayLabel(at: Long, slot: JSONObject, labels: JSONObject?): String {
        val day = Calendar.getInstance().apply { timeInMillis = at }
        val today = Calendar.getInstance()
        fun same(a: Calendar, b: Calendar) =
            a.get(Calendar.YEAR) == b.get(Calendar.YEAR) &&
                a.get(Calendar.DAY_OF_YEAR) == b.get(Calendar.DAY_OF_YEAR)
        val tomorrow = (today.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, 1) }
        return when {
            same(day, today) -> labels?.optString("today") ?: ""
            same(day, tomorrow) -> labels?.optString("tomorrow") ?: ""
            else -> slot.optString("date")
        }
    }

    /**
     * Redraw by itself when what's shown changes without the app running:
     * when the shown dose becomes due, or when it stops being due (and the
     * next one takes its place). Inexact is fine for a widget.
     */
    private fun scheduleNextRedraw(context: Context, slot: JSONObject?, now: Long) {
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NextDoseWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(
                AppWidgetManager.EXTRA_APPWIDGET_IDS,
                AppWidgetManager.getInstance(context)
                    .getAppWidgetIds(ComponentName(context, NextDoseWidget::class.java)),
            )
        }
        val pending = PendingIntent.getBroadcast(
            context, REDRAW_REQUEST, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        manager.cancel(pending)
        if (slot == null) return
        val at = slot.getLong("at")
        val next = if (at > now) at else at + DUE_WINDOW_MS
        manager.set(AlarmManager.RTC, next + 1_000, pending)
    }

    companion object {
        /** Must match AppConstants.widgetDataKey. */
        private const val DATA_KEY = "dosey_next_dose"

        /** Must match HomeWidgetSync.dueWindow (2 h). */
        private const val DUE_WINDOW_MS = 2 * 60 * 60 * 1000L

        private const val REDRAW_REQUEST = 7301
        private const val ACCENT = 0xFFFD572F.toInt()
        private const val MUTED = 0xFFC6C9BC.toInt()

        /** Below this height (dp) the card's lines would be cut off. */
        private const val CARD_MIN_HEIGHT = 125f
    }
}
