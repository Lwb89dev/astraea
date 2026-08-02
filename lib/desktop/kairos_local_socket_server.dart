import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Receives Kairos' local Linux hand-off.
///
/// Kairos connects to this per-user Unix socket and sends one JSON envelope per
/// line. The socket is intentionally local-only: task contents never go onto a
/// TCP listener or a shared filesystem file, and it lives in
/// `$XDG_RUNTIME_DIR`, which the OS creates as a 0700 directory owned by the
/// session user — so "who can connect" is already bounded to processes running
/// as that user.
///
/// That still makes this an *attack surface*: any process in the user's own
/// session can connect (a compromised browser extension host, a malicious
/// AppImage, a bug in an unrelated app). So the reader treats a peer as
/// untrusted and bounds everything it can consume:
///
///  - at most [maxClients] concurrent connections; further ones are closed
///    immediately, so a connection flood cannot exhaust file descriptors;
///  - at most [maxLineBytes] buffered per connection *while reading*, not
///    after the fact — a peer that never sends a newline is disconnected once
///    it crosses the limit instead of being buffered indefinitely;
///  - one payload in flight per connection, with the socket paused while it is
///    handled, so a flood of valid lines cannot spawn unbounded concurrent
///    database writes.
///
/// Payload *content* is validated separately, where it is decoded
/// (`EventsNotifier.importKairosTask`).
class KairosLocalSocketServer {
  KairosLocalSocketServer._(this._server, this.path);

  static const socketFileName = 'astraea-kairos.sock';

  /// Hard cap on one hand-off line. A Kairos task envelope is a few hundred
  /// bytes; 64 KiB is generous for the largest realistic one.
  static const maxLineBytes = 64 * 1024;

  /// Kairos opens one connection. A small allowance covers a restart racing
  /// its own previous socket without letting a hostile peer open thousands.
  static const maxClients = 8;

  static const int _newline = 0x0a;

  final ServerSocket _server;
  final String path;
  final Set<_KairosClient> _clients = {};

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
      server.listen((socket) => listener._accept(socket, onPayload));
      return listener;
    } catch (_) {
      return null;
    }
  }

  void _accept(Socket socket, Future<void> Function(String raw) onPayload) {
    if (_clients.length >= maxClients) {
      socket.destroy();
      return;
    }
    final client = _KairosClient(socket, onPayload, _clients.remove);
    _clients.add(client);
    client.start();
  }

  Future<void> close() async {
    for (final client in _clients.toList()) {
      client.dispose();
    }
    _clients.clear();
    await _server.close();
    final socketFile = File(path);
    if (await socketFile.exists()) await socketFile.delete();
  }
}

/// One accepted connection, with its own bounded read buffer.
///
/// Byte-level framing rather than `utf8.decoder` + `LineSplitter`: those
/// buffer a whole line before anything downstream can inspect its size, so a
/// peer sending gigabytes with no newline would be buffered in full before a
/// length check could ever run. Splitting on the newline byte ourselves lets
/// the limit be enforced *as bytes arrive*.
class _KairosClient {
  _KairosClient(this._socket, this._onPayload, this._onClosed);

  final Socket _socket;
  final Future<void> Function(String raw) _onPayload;
  final void Function(_KairosClient client) _onClosed;

  final BytesBuilder _buffer = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _subscription;

  void start() {
    _subscription = _socket.listen(
      _onData,
      onError: (_) => dispose(),
      onDone: dispose,
      cancelOnError: true,
    );
  }

  void _onData(Uint8List chunk) {
    for (final byte in chunk) {
      if (byte != KairosLocalSocketServer._newline) {
        _buffer.addByte(byte);
        // Over the limit with no newline in sight: this peer is not speaking
        // the protocol. Drop the connection rather than keep buffering.
        if (_buffer.length > KairosLocalSocketServer.maxLineBytes) dispose();
        continue;
      }
      final line = _buffer.takeBytes();
      if (line.isNotEmpty) _dispatch(line);
    }
  }

  /// Hands one complete line to the app, with the socket paused until it has
  /// been processed. That is the backpressure: a peer cannot make Astraea run
  /// an unbounded number of concurrent imports by sending lines faster than
  /// they can be stored.
  void _dispatch(Uint8List line) {
    final subscription = _subscription;
    if (subscription == null) return;
    final String raw;
    try {
      raw = utf8.decode(line);
    } catch (_) {
      return; // Not UTF-8: not a Kairos envelope. Skip the line, keep reading.
    }

    subscription.pause();
    // Errors are the importer's to report; here they must only never leave
    // the socket paused forever.
    _onPayload(raw).whenComplete(() {
      if (_subscription != null) subscription.resume();
    });
  }

  void dispose() {
    if (_subscription == null) return;
    _subscription?.cancel();
    _subscription = null;
    _socket.destroy();
    _onClosed(this);
  }
}
