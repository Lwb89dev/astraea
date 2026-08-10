#!/usr/bin/env bash
# Renders the widget-picker preview PNGs (android:previewImage) for the three
# home-screen widgets.
#
# Why a PNG at all, when res/layout/astraea_widget_preview_*.xml already exists:
# android:previewLayout is API 31+. Astraea's minSdk is 24, and on API 24–30
# the picker can only show a static previewImage. Without one, those launchers
# fall back to the app icon — or, worse, to an unbound inflation of the real
# layout, which is the empty box the preview layouts were added to fix.
#
# The output is checked in (res/drawable-nodpi/) so a normal build needs no
# ImageMagick. Re-run this only when the widget's visual design changes:
#
#   ./tool/render_widget_previews.sh
#
# Requires ImageMagick (`convert`). The geometry mirrors the real layouts —
# same scrim, corner radius, paddings, text sizes and accent tones as
# astraea_widget_background.xml / astraea_widget_item.xml / the navy drawables
# — so the raster preview and the API 31+ layout preview agree.
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
out="$here/android/app/src/main/res/drawable-nodpi"
mkdir -p "$out"

command -v convert >/dev/null || {
    echo "ImageMagick (convert) is required" >&2
    exit 1
}

# Everything is rendered at 2x the widget's dp size (xhdpi), which is plenty
# for a picker thumbnail and keeps the PNGs small. Every constant below is
# therefore "dp * 2".
SCRIM='#161A2ECC'      # astraea_widget_background.xml, 90% of #E6161A2E
ACCENT_DARK='#3F51B5'  # astraea_widget_dot.xml   (navy, saturated)
ACCENT_LIGHT='#9FA8DA' # astraea_widget_today.xml (navy, light)
WHITE='#FFFFFF'
MUTED='#B3FFFFFF'
RADIUS=40

FONT="$(fc-match -f '%{file}' 'DejaVu Sans:style=Book')"
FONT_BOLD="$(fc-match -f '%{file}' 'DejaVu Sans:style=Bold')"
[ -n "$FONT" ] && [ -n "$FONT_BOLD" ] || { echo "no usable font found" >&2; exit 1; }

# Draw operations accumulate here as a plain argv array — no eval, so a title
# containing a space or a quote cannot break the command line.
ARGS=()

# header WIDTH HEIGHT TITLE — rounded scrim plus the title row (bullet, text,
# accent "+" pill), echoing the header LinearLayout the real layouts share.
header() {
    local width=$1 height=$2 title=$3
    ARGS=(
        -size "${width}x${height}" xc:none
        -fill "$SCRIM"
        -draw "roundrectangle 0,0 $((width - 1)),$((height - 1)) $RADIUS,$RADIUS"
        -fill "$MUTED" -draw "circle 34,32 34,36"
        -font "$FONT_BOLD" -pointsize 26 -fill "$WHITE"
        -draw "text 48,40 '$title'"
        -fill "$ACCENT_LIGHT"
        -draw "circle $((width - 40)),32 $((width - 40)),46"
        -font "$FONT_BOLD" -pointsize 30 -fill "$SCRIM"
        -draw "text $((width - 50)),42 '+'"
    )
}

# row Y TIME TITLE COLOUR [TITLE_X] — one agenda row: colour bar, time, title.
#
# TITLE_X is where the title column starts. It is a parameter because the week
# widget prefixes each time with a weekday ("Thu 18:00"), which is wide enough
# to run into a title column sized for the day widget's bare "18:00".
row() {
    local y=$1 time=$2 title=$3 colour=$4 title_x=${5:-150}
    ARGS+=(
        -fill "$colour" -draw "rectangle 24,$((y - 14)) 30,$((y + 14))"
        -font "$FONT" -pointsize 22 -fill "$MUTED"
        -draw "text 44,$((y + 8)) '$time'"
        -font "$FONT" -pointsize 24 -fill "$WHITE"
        -draw "text $title_x,$((y + 8)) '$title'"
    )
}

emit() {
    convert "${ARGS[@]}" "PNG32:$out/$1.png"
    echo "rendered $out/$1.png"
}

# ── Day: 250x110dp → 500x220, three rows ────────────────────────────────
header 500 220 'Thursday 12 February'
row 100 '09:00' 'Team stand-up' "$ACCENT_DARK"
row 146 '13:30' 'Lunch with Ada' "$ACCENT_LIGHT"
row 192 '18:00' 'Climbing session' "$ACCENT_DARK"
emit astraea_widget_preview_day

# ── Week: 250x150dp → 500x300, four weekday-prefixed rows ───────────────
header 500 300 '9 - 15 Feb'
row 106 'Mon 09:00' 'Team stand-up' "$ACCENT_DARK" 200
row 158 'Tue 11:00' 'Lunch with Ada' "$ACCENT_LIGHT" 200
row 210 'Thu 18:00' 'Climbing session' "$ACCENT_DARK" 200
row 262 'Sat 20:30' 'Film night' "$ACCENT_LIGHT" 200
emit astraea_widget_preview_week

# ── Month: 250x180dp → 500x360 ──────────────────────────────────────────
# The weekday strip plus February 2026, today circled on the 12th and event
# dots on 3, 9, 12, 17 and 24 — the same sample month that
# astraea_widget_preview_month.xml draws, so the two previews agree.
header 500 360 'February 2026'

WEEKS=(
    "0 0 0 0 0 0 1"
    "2 3 4 5 6 7 8"
    "9 10 11 12 13 14 15"
    "16 17 18 19 20 21 22"
    "23 24 25 26 27 28 0"
)
TODAY=12
DOTTED=" 3 9 12 17 24 "

ARGS+=(-font "$FONT" -pointsize 18 -fill "$MUTED")
for i in 0 1 2 3 4 5 6; do
    letter=${_weekday_letters:-MTWTFSS}
    ARGS+=(-draw "text $((39 + i * 69)),100 '${letter:$i:1}'")
done

y=138
for week in "${WEEKS[@]}"; do
    i=0
    for day in $week; do
        x=$((44 + i * 69))
        i=$((i + 1))
        [ "$day" = 0 ] && continue
        if [ "$day" = "$TODAY" ]; then
            # Today's number sits on the light accent circle, so it flips to
            # the dark scrim colour — the same pairing the provider applies.
            ARGS+=(
                -fill "$ACCENT_LIGHT" -draw "circle $x,$((y - 6)) $x,$((y + 8))"
                -fill "$SCRIM"
            )
        else
            ARGS+=(-fill "$WHITE")
        fi
        ARGS+=(
            -font "$FONT" -pointsize 20
            -draw "text $((x - ${#day} * 6)),$y '$day'"
        )
        case "$DOTTED" in
            *" $day "*)
                ARGS+=(
                    -fill "$ACCENT_DARK"
                    -draw "circle $x,$((y + 13)) $x,$((y + 17))"
                )
                ;;
        esac
    done
    y=$((y + 44))
done
emit astraea_widget_preview_month

echo
echo "Preview images written. They are referenced by android:previewImage in"
echo "android/app/src/main/res/xml/astraea_*_widget_info.xml."
