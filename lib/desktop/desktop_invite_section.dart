import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../utils/formatter.dart';
import 'desktop_providers.dart';

/// Desktop-only attendee invite UI (ADR-007, docs/nostr-sync.md "Attendee
/// invites"). Selected via the same conditional-import seam as
/// `desktop_settings_sections.dart`; the stub returns `null` everywhere else
/// and the shared editor/shell render nothing in its place.
bool get isLinuxDesktop => Platform.isLinux;

/// Attendee list + invite action for an existing event. `null` for a new,
/// not-yet-created event — the service can only invite people to an event
/// it already has a row for (`InviteAttendee` calls `GetEvent` first).
Widget? desktopInviteSection(String eventId) =>
    isLinuxDesktop ? _DesktopInviteSection(eventId: eventId) : null;

/// A small badge button for the sidebar showing the pending-invitations
/// count, opening the accept/decline dialog on tap.
Widget? desktopPendingInvitationsButton() =>
    isLinuxDesktop ? const _PendingInvitationsButton() : null;

// ── Attendees of an event I own ─────────────────────────────────────────

class _DesktopInviteSection extends ConsumerStatefulWidget {
  const _DesktopInviteSection({required this.eventId});

  final String eventId;

  @override
  ConsumerState<_DesktopInviteSection> createState() =>
      _DesktopInviteSectionState();
}

class _DesktopInviteSectionState extends ConsumerState<_DesktopInviteSection> {
  late Future<List<Map<String, dynamic>>> _attendees;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _attendees = ref
        .read(dbusCalendarClientProvider)
        .getAttendees(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.inviteSectionTitle,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openInviteDialog(context),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: Text(l10n.inviteButtonLabel),
            ),
          ],
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _attendees,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              );
            }
            final attendees = snapshot.data ?? const [];
            if (attendees.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noAttendeesYet,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final attendee in attendees)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    title: Text(
                      Formatter.truncateKey(
                        attendee['pubkeyHex'] as String? ?? '',
                      ),
                    ),
                    trailing: _StatusChip(
                      status: attendee['status'] as String? ?? 'invited',
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _openInviteDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.inviteDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.inviteDialogHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.inviteButtonLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    if (query == null || query.isEmpty || !context.mounted) return;
    await _resolveAndInvite(context, query);
  }

  /// Step-by-step confirmation flow, matching Echoes' share sheet: resolve
  /// first, then — for a NIP-05 identifier specifically, since that mapping
  /// is the domain operator's claim rather than proof of identity — make the
  /// user confirm the resolved key before anything is sent.
  Future<void> _resolveAndInvite(BuildContext context, String query) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final client = ref.read(dbusCalendarClientProvider);

    final Map<String, dynamic> resolved;
    try {
      resolved = await client.resolvePerson(query);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.resolvePersonFailed(e.toString()))),
      );
      return;
    }
    final pubkeyHex = resolved['pubkeyHex'] as String? ?? '';
    final viaNip05 = resolved['viaNip05'] == true;
    if (pubkeyHex.isEmpty) return;

    if (viaNip05) {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.confirmNip05Title),
          content: Text(
            l10n.confirmNip05Body(query, Formatter.truncateKey(pubkeyHex)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await client.inviteAttendee(widget.eventId, pubkeyHex);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.inviteFailed(e.toString()))),
      );
      return;
    }
    if (!mounted) return;
    setState(_reload);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      'accepted' => (l10n.attendeeStatusAccepted, Colors.green),
      'declined' => (l10n.attendeeStatusDeclined, theme.colorScheme.error),
      _ => (l10n.attendeeStatusInvited, theme.colorScheme.onSurfaceVariant),
    };
    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
    );
  }
}

// ── Invitations addressed to me ─────────────────────────────────────────

class _PendingInvitationsButton extends ConsumerWidget {
  const _PendingInvitationsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(desktopPendingInvitationsProvider);
    final count = pending.value?.length ?? 0;

    return IconButton(
      tooltip: l10n.pendingInvitationsTooltip,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => const _PendingInvitationsDialog(),
      ),
      icon: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        child: const Icon(Icons.mail_outline),
      ),
    );
  }
}

class _PendingInvitationsDialog extends ConsumerWidget {
  const _PendingInvitationsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(desktopPendingInvitationsProvider);

    return AlertDialog(
      title: Text(l10n.pendingInvitationsTitle),
      content: SizedBox(
        width: 420,
        child: pending.when(
          loading: () => const Center(
            heightFactor: 2,
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Text(e.toString()),
          data: (invitations) {
            if (invitations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.pendingInvitationsEmpty),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: [
                for (final invitation in invitations)
                  _InvitationTile(invitation: invitation),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.done),
        ),
      ],
    );
  }
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({required this.invitation});

  final Map<String, dynamic> invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = invitation['invitationId'] as String? ?? '';
    final inviter = invitation['inviterPubkey'] as String? ?? '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(invitation['title'] as String? ?? ''),
      subtitle: Text(l10n.invitationFromLabel(Formatter.truncateKey(inviter))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.declineInvitation,
            icon: const Icon(Icons.close),
            onPressed: () => _respond(context, ref, id, false),
          ),
          IconButton(
            tooltip: l10n.acceptInvitation,
            icon: const Icon(Icons.check),
            onPressed: () => _respond(context, ref, id, true),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    String invitationId,
    bool accept,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(dbusCalendarClientProvider)
          .respondToInvitation(invitationId, accept);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.respondToInvitationFailed(e.toString()))),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          accept ? l10n.invitationAccepted : l10n.invitationDeclined,
        ),
      ),
    );
    ref.invalidate(desktopPendingInvitationsProvider);
  }
}
