import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dbus/dbus.dart';

import '../models/event_model.dart';
import 'service_event_codec.dart';

/// Dart client for the Astraea Linux background service
/// (`com.lwb89dev.Astraea.Service` on the session bus — docs/dbus-api.md).
///
/// Every call is asynchronous and bounded by [callTimeout]. A call to a
/// stopped service triggers D-Bus activation transparently; a system without
/// the service installed surfaces [ServiceUnavailableException] so the UI can
/// show a clear error instead of hanging.
class DbusCalendarClient {
  DbusCalendarClient({DBusClient? bus}) : _bus = bus ?? DBusClient.session() {
    _object = DBusRemoteObject(
      _bus,
      name: busName,
      path: DBusObjectPath(objectPath),
    );
  }

  static const String busName = 'com.lwb89dev.Astraea.Service';
  static const String objectPath = '/com/lwb89dev/Astraea';
  static const String calendarInterface = 'com.lwb89dev.Astraea.Calendar1';
  static const String accountInterface = 'com.lwb89dev.NostrAccount1';
  static const Duration callTimeout = Duration(seconds: 25);

  final DBusClient _bus;
  late final DBusRemoteObject _object;

  Future<void> close() => _bus.close();

  // -------------------------------------------------------------------
  // Events
  // -------------------------------------------------------------------

  /// Master events intersecting `[start, end)` — the shared [Event] model,
  /// so all existing screens work unchanged.
  Future<List<Event>> listEvents({
    required DateTime startUtc,
    required DateTime endUtc,
    List<String> calendarIds = const [],
  }) async {
    final raw = await _callString(calendarInterface, 'ListEvents', [
      DBusInt64(startUtc.millisecondsSinceEpoch ~/ 1000),
      DBusInt64(endUtc.millisecondsSinceEpoch ~/ 1000),
      DBusArray.string(calendarIds),
    ]);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (e) => ServiceEventCodec.fromServiceJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<String> createEvent(Event event) async {
    return _callString(calendarInterface, 'CreateEvent', [
      DBusString(jsonEncode(ServiceEventCodec.toDraftJson(event))),
    ]);
  }

  Future<void> updateEvent(Event event) async {
    await _callString(calendarInterface, 'UpdateEvent', [
      DBusString(event.id),
      DBusString(jsonEncode(ServiceEventCodec.toPatchJson(event))),
    ]);
  }

  Future<void> deleteEvent(String eventId) async {
    await _call(calendarInterface, 'DeleteEvent', [DBusString(eventId)], null);
  }

  // -------------------------------------------------------------------
  // Calendars / status / settings
  // -------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCalendars() async {
    final raw = await _callString(calendarInterface, 'GetCalendars', []);
    return (jsonDecode(raw) as List<dynamic>)
        .map((c) => Map<String, dynamic>.from(c as Map))
        .toList();
  }

  Future<Map<String, dynamic>> getServiceStatus() async {
    final raw = await _callString(calendarInterface, 'GetServiceStatus', []);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final raw = await _callString(calendarInterface, 'GetSyncStatus', []);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>> getAuthenticationStatus() async {
    final raw = await _callString(
      accountInterface,
      'GetAuthenticationStatus',
      [],
    );
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<String> syncNow() => _callString(calendarInterface, 'SyncNow', []);

  Future<Map<String, dynamic>> beginBrowserLogin() async {
    final raw = await _callString(accountInterface, 'BeginBrowserLogin', []);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> logout() async {
    await _call(accountInterface, 'Logout', [], null);
  }

  // -------------------------------------------------------------------
  // Signals
  // -------------------------------------------------------------------

  /// Emits on every `EventsChanged` signal (the payload lists changed event
  /// ids; an empty list means "refresh everything").
  Stream<List<String>> eventsChanged() {
    final stream = DBusSignalStream(
      _bus,
      sender: busName,
      interface: calendarInterface,
      name: 'EventsChanged',
      path: DBusObjectPath(objectPath),
    );
    return stream.map(
      (signal) => signal.values.isNotEmpty && signal.values.first is DBusArray
          ? (signal.values.first as DBusArray).children
                .map((v) => (v as DBusString).value)
                .toList()
          : const <String>[],
    );
  }

  Stream<void> calendarsChanged() {
    return DBusSignalStream(
      _bus,
      sender: busName,
      interface: calendarInterface,
      name: 'CalendarsChanged',
      path: DBusObjectPath(objectPath),
    ).map((_) {});
  }

  Stream<Map<String, dynamic>> authenticationChanged() {
    return DBusSignalStream(
      _bus,
      sender: busName,
      interface: accountInterface,
      name: 'AuthenticationChanged',
      path: DBusObjectPath(objectPath),
    ).map((signal) {
      try {
        final raw = (signal.values.first as DBusString).value;
        return Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        return const <String, dynamic>{};
      }
    });
  }

  // -------------------------------------------------------------------
  // Plumbing
  // -------------------------------------------------------------------

  Future<String> _callString(
    String interface,
    String method,
    List<DBusValue> args,
  ) async {
    final result = await _call(interface, method, args, DBusSignature('s'));
    return (result.returnValues.first as DBusString).value;
  }

  Future<DBusMethodSuccessResponse> _call(
    String interface,
    String method,
    List<DBusValue> args,
    DBusSignature? replySignature,
  ) async {
    try {
      return await _object
          .callMethod(interface, method, args, replySignature: replySignature)
          .timeout(callTimeout);
    } on DBusServiceUnknownException catch (e) {
      throw ServiceUnavailableException(
        'astraea-service is not installed or not activatable: $e',
      );
    } on TimeoutException {
      throw ServiceUnavailableException(
        'astraea-service did not answer within ${callTimeout.inSeconds}s '
        '($method)',
      );
    } on DBusMethodResponseException catch (e) {
      developer.log(
        '$method failed: ${e.response.errorName}',
        name: 'DbusCalendarClient',
      );
      rethrow;
    }
  }
}

/// The service cannot be reached at all (not installed / no session bus).
/// Distinct from a method-level error so the UI can offer "install/start".
class ServiceUnavailableException implements Exception {
  ServiceUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}
