package com.example.astraea

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle

/**
 * The widget's theme picker (see [WidgetAccent]), shown once: right after a
 * widget is dragged onto the home screen, before it's actually bound (this
 * is Android's `android:configure` activity, launched by the OS itself).
 *
 * Deliberately a one-shot choice, not a "long-press → reconfigure" surface:
 * `android:configure` is the same declaration launchers use for both, and
 * that reconfigure entry point is unreliable across launchers (some don't
 * surface it at all), so instead of a picker that inconsistently reappears,
 * a widget that's already been configured just finishes immediately here —
 * pick the theme again by removing and re-adding the widget.
 */
class AstraeaWidgetConfigActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Cancelled unless a theme is actually picked below (see chooseTheme) —
        // required so an abandoned placement (back button, tap outside) doesn't
        // leave a half-configured widget on the home screen.
        setResult(RESULT_CANCELED)

        val widgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID ||
            AstraeaWidgetData.hasExplicitWidgetAccent(this, widgetId)
        ) {
            finish()
            return
        }

        // Nothing to preselect: the guard above guarantees this widget has
        // never been configured before, so it's always still the default.
        val accents = WidgetAccent.entries.toList()
        val labels = accents.map { getString(it.labelRes) }.toTypedArray()

        AlertDialog.Builder(this)
            .setTitle(R.string.astraea_widget_choose_theme)
            .setSingleChoiceItems(labels, accents.indexOf(WidgetAccent.NAVY)) { dialog, which ->
                chooseTheme(widgetId, accents[which])
                dialog.dismiss()
            }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun chooseTheme(widgetId: Int, accent: WidgetAccent) {
        AstraeaWidgetData.setWidgetAccent(this, widgetId, accent)
        redrawWidget(widgetId)
        setResult(
            RESULT_OK,
            Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId),
        )
        finish()
    }

    /**
     * Re-runs `onUpdate` for whichever of the three providers actually owns
     * this widget id, so the new theme is visible immediately instead of
     * waiting for the next periodic tick.
     */
    private fun redrawWidget(widgetId: Int) {
        val manager = AppWidgetManager.getInstance(this)
        val providers = listOf(
            AstraeaDayWidgetProvider(),
            AstraeaWeekWidgetProvider(),
            AstraeaMonthWidgetProvider(),
        )
        for (provider in providers) {
            val ownedIds = manager.getAppWidgetIds(ComponentName(this, provider.javaClass))
            if (widgetId in ownedIds) {
                provider.onUpdate(this, manager, intArrayOf(widgetId))
                return
            }
        }
    }
}
