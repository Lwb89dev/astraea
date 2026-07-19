import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'deep_link_handler.dart';
import 'desktop_providers.dart';
import 'desktop_shell.dart';

/// Entry points used by main.dart on IO platforms (conditional import; the
/// web build gets desktop_bootstrap_stub.dart instead).
bool get isLinuxDesktop => Platform.isLinux;

/// Provider overrides for the Linux desktop client (no-op elsewhere, so the
/// Android/iOS paths are untouched).
List<Override> platformOverrides() =>
    isLinuxDesktop ? desktopOverrides() : const [];

/// Wraps the shared app root with the desktop chrome and deep-link handling.
Widget wrapHome({
  required GlobalKey<NavigatorState> navigatorKey,
  required List<String> launchArgs,
  required Widget child,
}) {
  return DesktopDeepLinkHandler(
    navigatorKey: navigatorKey,
    initialUri: DesktopDeepLinkHandler.uriFromArgs(launchArgs),
    child: DesktopShell(child: child),
  );
}
