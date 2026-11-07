import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_providers.dart';

/// Forces one sync cycle when the desktop client starts.
///
/// On Linux the calendar lives in astraea-service, not in this process, so the
/// mobile [SyncNotifier.syncOnStartup] path does not apply: the equivalent is a
/// single `SyncNow` call on `com.lwb89dev.Astraea.Calendar1`. The service is
/// idempotent about it — a cycle already in flight simply absorbs the nudge.
///
/// Deliberately fire-and-forget and deliberately silent:
///  - the first frame must not wait on a D-Bus round-trip or on relays;
///  - a service that is not running, or a session with no account or no relays
///    yet, is a normal state at start-up, not something to interrupt the user
///    about. The sync tile in Settings and the sidebar status already show the
///    real state, and a manual retry is one click away.
class DesktopStartupSync extends ConsumerStatefulWidget {
  const DesktopStartupSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DesktopStartupSync> createState() => _DesktopStartupSyncState();
}

class _DesktopStartupSyncState extends ConsumerState<DesktopStartupSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOnce());
  }

  Future<void> _syncOnce() async {
    if (!mounted) return;
    try {
      await ref.read(dbusCalendarClientProvider).syncNow();
    } catch (error) {
      developer.log(
        'Start-up sync could not be requested from the service',
        name: 'DesktopStartupSync',
        error: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
