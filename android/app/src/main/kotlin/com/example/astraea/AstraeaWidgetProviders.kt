package com.example.astraea

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.os.Bundle
import android.util.TypedValue
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * The home-screen agenda widgets: daily, weekly and monthly.
 *
 * These are standalone widgets, not shortcuts. Each is drawn natively
 * (RemoteViews + a RemoteViewsFactory backed by [AstraeaWidgetData]) from data
 * the app published earlier, so Android can redraw them by itself — on its
 * periodic tick, when the date changes at midnight, on a timezone change, or
 * after a reboot — while Astraea isn't running.
 *
 * They're interactive, not read-only: the "+" in the header creates an event,
 * and tapping a row opens that event. Both go through home_widget's LAUNCH
 * action carrying an `astraea://…` URI, which the Dart side turns into a screen
 * (see WidgetLaunchHandler).
 *
 * Added the ordinary Android way — long-press the home screen → Widgets — and
 * resizable by long-pressing and dragging the handles (see `resizeMode` and
 * `minResizeWidth`/`minResizeHeight` in the appwidget-info XML). The app has no
 * "add widget" UI.
 */
abstract class AstraeaWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val ACTION_PREVIOUS = "com.example.astraea.widget.PREVIOUS"
        private const val ACTION_NEXT = "com.example.astraea.widget.NEXT"
    }

    /** Which list/grid this widget shows — see [AstraeaWidgetService]. */
    abstract val widgetType: String

    /** Layout to inflate. */
    abstract val layoutId: Int

    /** The collection view inside [layoutId] that the factory feeds. */
    abstract val collectionViewId: Int

    /** Design-time size (dp) this widget's text sizes were chosen at; the
     *  current size vs. this base is what scales the text on resize. Matches
     *  minWidth/minHeight in the appwidget-info XML. */
    abstract val baseWidthDp: Float
    abstract val baseHeightDp: Float

    /** Header text, recomputed at every draw (never baked in by the app). */
    abstract fun headerText(offset: Int): String

    /** Extra per-subclass scaling (e.g. the month grid's weekday strip). */
    open fun applyScale(views: RemoteViews, scale: Float) {}

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            // Persist the widget's current size so the factories (which have
            // no access to the widget options) can scale their rows too.
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val landscape = context.resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
            val widthKey = if (landscape) AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH
                else AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
            val heightKey = if (landscape) AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
                else AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT
            val widthDp = options.getInt(widthKey)
            val heightDp = options.getInt(heightKey)
            if (widthDp > 0 && heightDp > 0) {
                AstraeaWidgetData.saveWidgetSize(context, widgetId, widthDp, heightDp)
            }
            val scale = AstraeaWidgetData.widgetScale(context, widgetId, baseWidthDp, baseHeightDp)

            val views = RemoteViews(context.packageName, layoutId)
            val offset = AstraeaWidgetData.periodOffset(context, widgetId)
            views.setTextViewText(R.id.widget_header, headerText(offset))
            views.setTextViewTextSize(R.id.widget_header, TypedValue.COMPLEX_UNIT_SP, 13f * scale)
            views.setTextViewTextSize(R.id.widget_empty, TypedValue.COMPLEX_UNIT_SP, 12f * scale)
            applyScale(views, scale)

            views.setOnClickPendingIntent(
                R.id.widget_previous,
                navigationIntent(context, widgetId, ACTION_PREVIOUS),
            )
            views.setOnClickPendingIntent(
                R.id.widget_next,
                navigationIntent(context, widgetId, ACTION_NEXT),
            )

            // Each widget instance needs an intent Android considers distinct,
            // or they'd all share one factory: the data URI is what makes it so.
            val serviceIntent = Intent(context, AstraeaWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                putExtra(AstraeaWidgetService.EXTRA_TYPE, widgetType)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(collectionViewId, serviceIntent)
            views.setEmptyView(collectionViewId, R.id.widget_empty)

            // "+" → new event. A complete URI, so this one can stay immutable.
            views.setOnClickPendingIntent(
                R.id.widget_add,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("${AstraeaWidgetService.URI_SCHEME}://${AstraeaWidgetService.HOST_NEW_EVENT}"),
                ),
            )

            // Header (and the empty state behind it) → just open the app.
            views.setOnClickPendingIntent(
                R.id.widget_header,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )

            // Rows → open that event. A collection's children can't hold their
            // own PendingIntent: they fill in this template, which therefore
            // must be MUTABLE (home_widget's own helper builds an immutable one,
            // so this is constructed by hand with the same LAUNCH action its
            // Dart side listens for). Request code 1, NOT 0: the header's
            // PendingIntent above uses 0 with a filterEquals-identical intent
            // (same component + action, both data-less), and the system would
            // hand back that existing IMMUTABLE record — silently breaking
            // every row's fill-in. The base intent must also stay data-less:
            // Intent.fillIn only lets a row set the data URI if the template
            // didn't set one.
            val templateIntent = Intent(context, MainActivity::class.java).apply {
                action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            }
            val template = PendingIntent.getActivity(
                context,
                1,
                templateIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            views.setPendingIntentTemplate(collectionViewId, template)

            appWidgetManager.updateAppWidget(widgetId, views)
            // The header is part of the RemoteViews, but the rows come from the
            // factory — it must be told the data changed or it would keep
            // serving yesterday's list.
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, collectionViewId)
        }
    }

    /**
     * Fired by the launcher when the user long-presses and drags the resize
     * handles. Re-running [onUpdate] re-reads the new size, rescales the
     * header, and its notifyAppWidgetViewDataChanged makes the factory rebuild
     * the rows at the new scale.
     */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    /** Drop the persisted size of widgets removed from the home screen. */
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { AstraeaWidgetData.clearWidgetSize(context, it) }
    }

    /**
     * Redraws on the broadcasts that invalidate a calendar view but that the
     * app can't announce, because it may well not be running: midnight rollover,
     * a timezone change, and the manual/periodic update. This is what keeps the
     * widget correct on its own.
     */
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PREVIOUS, ACTION_NEXT -> {
                val widgetId = intent.getIntExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_ID,
                    AppWidgetManager.INVALID_APPWIDGET_ID,
                )
                val manager = AppWidgetManager.getInstance(context)
                val ownedIds = manager.getAppWidgetIds(ComponentName(context, javaClass))
                if (widgetId in ownedIds) {
                    AstraeaWidgetData.changePeriodOffset(
                        context,
                        widgetId,
                        if (intent.action == ACTION_PREVIOUS) -1 else 1,
                    )
                    onUpdate(context, manager, intArrayOf(widgetId))
                }
            }
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            -> {
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, javaClass))
                if (ids.isNotEmpty()) onUpdate(context, manager, ids)
            }
        }
    }

    private fun navigationIntent(
        context: Context,
        widgetId: Int,
        actionName: String,
    ): PendingIntent {
        val intent = Intent(context, javaClass).apply {
            action = actionName
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            data = Uri.parse("astraea-widget://navigate/$widgetId/${actionName.substringAfterLast('.')}")
        }
        return PendingIntent.getBroadcast(
            context,
            widgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

class AstraeaDayWidgetProvider : AstraeaWidgetProvider() {
    override val widgetType = AstraeaWidgetService.TYPE_DAY
    override val layoutId = R.layout.astraea_widget_list
    override val collectionViewId = R.id.widget_list
    override val baseWidthDp = 250f
    override val baseHeightDp = 110f

    override fun headerText(offset: Int): String =
        SimpleDateFormat("EEEE d MMMM", Locale.getDefault())
            .format(AstraeaWidgetData.startOfToday(offset).time)
}

class AstraeaWeekWidgetProvider : AstraeaWidgetProvider() {
    override val widgetType = AstraeaWidgetService.TYPE_WEEK
    override val layoutId = R.layout.astraea_widget_list
    override val collectionViewId = R.id.widget_list
    override val baseWidthDp = 250f
    override val baseHeightDp = 150f

    override fun headerText(offset: Int): String {
        val start = AstraeaWidgetData.startOfWeek(offset)
        val end = (start.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, 6) }
        val dayOnly = SimpleDateFormat("d", Locale.getDefault())
        val dayMonth = SimpleDateFormat("d MMM", Locale.getDefault())
        return "${dayOnly.format(start.time)} – ${dayMonth.format(end.time)}"
    }
}

class AstraeaMonthWidgetProvider : AstraeaWidgetProvider() {
    override val widgetType = AstraeaWidgetService.TYPE_MONTH
    override val layoutId = R.layout.astraea_widget_month
    override val collectionViewId = R.id.widget_grid
    override val baseWidthDp = 250f
    override val baseHeightDp = 180f

    override fun headerText(offset: Int): String =
        SimpleDateFormat("MMMM y", Locale.getDefault())
            .format(AstraeaWidgetData.startOfMonth(offset).time)

    private val weekdayIds = intArrayOf(
        R.id.weekday_mon, R.id.weekday_tue, R.id.weekday_wed, R.id.weekday_thu,
        R.id.weekday_fri, R.id.weekday_sat, R.id.weekday_sun,
    )

    override fun applyScale(views: RemoteViews, scale: Float) {
        weekdayIds.forEach {
            views.setTextViewTextSize(it, TypedValue.COMPLEX_UNIT_SP, 9f * scale)
        }
    }
}
