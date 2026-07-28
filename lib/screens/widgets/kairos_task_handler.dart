import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/calendar_view_provider.dart';
import '../../providers/events_provider.dart';

/// Receives the local Android hand-off from Kairos and puts the selected task
/// straight into Astraea's local calendar. The native side waits for the
/// `ready` call before delivering a cold-start payload, so no task is lost
/// while Flutter is creating its engine.
class KairosTaskHandler extends ConsumerStatefulWidget {
  const KairosTaskHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<KairosTaskHandler> createState() => _KairosTaskHandlerState();
}

class _KairosTaskHandlerState extends ConsumerState<KairosTaskHandler> {
  static const _channel = MethodChannel('com.example.astraea/kairos');

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _channel.setMethodCallHandler(_handleCall);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _channel.invokeMethod<void>('ready');
        } catch (error) {
          developer.log(
            'Could not register Kairos local bridge: $error',
            name: 'KairosTaskHandler',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  Future<void> _handleCall(MethodCall call) async {
    if (call.method != 'kairosTask' || call.arguments is! String) {
      throw MissingPluginException('Unsupported Kairos bridge method.');
    }
    final raw = call.arguments as String;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final event = await ref
            .read(eventsProvider.notifier)
            .importKairosTask(raw);
        if (!mounted) return;
        final local = event.startTimeUtc.toLocal();
        final view = ref.read(calendarViewProvider.notifier);
        view.setMode(CalendarViewMode.day);
        view.selectDay(DateTime(local.year, local.month, local.day));
      } catch (error, stackTrace) {
        developer.log(
          'Could not import local Kairos task: $error',
          name: 'KairosTaskHandler',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
