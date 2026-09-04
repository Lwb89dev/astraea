package com.example.astraea

import android.content.Context
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import java.util.Calendar
import kotlin.math.sqrt

/**
 * One occurrence of a calendar event, as published by the Flutter side
 * (HomeWidgetService.updateAll) and read back here at draw time.
 *
 * The widgets are drawn from this cached data by Android itself, with no
 * Flutter engine involved, which is what lets them refresh on a periodic tick,
 * at midnight or after a reboot while Astraea isn't running.
 */
data class WidgetEvent(
    /** The app's event id — what a tapped row deep-links to. */
    val id: String,
    val startMillis: Long,
    val endMillis: Long,
    val title: String,
    val color: Int,
    val isAllDay: Boolean,
) {
    /** Start as a local-time Calendar — the widget always shows device-local time. */
    fun startCalendar(): Calendar = Calendar.getInstance().apply { timeInMillis = startMillis }
}

/**
 * Per-widget-instance theme (ADR-free — a small, self-contained native
 * feature): chosen at creation via [AstraeaWidgetConfigActivity] and
 * changeable afterwards through most launchers' long-press "Widget
 * settings" action, which the OS re-launches the same configure Activity
 * for. Deliberately independent from the Flutter app's own Settings >
 * Appearance accent — this is the *widget's* accent, not the app's.
 *
 * [dayBackground]/[dot]/[addBackground] mirror the app-side two-tone
 * pairing (a lighter tint for a highlighted day's background, the brand's
 * own saturated tone for the event indicator) with hand-picked drawables
 * instead of the Dart `AppAccent` enum, since RemoteViews can only apply a
 * color by swapping to a pre-baked drawable resource, not by computing one
 * at runtime.
 */
enum class WidgetAccent(val prefsValue: String, val labelRes: Int) {
    NAVY("navy", R.string.astraea_widget_theme_navy),
    BITCOIN("bitcoin", R.string.astraea_widget_theme_bitcoin),
    NOSTR("nostr", R.string.astraea_widget_theme_nostr);

    val dayBackground: Int
        get() = when (this) {
            NAVY -> R.drawable.astraea_widget_today
            BITCOIN -> R.drawable.astraea_widget_today_bitcoin
            NOSTR -> R.drawable.astraea_widget_today_nostr
        }

    val dot: Int
        get() = when (this) {
            NAVY -> R.drawable.astraea_widget_dot
            BITCOIN -> R.drawable.astraea_widget_dot_bitcoin
            NOSTR -> R.drawable.astraea_widget_dot_nostr
        }

    val addBackground: Int
        get() = when (this) {
            NAVY -> R.drawable.astraea_widget_add_background
            BITCOIN -> R.drawable.astraea_widget_add_background_bitcoin
            NOSTR -> R.drawable.astraea_widget_add_background_nostr
        }

    companion object {
        fun fromPrefsValue(value: String?): WidgetAccent =
            entries.firstOrNull { it.prefsValue == value } ?: NAVY
    }
}

object AstraeaWidgetData {
    // Stable bridge keys: changing these would discard cached widget state on
    // upgrades from the former Epochs identity.
    private const val EVENTS_KEY = "epochs_events"
    private const val DEFAULT_COLOR = 0xFF2196F3.toInt()
    private const val DIMS_PREFS = "epochs_widget_dims"
    private const val STATE_PREFS = "epochs_widget_state"

    // ── Per-widget size → text scale ─────────────────────────────────────
    // RemoteViews text sizes are fixed sp values, so resizing a widget leaves
    // its text unchanged unless we recompute it. The provider persists each
    // widget's current dp size here (onUpdate/onAppWidgetOptionsChanged), and
    // both the provider (header) and the factories (rows — they run in a
    // separate binder callback with no access to the widget options) read it
    // back to scale their text.

    fun saveWidgetSize(context: Context, widgetId: Int, widthDp: Int, heightDp: Int) {
        context.getSharedPreferences(DIMS_PREFS, Context.MODE_PRIVATE)
            .edit()
            .putInt("w_$widgetId", widthDp)
            .putInt("h_$widgetId", heightDp)
            .apply()
    }

