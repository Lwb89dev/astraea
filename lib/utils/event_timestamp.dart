/// Returns a UTC timestamp whose whole-second value is strictly newer than
/// [previous]. Nostr replaceable events are ordered at one-second resolution,
/// so edits and deletions made in rapid succession must not share a second.
DateTime nextEventTimestamp(DateTime previous, {DateTime? now}) {
  final current = (now ?? DateTime.now()).toUtc();
  final previousSecond = previous.toUtc().millisecondsSinceEpoch ~/ 1000;
  final currentSecond = current.millisecondsSinceEpoch ~/ 1000;
  if (currentSecond > previousSecond) return current;
  return DateTime.fromMillisecondsSinceEpoch(
    (previousSecond + 1) * 1000,
    isUtc: true,
  );
}
