import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Non-IO stub of desktop_bootstrap.dart, selected on platforms without
/// `dart:io` (web). See the conditional import in main.dart.
bool get isLinuxDesktop => false;

List<Override> platformOverrides() => const [];

Widget wrapHome({
  required GlobalKey<NavigatorState> navigatorKey,
  required List<String> launchArgs,
  required Widget child,
}) {
  throw UnsupportedError('wrapHome is only used on Linux desktop');
}
