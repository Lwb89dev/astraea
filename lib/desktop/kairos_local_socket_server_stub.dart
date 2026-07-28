/// Web/non-IO fallback for the Linux-only Kairos Unix-socket bridge.
class KairosLocalSocketServer {
  static Future<KairosLocalSocketServer?> start(
    Future<void> Function(String raw) onPayload,
  ) async => null;

  String get path => '';
}
