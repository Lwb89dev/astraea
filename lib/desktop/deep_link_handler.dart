import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calendar_view_provider.dart';
import '../screens/event_details_screen.dart';
import '../screens/event_editor_screen.dart';

/// Handles astraea:// deep links on Linux desktop.
///
/// Two delivery paths (see linux/runner/my_application.cc):
///  - cold start: the URI arrives in `main(List<String> args)` and is passed
///    here as [initialUri];
///  - running instance: the GTK runner is unique, forwards the URI of any
///    second invocation over the `com.lwb89dev.astraea/deeplink` channel and
///    raises the existing window.
///
/// Supported links (docs/dbus-api.md, OpenDesktop):
///   astraea://calendar
///   astraea://calendar/day/2026-07-19
///   astraea://calendar/week/2026-07-19
///   `astraea://event/<id>`          (also legacy `astraea://event?id=<id>`)
///   astraea://new-event?date=2026-07-19
///   astraea://auth/callback?...     (ignored here: the service owns auth)
class DesktopDeepLinkHandler extends ConsumerStatefulWidget {
  const DesktopDeepLinkHandler({
    super.key,
    required this.navigatorKey,
    required this.child,
    this.initialUri,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final Uri? initialUri;

  /// Extracts the first astraea:// URI from the process arguments.
  static Uri? uriFromArgs(List<String> args) {
    for (final arg in args) {
      if (arg.startsWith('astraea://')) return Uri.tryParse(arg);
    }
    return null;
  }

  @override
  ConsumerState<DesktopDeepLinkHandler> createState() =>
      _DesktopDeepLinkHandlerState();
}

class _DesktopDeepLinkHandlerState
    extends ConsumerState<DesktopDeepLinkHandler> {
  static const _channel = MethodChannel('com.lwb89dev.astraea/deeplink');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openUri' && call.arguments is String) {
        _handle(Uri.tryParse(call.arguments as String));
      }
    });
    final initial = widget.initialUri;
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handle(initial));
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  void _handle(Uri? uri) {
    if (uri == null || uri.scheme != 'astraea') return;
    developer.log('deep link: $uri', name: 'DesktopDeepLinkHandler');

    switch (uri.host) {
      case 'calendar':
        _handleCalendar(uri.pathSegments);
      case 'event':
        final id = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : uri.queryParameters['id'];
        if (id != null && id.isNotEmpty) {
          _push(EventDetailsScreen(eventId: id));
        }
      case 'new-event':
        final date = _parseDate(uri.queryParameters['date']);
        _push(EventEditorScreen(initialDay: date ?? DateTime.now()));
      case 'auth':
        // Authentication callbacks belong to the background service's
        // localhost listener; reaching the app this way is a no-op.
        break;
      default:
        developer.log(
          'unsupported deep link host: ${uri.host}',
          name: 'DesktopDeepLinkHandler',
        );
    }
  }

  void _handleCalendar(List<String> segments) {
    final view = ref.read(calendarViewProvider.notifier);
    if (segments.isEmpty) return;
    final date = segments.length > 1 ? _parseDate(segments[1]) : null;
    switch (segments.first) {
      case 'day':
        view.setMode(CalendarViewMode.day);
        if (date != null) view.selectDay(date);
      case 'week':
        view.setMode(CalendarViewMode.week);
        if (date != null) view.selectDay(date);
      case 'month':
        view.setMode(CalendarViewMode.month);
        if (date != null) view.selectDay(date);
      case 'agenda':
        view.setMode(CalendarViewMode.list);
        if (date != null) view.selectDay(date);
    }
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  void _push(Widget screen) {
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
