import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// A scrollable, searchable list of IANA timezones, sourced from the timezone
/// package's own database — the user picks one, they never type it. A typo in a
/// hand-typed zone name silently falls back to the device zone (see
/// [Formatter.toZoned]), which would show every event at the wrong time with no
/// hint as to why.
///
/// Shows the current UTC offset next to each zone, so "Europe/Rome (UTC+2)" is
/// recognisable without knowing the IANA naming scheme.
///
/// Returns the chosen zone name, or the empty string for "follow device" when
/// [allowFollowDevice] is set. Null means the sheet was dismissed.
Future<String?> showTimezonePicker(
  BuildContext context, {
  String? current,
  bool allowFollowDevice = true,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TimezonePickerSheet(
      current: current,
      allowFollowDevice: allowFollowDevice,
    ),
  );
}

class _TimezonePickerSheet extends StatefulWidget {
  const _TimezonePickerSheet({
    required this.current,
    required this.allowFollowDevice,
  });

  final String? current;
  final bool allowFollowDevice;

  @override
  State<_TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<_TimezonePickerSheet> {
  final _searchController = TextEditingController();
  late final List<_Zone> _allZones;
  late List<_Zone> _filtered;

  @override
  void initState() {
    super.initState();
    _allZones = _loadZones();
    _filtered = _allZones;
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Every zone in the loaded IANA database, ordered by current UTC offset then
  /// name, so the list reads geographically rather than alphabetically jumping
  /// across the globe. "UTC" itself is dropped from the list — it's not a place,
  /// and is already the effective fallback.
  List<_Zone> _loadZones() {
    final now = DateTime.now();
    final zones = <_Zone>[];
    for (final name in tz.timeZoneDatabase.locations.keys) {
      // Only the canonical Area/Location names; the database also carries
      // legacy aliases ("EST", "US/Pacific") that would just add noise.
      if (!name.contains('/')) continue;
      try {
        final location = tz.getLocation(name);
        final offset = location.timeZone(now.millisecondsSinceEpoch).offset;
        zones.add(_Zone(name: name, offsetMillis: offset));
      } catch (_) {
        // A zone the database can't resolve is not one we can offer.
      }
    }
    zones.sort((a, b) {
      final byOffset = a.offsetMillis.compareTo(b.offsetMillis);
      return byOffset != 0 ? byOffset : a.name.compareTo(b.name);
    });
    return zones;
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _allZones
          : _allZones
                .where((z) => z.label.toLowerCase().contains(query))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SizedBox(
        height: mediaQuery.size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search a city or region',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (widget.allowFollowDevice)
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Follow device timezone'),
                subtitle: Text(tz.local.name),
                selected: widget.current == null,
                onTap: () => Navigator.of(context).pop(''),
              ),
            const Divider(height: 1),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No matching timezone.'))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final zone = _filtered[i];
                        return ListTile(
                          title: Text(zone.city),
                          subtitle: Text('${zone.area} · ${zone.offsetLabel}'),
                          selected: zone.name == widget.current,
                          trailing: zone.name == widget.current
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.of(context).pop(zone.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Zone {
  _Zone({required this.name, required this.offsetMillis});

  final String name;
  final int offsetMillis;

  /// "Europe/Rome" → "Rome"; "America/Argentina/Buenos_Aires" → "Buenos Aires".
  String get city => name.split('/').last.replaceAll('_', ' ');

  /// "Europe/Rome" → "Europe"; nested zones keep their middle segment too.
  String get area {
    final parts = name.split('/');
    return parts.length > 2
        ? '${parts.first} · ${parts[1].replaceAll('_', ' ')}'
        : parts.first;
  }

  String get label => '$name ${city.toLowerCase()}';

  /// "UTC+2", "UTC-3:30".
  String get offsetLabel {
    final totalMinutes = offsetMillis ~/ 60000;
    final sign = totalMinutes < 0 ? '-' : '+';
    final absolute = totalMinutes.abs();
    final hours = absolute ~/ 60;
    final minutes = absolute % 60;
    return minutes == 0
        ? 'UTC$sign$hours'
        : 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
