import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/discovery.dart';
import '../shell/navigation.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.initialPartId});

  final String? initialPartId;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _search = TextEditingController();
  String? _partId;
  var _favoritesOnly = false;
  var _inProgressOnly = false;

  @override
  void initState() {
    super.initState();
    _partId = widget.initialPartId;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final matches = eligibleExperiences(
      app.pack,
      DiscoveryQuery(
        text: _search.text,
        partId: _partId,
        favoritesOnly: _favoritesOnly,
        favoriteIds: app.favoriteIds,
        inProgressOnly: _inProgressOnly,
        inProgressIds: app.inProgress.map((session) => session.experienceStableId).toSet(),
      ),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Search titles, ids, and text',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Favorites'),
                selected: _favoritesOnly,
                onSelected: (value) => setState(() => _favoritesOnly = value),
              ),
              FilterChip(
                label: const Text('In progress'),
                selected: _inProgressOnly,
                onSelected: (value) => setState(() => _inProgressOnly = value),
              ),
              if (_partId != null)
                InputChip(
                  label: Text(app.pack.partName(_partId)),
                  onDeleted: () => setState(() => _partId = null),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('${matches.length} in alphabetical order'),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                const Text('Nothing is in this slice. Clearing a filter shows the inventory again.')
              else
                for (final experience in matches) ExperienceTile(experience: experience),
            ],
          ),
        ),
      ],
    );
  }
}
