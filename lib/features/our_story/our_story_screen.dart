import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/private/journal_repository.dart';
import '../../domain/content_pack.dart';
import '../shell/navigation.dart';

class OurStoryScreen extends StatefulWidget {
  const OurStoryScreen({super.key});

  @override
  State<OurStoryScreen> createState() => _OurStoryScreenState();
}

class _OurStoryScreenState extends State<OurStoryScreen> {
  String? _profileId;
  Future<List<JournalEntry>>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = AppScope.of(context).activeProfile;
    if (profile?.id == _profileId) {
      return;
    }
    _profileId = profile?.id;
    _entries = profile == null ? null : AppScope.of(context).journal.entriesVisibleTo(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final profile = app.activeProfile;
    if (profile == null || _entries == null) {
      return const Center(child: Text('Add a profile to see notes.'));
    }
    return FutureBuilder(
      future: _entries,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: Text('Opening notes'));
        }
        if (entries.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              Text('Your story will show the notes you actually write.'),
              SizedBox(height: 8),
              Text('Private notes from the other profile stay off this timeline. Nothing is invented to fill the space.'),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Visible to ${profile.displayLabel}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in entries)
              _StoryCard(entryExperience: app.pack.find(entry.experienceStableId), entry: entry),
          ],
        );
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.entryExperience, required this.entry});

  final Experience? entryExperience;
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final title = entryExperience?.title ?? entry.experienceStableId;
    final archived = entryExperience?.archiveReason != null;
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          '${entry.scope == 'shared' ? 'Shared' : 'Private'}'
          '${archived ? ' · archived chapter' : ''}\n'
          '${entry.updatedAt}\n${entry.body}',
        ),
        isThreeLine: true,
        onTap: entryExperience == null ? null : () => openExperience(context, entryExperience!),
      ),
    );
  }
}
