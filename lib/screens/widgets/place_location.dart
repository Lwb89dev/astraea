import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/event_place.dart';
import '../../services/geocoding_service.dart';
import '../../services/place_navigation.dart';

const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';

class PlaceSheetResult {
  const PlaceSheetResult.chosen(this.place) : keepText = false;

  const PlaceSheetResult.keepText() : place = null, keepText = true;

  final EventPlace? place;
  final bool keepText;
}

Future<PlaceSheetResult?> showPlacePicker({
  required BuildContext context,
  required List<PlaceSearchResult> candidates,
}) {
  return showModalBottomSheet<PlaceSheetResult>(
    context: context,
    showDragHandle: true,
    builder: (context) => PlaceCandidateSheet(candidates: candidates),
  );
}

class PlaceCandidateSheet extends StatelessWidget {
  const PlaceCandidateSheet({super.key, required this.candidates});

  final List<PlaceSearchResult> candidates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(title: Text(l10n.placeChooseTitle)),
        for (final candidate in candidates)
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(_candidateTitle(candidate)),
            subtitle: _candidateSubtitle(candidate),
            onTap: () => Navigator.of(
              context,
            ).pop(PlaceSheetResult.chosen(candidate.place)),
          ),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: Text(l10n.placeKeepTextOnly),
          onTap: () =>
              Navigator.of(context).pop(const PlaceSheetResult.keepText()),
        ),
      ],
    );
  }
}

class ResolvedPlaceSummary extends StatelessWidget {
  const ResolvedPlaceSummary({
    super.key,
    required this.place,
    required this.onResolveAgain,
    required this.onClear,
  });

  final EventPlace place;
  final VoidCallback onResolveAgain;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final detail = place.detailLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(place.headline, style: Theme.of(context).textTheme.titleMedium),
        if (detail != null)
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        if (place.source == EventPlace.osmSource)
          TextButton(
            onPressed: _openOsmCredit,
            child: Text(l10n.placeOsmCredit),
          ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: onResolveAgain,
              child: Text(l10n.placeResolveAgain),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(l10n.placeClearPosition),
            ),
          ],
        ),
      ],
    );
  }
}

class PlaceDetailBlock extends StatelessWidget {
  const PlaceDetailBlock({super.key, required this.place});

  final EventPlace place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final detail = place.detailLine;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_outlined, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.headline,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                ),
                if (detail != null)
                  Text(
                    detail,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                  ),
                if (place.source == EventPlace.osmSource)
                  TextButton(
                    onPressed: _openOsmCredit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.placeOsmCredit),
                  ),
                TextButton.icon(
                  onPressed: () => _navigate(context),
                  icon: const Icon(Icons.navigation_outlined),
                  label: Text(l10n.placeNavigate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigate(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await openPlace(place);
    if (!context.mounted) return;
    final message = switch (outcome) {
      PlaceNavOutcome.roadstr || PlaceNavOutcome.geo => null,
      PlaceNavOutcome.unavailable => l10n.placeNoNavigationApp,
      PlaceNavOutcome.failed => l10n.placeCouldNotNavigate,
    };
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _candidateTitle(PlaceSearchResult candidate) {
  final headline = candidate.place.headline;
  if (headline.isNotEmpty) return headline;
  return candidate.place.displayName ?? '';
}

Widget? _candidateSubtitle(PlaceSearchResult candidate) {
  final detail = candidate.place.detailLine;
  if (detail == null) return null;
  return Text(detail);
}

Future<void> _openOsmCredit() async {
  final uri = Uri.parse(osmCopyrightUrl);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Attribution stays on screen either way.
  }
}
