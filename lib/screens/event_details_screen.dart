import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import 'event_editor_screen.dart';

/// Read-only details of a single event, with edit/delete actions. Looks the
/// event up live from [eventsProvider] by id, so it reflects edits made in
/// the editor without needing the object passed in.
class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      return const Scaffold(body: Center(child: Text('Event not found.')));
    }
    final event = found;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventEditorScreen(existing: event),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, event),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: parseEventColor(event.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title.isEmpty ? '(untitled)' : event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: Icons.schedule,
            label: event.isAllDay
                ? '${Formatter.dayLabel(event.startTimeUtc, event.timezone)} · All day'
                : '${Formatter.fullLabel(event.startTimeUtc, event.timezone)}\n'
                      '${Formatter.fullLabel(event.endTimeUtc, event.timezone)}',
          ),
          _DetailRow(icon: Icons.public, label: event.timezone),
          if (event.recurrence != RecurrenceType.none)
            _DetailRow(
              icon: Icons.repeat,
              label: event.recurrenceEnd == null
                  ? Formatter.recurrenceLabel(event.recurrence)
                  : '${Formatter.recurrenceLabel(event.recurrence)} · until '
                        '${Formatter.dayLabel(event.recurrenceEnd!, event.timezone)}',
            ),
          if (event.reminders.isNotEmpty)
            _DetailRow(
              icon: Icons.notifications_outlined,
              label: event.reminders
                  .map((r) => Formatter.reminderLabel(r.minutesBefore))
                  .join(', '),
            ),
          if (event.location != null && event.location!.isNotEmpty)
            _DetailRow(icon: Icons.place_outlined, label: event.location!),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
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
                event.synced ? 'Synced to relays' : 'Not yet synced',
                style: Theme.of(context).textTheme.bodySmall,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text(
          'This removes the event from this device and requests deletion from the relays.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
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
