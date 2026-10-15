import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/chapter_session.dart';
import '../../domain/content_pack.dart';
import '../common/experience_art.dart';
import '../common/source_gap_banner.dart';
import '../journal/journal_screen.dart';
import '../reader/reader_screen.dart';
import '../session/session_screen.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key, required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final favorite = app.favoriteIds.contains(experience.stableId);
    return Scaffold(
      appBar: AppBar(
        title: Text(experience.stableId),
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove favorite' : 'Favorite',
            onPressed: () => app.toggleFavorite(experience.stableId),
            icon: Icon(favorite ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(experience.title, style: Theme.of(context).textTheme.headlineMedium),
          if (experience.partId != null) ...[
            const SizedBox(height: 8),
            Text(app.pack.partName(experience.partId)),
          ],
          if (app.pack.edition.completeness == 'copyedited_draft' && experience.hasFullChapter) ...[
            const SizedBox(height: 8),
            Text(
              'Copyedited draft chapter.',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 16),
          if (experience.artAsset != null) ...[
            ExperienceArt(asset: experience.artAsset!),
            const SizedBox(height: 16),
          ],
          if (!experience.hasFullChapter) const SourceGapBanner(),
          if (experience.premise.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(experience.premise),
          ],
          if (experience.metadata.durationSummary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(experience.metadata.durationSummary),
          ],
          if (experience.metadata.materials.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Materials: ${experience.metadata.materials.join(', ')}'),
          ],
          if (!experience.hasFullChapter) ...[
            const SizedBox(height: 8),
            Text(
              'Duration, materials, and guided steps are blank because this edition does not include them.',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: experience.hasFullChapter
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SessionScreen(
                          definition: chapterSession(experience),
                          experience: experience,
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Begin this chapter'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ReaderScreen(experience: experience)),
              );
            },
            child: Text(experience.hasFullChapter ? 'Read the chapter' : 'Read what is here'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => JournalScreen(experience: experience)),
              );
            },
            child: const Text('Write a note'),
          ),
          const SizedBox(height: 8),
          Text(
            experience.hasFullChapter
                ? 'Begin walks the chapter’s own sections, then the private, shared, and revisit pages. A pass needs no substitute.'
                : 'The book has not supplied steps for this experience yet. A note is still saved as its own visit.',
          ),
        ],
      ),
    );
  }
}
