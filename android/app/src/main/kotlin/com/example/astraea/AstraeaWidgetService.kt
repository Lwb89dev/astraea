package com.example.astraea

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Feeds the widgets' collection views. One service serves all three widget
 * types, selected by [EXTRA_TYPE] on the intent.
 *
 * Everything here runs without the app: rows are built from the cached
 * occurrences ([AstraeaWidgetData]) and the current date — and the widget's
 * current size, for text scaling — are read at
 * [RemoteViewsFactory.onDataSetChanged] time, so a widget Android redraws after
 * midnight or a resize is correct by itself.
 *
 * Rows are tappable: each fills in the provider's pending-intent template with
 * an `astraea://event?id=…` URI, which the Dart side routes to that event's
 * details screen.
 */
class AstraeaWidgetService : RemoteViewsService() {
    companion object {
        const val EXTRA_TYPE = "astraea_widget_type"
        const val TYPE_DAY = "day"
        const val TYPE_WEEK = "week"
        const val TYPE_MONTH = "month"

        /** Deep links back into the app; mirrored in HomeWidgetService (Dart). */
        const val URI_SCHEME = "astraea"
        const val HOST_NEW_EVENT = "new-event"
        const val HOST_EVENT = "event"
    }

    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        val widgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        )
        return when (intent.getStringExtra(EXTRA_TYPE)) {
            TYPE_WEEK -> WeekAgendaFactory(applicationContext, widgetId)
            TYPE_MONTH -> MonthGridFactory(applicationContext, widgetId)
            else -> DayAgendaFactory(applicationContext, widgetId)
        }
    }
}

/** The fill-in intent that opens one event's details. */
private fun openEventIntent(eventId: String): Intent = Intent().apply {
    data = Uri.Builder()
        .scheme(AstraeaWidgetService.URI_SCHEME)
        .authority(AstraeaWidgetService.HOST_EVENT)
        .appendQueryParameter("id", eventId)
        .build()
}

/**
 * Builds one agenda row, text sized by [scale] (the widget's current size vs.
 * its base — see [AstraeaWidgetData.widgetScale]). The colour bar's height can
 * only follow along on API 31+, where RemoteViews gained setViewLayoutHeight;
 * below that it stays at its layout size, which reads fine.
 */
private fun agendaRow(context: Context, event: WidgetEvent, timeLabel: String, scale: Float): RemoteViews =
    RemoteViews(context.packageName, R.layout.astraea_widget_item).apply {
        setInt(R.id.item_color, "setBackgroundColor", event.color)
        setTextViewText(R.id.item_time, timeLabel)
        setTextViewText(
            R.id.item_title,
            event.title.ifEmpty { context.getString(R.string.astraea_widget_untitled) },
        )
        setTextViewTextSize(R.id.item_time, TypedValue.COMPLEX_UNIT_SP, 11f * scale)
        setTextViewTextSize(R.id.item_title, TypedValue.COMPLEX_UNIT_SP, 12f * scale)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            setViewLayoutHeight(R.id.item_color, 14f * scale, TypedValue.COMPLEX_UNIT_DIP)
        }
        setOnClickFillInIntent(R.id.item_root, openEventIntent(event.id))
    }

/** Today's events, one row each. */
private class DayAgendaFactory(
    private val context: Context,
    private val widgetId: Int,
) : RemoteViewsService.RemoteViewsFactory {
    private var rows: List<WidgetEvent> = emptyList()
    private var scale = 1f
    private var offset = 0

    override fun onCreate() {}

    override fun onDataSetChanged() {
        offset = AstraeaWidgetData.periodOffset(context, widgetId)
        rows = AstraeaWidgetData.eventsOn(
            AstraeaWidgetData.loadEvents(context),
            AstraeaWidgetData.startOfToday(offset),
        )
        scale = AstraeaWidgetData.widgetScale(context, widgetId, 250f, 110f)
    }

    override fun onDestroy() { rows = emptyList() }
    override fun getCount() = rows.size
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount() = 1
    // Folds the period offset in so a day with the same event count as the
    // previously shown one is still recognised as a different dataset — see
    // itemIdFor's doc comment for why plain positional ids aren't enough.
    override fun getItemId(position: Int) = itemIdFor(offset, position)
    override fun hasStableIds() = true

    override fun getViewAt(position: Int): RemoteViews =
        agendaRow(context, rows[position], formatTime(rows[position]), scale)
}