    fun clearWidgetSize(context: Context, widgetId: Int) {
        context.getSharedPreferences(DIMS_PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove("w_$widgetId")
            .remove("h_$widgetId")
            .apply()
        context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove("offset_$widgetId")
            .remove("accent_$widgetId")
            .apply()
    }

    /**
     * Text multiplier for a widget currently sized vs. its design-time base
     * size. The geometric mean lets a vertical-only resize affect the content
     * without allowing one very long axis to dominate. Clamped so labels stay
     * legible at the small end and collection rows remain useful at the large
     * end.
     */
    fun widgetScale(context: Context, widgetId: Int, baseWidthDp: Float, baseHeightDp: Float): Float {
        val prefs = context.getSharedPreferences(DIMS_PREFS, Context.MODE_PRIVATE)
        val w = prefs.getInt("w_$widgetId", 0)
        val h = prefs.getInt("h_$widgetId", 0)
        if (w <= 0 || h <= 0) return 1f
        return sqrt((w / baseWidthDp) * (h / baseHeightDp)).coerceIn(0.82f, 1.65f)
    }

    fun widgetWidth(context: Context, widgetId: Int, fallbackDp: Int): Int =
        context.getSharedPreferences(DIMS_PREFS, Context.MODE_PRIVATE)
            .getInt("w_$widgetId", fallbackDp)

    fun widgetHeight(context: Context, widgetId: Int, fallbackDp: Int): Int =
        context.getSharedPreferences(DIMS_PREFS, Context.MODE_PRIVATE)
            .getInt("h_$widgetId", fallbackDp)

    /** Relative day/week/month selected by one widget instance. */
    fun periodOffset(context: Context, widgetId: Int): Int =
        context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
            .getInt("offset_$widgetId", 0)

    /**
     * [minOffset]/[maxOffset] must match the calling widget's own
     * [AstraeaWidgetProvider.maxPastOffset]/[AstraeaWidgetProvider.maxFutureOffset]
     * — bounding navigation to Flutter's cache window (HomeWidgetService),
     * not a generic constant, since day/week/month each interpret this
     * offset in a different unit.
     */
    fun changePeriodOffset(context: Context, widgetId: Int, delta: Int, minOffset: Int, maxOffset: Int) {
        val prefs = context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
        val current = prefs.getInt("offset_$widgetId", 0)
        prefs.edit().putInt("offset_$widgetId", (current + delta).coerceIn(minOffset, maxOffset)).apply()
    }

    /** This widget instance's theme (see [WidgetAccent]); NAVY until chosen. */
    fun widgetAccent(context: Context, widgetId: Int): WidgetAccent =
        WidgetAccent.fromPrefsValue(
            context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
                .getString("accent_$widgetId", null),
        )

    /**
     * Whether a theme has ever actually been chosen for this widget, as
     * opposed to [widgetAccent] merely falling back to NAVY. Distinguishes
     * "this is the first-placement configure launch" from "some launcher
     * re-launched the configure activity to reconfigure an existing widget"
     * — see [AstraeaWidgetConfigActivity].
     */
    fun hasExplicitWidgetAccent(context: Context, widgetId: Int): Boolean =
        context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
            .contains("accent_$widgetId")

    fun setWidgetAccent(context: Context, widgetId: Int, accent: WidgetAccent) {
        context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString("accent_$widgetId", accent.prefsValue)
            .apply()
    }

    /**
     * Reads the published occurrences. Returns an empty list when the app has
     * never published anything yet, or if the payload is unreadable — a widget
     * must degrade to its empty state, never crash the launcher.
     */
    fun loadEvents(context: Context): List<WidgetEvent> {
        val raw = HomeWidgetPlugin.getData(context).getString(EVENTS_KEY, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            (0 until array.length()).mapNotNull { i ->
                val o = array.optJSONObject(i) ?: return@mapNotNull null
                WidgetEvent(
                    id = o.optString("i", ""),
                    startMillis = o.optLong("s"),
                    endMillis = o.optLong("e"),
                    title = o.optString("t", ""),
                    color = parseColor(o.optString("c", "")),
                    isAllDay = o.optBoolean("a", false),
                )
            }.sortedBy { it.startMillis }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** Parses the app's "0xFF2196F3" colour format. */
    private fun parseColor(value: String): Int = try {
        if (value.startsWith("0x")) value.substring(2).toLong(16).toInt()
        else Color.parseColor(value)
    } catch (e: Exception) {
        DEFAULT_COLOR
    }

    // ── Date helpers ─────────────────────────────────────────────────────
    // All ranges are computed from `now` at draw time (never baked in by the
    // app), so a widget that Android redraws after midnight shows the new day.

    fun startOfToday(offsetDays: Int = 0): Calendar = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
        add(Calendar.DAY_OF_YEAR, offsetDays)
    }

    /** Monday of the current week. */
    fun startOfWeek(offsetWeeks: Int = 0): Calendar = startOfToday().apply {
        // Calendar.DAY_OF_WEEK is Sun=1..Sat=7; normalise to Mon=0..Sun=6.
        val offset = (get(Calendar.DAY_OF_WEEK) + 5) % 7
        add(Calendar.DAY_OF_YEAR, -offset)
        add(Calendar.WEEK_OF_YEAR, offsetWeeks)
    }

    fun startOfMonth(offsetMonths: Int = 0): Calendar = startOfToday().apply {
        set(Calendar.DAY_OF_MONTH, 1)
        add(Calendar.MONTH, offsetMonths)
    }

    fun isSameDay(a: Calendar, b: Calendar): Boolean =
        a.get(Calendar.YEAR) == b.get(Calendar.YEAR) &&
            a.get(Calendar.DAY_OF_YEAR) == b.get(Calendar.DAY_OF_YEAR)

    /**
     * Events visible on the given day, in order. A multi-day event belongs to
     * every day it overlaps; a Kairos task (start == end) belongs to the one
     * day containing its due instant.
     */
    fun eventsOn(events: List<WidgetEvent>, day: Calendar): List<WidgetEvent> =
        events.filter { event ->
            val dayStart = (day.clone() as Calendar).apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val dayEnd = (dayStart.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, 1)
            }
            if (event.startMillis == event.endMillis) {
                event.startMillis >= dayStart.timeInMillis &&
                    event.startMillis < dayEnd.timeInMillis
            } else {
                event.endMillis > dayStart.timeInMillis &&
                    event.startMillis < dayEnd.timeInMillis
            }
        }

    /** Events overlapping [from, to), in chronological order. */
    fun eventsBetween(events: List<WidgetEvent>, from: Calendar, to: Calendar): List<WidgetEvent> =
        events.filter { event ->
            if (event.startMillis == event.endMillis) {
                event.startMillis >= from.timeInMillis && event.startMillis < to.timeInMillis
            } else {
                event.endMillis > from.timeInMillis && event.startMillis < to.timeInMillis
            }
        }
}
