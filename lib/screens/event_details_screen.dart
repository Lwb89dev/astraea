import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import 'event_editor_screen.dart';
import '../widgets/astraea_ui.dart';

/// Read-only details of a single event, with edit/delete actions. Looks the
/// event up live from [eventsProvider] by id, so it reflects edits made in
/// the editor without needing the object passed in.
class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(eventsProvider).value ?? const <Event>[];
    Event? found;
    for (final e in events) {
      if (e.id == eventId) {
        found = e;
        break;
      }
    }

    if (found == null) {
      // The event was deleted (e.g. from another action) — pop back out.
      return Scaffold(body: Center(child: Text(l10n.eventNotFound)));
    }
    final event = found;

    final eventColor = parseEventColor(event.color);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventAppBarTitle),
        actions: [
          AstraeaIconButton(
            tooltip: l10n.editTooltip,
            icon: Icons.edit_outlined,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventEditorScreen(existing: event),
              ),
            ),
          ),
          AstraeaIconButton(
            tooltip: l10n.deleteTooltip,
            icon: Icons.delete_outline,
            onPressed: () => _confirmDelete(context, ref, event),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          AstraeaGlassSurface(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            radius: AstraeaTokens.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    color: eventColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  event.title.isEmpty ? l10n.untitledEvent : event.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: event.isAllDay
                      ? l10n.allDayLabel(
                          Formatter.dayLabel(
                            event.startTimeUtc,
                            event.timezone,
                          ),
                        )
                      : '${Formatter.fullLabel(event.startTimeUtc, event.timezone)}\n${Formatter.fullLabel(event.endTimeUtc, event.timezone)}',
                ),
                _DetailRow(icon: Icons.public_rounded, label: event.timezone),
                if (event.location != null && event.location!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.place_outlined,
                    label: event.location!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AstraeaGlassSurface(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            shadow: false,
            child: Column(
              children: [
                if (event.recurrence != RecurrenceType.none)
                  _DetailRow(
                    icon: Icons.repeat_rounded,
                    label: event.recurrenceEnd == null
                        ? Formatter.recurrenceLabel(l10n, event.recurrence)
                        : l10n.recurrenceUntilLabel(
                            Formatter.recurrenceLabel(l10n, event.recurrence),
                            Formatter.dayLabel(
                              event.recurrenceEnd!,
                              event.timezone,
                            ),
                          ),
                  ),
                if (event.reminders.isNotEmpty)
                  _DetailRow(
                    icon: Icons.notifications_outlined,
                    label: event.reminders
                        .map(
                          (r) => Formatter.reminderLabel(l10n, r.minutesBefore),
                        )
                        .join(', '),
                  ),
              ],
            ),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            AstraeaGlassSurface(
              padding: const EdgeInsets.all(18),
              shadow: false,
              child: Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                event.synced
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                event.synced ? l10n.syncedToRelays : l10n.notYetSynced,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEventTitle),
        content: Text(l10n.deleteEventBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(eventsProvider.notifier).delete(event);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