/** This week, Monday–Sunday: one row per event, prefixed with its weekday. */
private class WeekAgendaFactory(
    private val context: Context,
    private val widgetId: Int,
) : RemoteViewsService.RemoteViewsFactory {
    private var rows: List<WidgetEvent> = emptyList()
    private var scale = 1f
    private var offset = 0

    override fun onCreate() {}

    override fun onDataSetChanged() {
        offset = AstraeaWidgetData.periodOffset(context, widgetId)
        val start = AstraeaWidgetData.startOfWeek(offset)
        val end = (start.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, 7) }
        rows = AstraeaWidgetData.eventsBetween(AstraeaWidgetData.loadEvents(context), start, end)
        scale = AstraeaWidgetData.widgetScale(context, widgetId, 250f, 150f)
    }

    override fun onDestroy() { rows = emptyList() }
    override fun getCount() = rows.size
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = itemIdFor(offset, position)
    override fun hasStableIds() = true

    override fun getViewAt(position: Int): RemoteViews {
        val event = rows[position]
        val weekday = SimpleDateFormat("EEE", Locale.getDefault()).format(event.startCalendar().time)
        return agendaRow(context, event, "$weekday ${formatTime(event)}", scale)
    }
}

/**
 * The current month as a 7-column grid. A month view can't show titles at
 * widget size, so it shows density instead — a dot under each day that has
 * events, with today highlighted. Tapping a day opens its first event, if any.
 */
