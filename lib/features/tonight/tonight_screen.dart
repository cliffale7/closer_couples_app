import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/discovery.dart';
import '../common/source_gap_banner.dart';
import '../discover/filter_panel.dart';
import '../shell/constellation_mark.dart';
import '../shell/navigation.dart';

class TonightScreen extends StatefulWidget {
  const TonightScreen({super.key});

  @override
  State<TonightScreen> createState() => _TonightScreenState();
}

class _TonightScreenState extends State<TonightScreen> {
  final _time = <String>{};
  final _outcomes = <String>{};
  final _energy = <String>{};
  final _depth = <String>{};
  final _formats = <String>{};
  final _passed = <String>{};
  SurpriseResult? _surprise;
  var _seed = 17;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final query = _query();
    final matches = eligibleExperiences(app.pack, query);
    final resume = app.inProgress;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Row(
          children: [
            ConstellationMark(),
            SizedBox(width: 16),
            Expanded(
              child: Text('Choose a limit first. Surprise Us stays inside it.'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!app.pack.isFinishedBook)
          SourceGapBanner(compact: true, completeness: app.pack.edition.completeness),
        const SizedBox(height: 8),
        DiscoveryFilterPanel(
          time: _time,
          outcomes: _outcomes,
          energy: _energy,
          depth: _depth,
          formats: _formats,
          onToggle: _toggle,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            setState(() {
              _surprise = surpriseUs(app.pack, query, _seed);
            });
          },
          child: const Text('Surprise us'),
        ),
        if (_surprise != null) ...[
          const SizedBox(height: 12),
          if (_surprise!.experience == null)
            Text(_surprise!.emptyReason ?? 'Nothing matches.')
          else ...[
            ExperienceTile(experience: _surprise!.experience!),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _seed += 1;
                      _surprise = surpriseUs(app.pack, _query(), _seed);
                    });
                  },
                  child: const Text('Reroll'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _passed.add(_surprise!.experience!.stableId);
                      _seed += 1;
                      _surprise = surpriseUs(app.pack, _query(), _seed);
                    });
                  },
                  child: const Text('Pass'),
                ),
              ],
            ),
          ],
        ],
        if (resume.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Pick up a note', style: Theme.of(context).textTheme.titleMedium),
          for (final session in resume)
            if (app.pack.find(session.experienceStableId) != null)
              ExperienceTile(
                experience: app.pack.find(session.experienceStableId)!,
                subtitle: 'Note in progress · ${session.experienceStableId}',
              ),
        ],
        const SizedBox(height: 12),
        Text(
          matches.isEmpty ? 'No experiences match.' : '${matches.length} match',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (matches.isEmpty && _surprise?.emptyReason != emptyDiscoveryReason(app.pack, query))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(emptyDiscoveryReason(app.pack, query)),
          )
        else
          for (final experience in matches) ExperienceTile(experience: experience),
      ],
    );
  }

  DiscoveryQuery _query() {
    return DiscoveryQuery(
      timeBuckets: _time,
      outcomes: _outcomes,
      energy: _energy,
      depth: _depth,
      formats: _formats,
      excludeIds: _passed,
    );
  }

  void _toggle(String group, String id) {
    setState(() {
      final target = switch (group) {
        'time' => _time,
        'outcome' => _outcomes,
        'energy' => _energy,
        'depth' => _depth,
        _ => _formats,
      };
      if (!target.add(id)) {
        target.remove(id);
      }
      _surprise = null;
    });
  }
}
