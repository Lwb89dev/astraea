import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../providers/app_entry_provider.dart';
import '../../services/home_widget_service.dart';
import '../event_details_screen.dart';
import '../event_editor_screen.dart';

/// Turns the home-screen widgets' taps into screens.
///
/// The widgets are standalone, but they're not read-only: the "+" opens the
/// event editor and tapping a row opens that event. Both arrive as an
/// `astraea://…` URI on home_widget's LAUNCH intent — either on a cold start
/// ([HomeWidget.initiallyLaunchedFromHomeWidget]) or while Astraea is already
/// running ([HomeWidget.widgetClicked]) — and this wraps the app to handle both.
///
/// Navigation goes through [navigatorKey] rather than a local context: the tap
/// can land before the first frame, and the routing must not depend on which
/// screen happens to be mounted.
class WidgetLaunchHandler extends ConsumerStatefulWidget {
  const WidgetLaunchHandler({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<WidgetLaunchHandler> createState() =>
      _WidgetLaunchHandlerState();
}

class _WidgetLaunchHandlerState extends ConsumerState<WidgetLaunchHandler> {
  StreamSubscription<Uri?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = HomeWidget.widgetClicked.listen(_handle);
    // A cold start: the intent is already on the activity, so it isn't
    // delivered through the stream. Wait for the first frame so there's a
    // Navigator to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _handle(await HomeWidget.initiallyLaunchedFromHomeWidget());
      } catch (e) {
        developer.log(
          'Could not read the launch intent: $e',
          name: 'WidgetLaunchHandler',
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handle(Uri? uri) {
    if (uri == null ||
        (uri.scheme != HomeWidgetService.scheme &&
            uri.scheme != HomeWidgetService.legacyScheme)) {
      return;
    }
    developer.log('Widget launch: $uri', name: 'WidgetLaunchHandler');

    // Nothing to route to while onboarding is still up — the tap just
    // opens the app, which is the sensible outcome anyway.
    if (ref.read(appEntryProvider).value != true) return;

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    switch (uri.host) {
      case HomeWidgetService.newEventHost:
        navigator.push(
          MaterialPageRoute(
            builder: (_) => EventEditorScreen(initialDay: DateTime.now()),
          ),
        );
      case HomeWidgetService.eventHost:
        final id = uri.queryParameters['id'];
        if (id == null || id.isEmpty) return;
        navigator.push(
          MaterialPageRoute(builder: (_) => EventDetailsScreen(eventId: id)),
        );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
