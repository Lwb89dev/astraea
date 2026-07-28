import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Receives Kairos' local Linux hand-off.
///
/// Kairos connects to this per-user Unix socket and sends one JSON envelope per
/// line. The socket is intentionally local-only: task contents never go onto
/// a TCP listener or a shared filesystem file.
class KairosLocalSocketServer {
  KairosLocalSocketServer._(this._server, this.path);

  static const socketFileName = 'astraea-kairos.sock';
  static const maxLineBytes = 64 * 1024;

  final ServerSocket _server;
  final String path;
  final Set<Socket> _clients = {};

  static Future<KairosLocalSocketServer?> start(
    Future<void> Function(String raw) onPayload,
  ) async {
    final runtimeDirectory = Platform.environment['XDG_RUNTIME_DIR'];
    if (runtimeDirectory == null || runtimeDirectory.isEmpty) return null;
    final path = '$runtimeDirectory/$socketFileName';

    // A previous Astraea process may have left its Unix socket pathname
    // behind after a crash. It is safe to remove this exact, app-owned path.
    final socketFile = File(path);
    if (await socketFile.exists()) {
      try {
        await socketFile.delete();
      } catch (_) {
        return null;
      }
    }

    try {
      final server = await ServerSocket.bind(
        InternetAddress(path, type: InternetAddressType.unix),
        0,
      );
      final listener = KairosLocalSocketServer._(server, path);
      server.listen((socket) {
        listener._clients.add(socket);
        listener._read(socket, onPayload);
      });
      return listener;
    } catch (_) {
      return null;
    }
  }

  void _read(Socket socket, Future<void> Function(String raw) onPayload) {
    final lines = socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (utf8.encode(line).length > maxLineBytes) return;
            unawaited(onPayload(line));
          },
          onError: (_) {},
          onDone: () {
            _clients.remove(socket);
            socket.destroy();
          },
          cancelOnError: true,
        );
    // Keep the subscription alive through the socket's stream. The local
    // variable documents ownership; cancellation happens in close().
    socket.done.whenComplete(() => lines.cancel());
  }

  Future<void> close() async {
    for (final client in _clients.toList()) {
      client.destroy();
    }
    _clients.clear();
    await _server.close();
    final socketFile = File(path);
    if (await socketFile.exists()) await socketFile.delete();
  }
}