private class MonthGridFactory(
    private val context: Context,
    private val widgetId: Int,
) : RemoteViewsService.RemoteViewsFactory {
    private var cells: List<Cell> = emptyList()
    private var scale = 1f
    private var offset = 0

    /** [day] is null for the blank cells before the 1st. */
    private data class Cell(val day: Int?, val isToday: Boolean, val firstEventId: String?)

    override fun onCreate() {}

    override fun onDataSetChanged() {
        scale = AstraeaWidgetData.widgetScale(context, widgetId, 250f, 180f)
        val events = AstraeaWidgetData.loadEvents(context)
        offset = AstraeaWidgetData.periodOffset(context, widgetId)
        val monthStart = AstraeaWidgetData.startOfMonth(offset)
        val today = Calendar.getInstance()
        val isCurrentMonth = monthStart.get(Calendar.MONTH) == today.get(Calendar.MONTH) &&
            monthStart.get(Calendar.YEAR) == today.get(Calendar.YEAR)
        val daysInMonth = monthStart.getActualMaximum(Calendar.DAY_OF_MONTH)
        // Blank cells before the 1st, with the week starting on Monday.
        val leading = (monthStart.get(Calendar.DAY_OF_WEEK) + 5) % 7

        // First event per day of this month — both the dot and the tap target.
        val firstEventByDay = mutableMapOf<Int, String>()
        for (event in events) {
            val c = event.startCalendar()
            if (c.get(Calendar.MONTH) == monthStart.get(Calendar.MONTH) &&
                c.get(Calendar.YEAR) == monthStart.get(Calendar.YEAR)
            ) {
                firstEventByDay.putIfAbsent(c.get(Calendar.DAY_OF_MONTH), event.id)
            }
        }

        val populated = (0 until leading).map { Cell(null, false, null) } +
            (1..daysInMonth).map { day ->
                Cell(
                    day = day,
                    isToday = isCurrentMonth && day == today.get(Calendar.DAY_OF_MONTH),
                    firstEventId = firstEventByDay[day],
                )
            }
        // Always provide complete weeks. Besides looking like a calendar, this
        // makes its row count deterministic for the height calculation below.
        val trailing = (7 - populated.size % 7) % 7
        cells = populated + (0 until trailing).map { Cell(null, false, null) }
    }

    override fun onDestroy() { cells = emptyList() }
    override fun getCount() = cells.size
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = itemIdFor(offset, position)
    override fun hasStableIds() = true

    override fun getViewAt(position: Int): RemoteViews {
        val cell = cells[position]
        // The day number sits in a fixed 18dp box (the today-circle). On 31+
        // the box grows with the text; before that, cap the text so it can't
        // outgrow the box it's centred in.
        val canGrowBox = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
        val textScale = if (canGrowBox) scale else scale.coerceAtMost(1.2f)
        val rowCount = (cells.size / 7).coerceAtLeast(1)
        val widgetHeight = AstraeaWidgetData.widgetHeight(context, widgetId, 180)
        // Root padding + header + weekday strip + margins consume roughly 70dp.
        // Divide the actual remainder between calendar weeks so resizing the
        // widget grows/shrinks the grid rather than leaving dead space.
        val cellHeight = ((widgetHeight - 70f) / rowCount).coerceIn(24f, 72f)

        return RemoteViews(context.packageName, R.layout.astraea_widget_month_cell).apply {
            setTextViewTextSize(R.id.cell_day, TypedValue.COMPLEX_UNIT_SP, 10f * textScale)
            if (canGrowBox) {
                setViewLayoutHeight(R.id.cell_root, cellHeight, TypedValue.COMPLEX_UNIT_DIP)
                setViewLayoutWidth(R.id.cell_day, 18f * scale, TypedValue.COMPLEX_UNIT_DIP)
                setViewLayoutHeight(R.id.cell_day, 18f * scale, TypedValue.COMPLEX_UNIT_DIP)
            }
            if (cell.day == null) {
                setTextViewText(R.id.cell_day, "")
                setViewVisibility(R.id.cell_dot, View.INVISIBLE)
                setInt(R.id.cell_day, "setBackgroundResource", 0)
            } else {
                setTextViewText(R.id.cell_day, cell.day.toString())
                setViewVisibility(
                    R.id.cell_dot,
                    if (cell.firstEventId != null) View.VISIBLE else View.INVISIBLE,
                )
                if (cell.isToday) {
                    setInt(R.id.cell_day, "setBackgroundResource", R.drawable.astraea_widget_today)
                    setTextColor(R.id.cell_day, 0xFF161A2E.toInt())
                } else {
                    setInt(R.id.cell_day, "setBackgroundResource", 0)
                    setTextColor(R.id.cell_day, 0xFFFFFFFF.toInt())
                }
                // A day with no events has nothing to open; an empty fill-in
                // intent just opens the app.
                setOnClickFillInIntent(
                    R.id.cell_root,
                    cell.firstEventId?.let { openEventIntent(it) } ?: Intent(),
                )
            }
        }
    }
}

/** "13:00", or a bullet for an all-day event. */
private fun formatTime(event: WidgetEvent): String =
    if (event.isAllDay) "•" else SimpleDateFormat("HH:mm", Locale.getDefault()).format(event.startCalendar().time)

/**
 * Item id for [position] under the given period [offset] (day/week/month
 * navigation — see [AstraeaWidgetData.periodOffset]).
 *
 * `hasStableIds() = true` combined with a plain `position.toLong()` id makes
 * `RemoteViewsAdapter` (the framework class backing List/GridView in
 * AppWidgets) treat two different periods with the same item count as the
 * *same* dataset at the id level, and it can then skip re-binding rows whose
 * position/id didn't change — this is a well-known collection-widget
 * staleness class of bug. Two consecutive months very often need the same
 * number of grid cells (35 for a 5-row month, 42 for a 6-row one), so the
 * "forward" button would appear to freeze exactly on months that happen to
 * share a cell count with the one before them — matching the reported "gets
 * stuck at the current month, or moves once and then gets stuck" symptom.
 * Folding the offset into the id makes every period change look like a
 * structurally new dataset, forcing a full re-bind every time.
 */
private fun itemIdFor(offset: Int, position: Int): Long = (offset + 200).toLong() * 1000L + position
