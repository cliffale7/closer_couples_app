import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../common/experience_art.dart';
import '../discover/discover_screen.dart';
import '../shell/navigation.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final draft = app.pack.edition.completeness == 'copyedited_draft';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (app.pack.edition.coverAsset != null) ...[
          ExperienceArt(asset: app.pack.edition.coverAsset!, height: 220),
          const SizedBox(height: 16),
        ],
        if (app.pack.frontMatter.isNotEmpty) ...[
          Text('Before the experiences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final piece in app.pack.frontMatter) ExperienceTile(experience: piece),
          const SizedBox(height: 16),
        ],
        Text('Thirteen parts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final part in app.pack.parts)
          Card(
            child: ListTile(
              title: Text(part.name),
              subtitle: Text('Part ${part.ordinal.toString().padLeft(2, '0')} · ${part.experienceIds.length}'),
              trailing: Text('${part.experienceIds.length}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(part.name)),
                      body: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (part.artAsset != null) ...[
                            ExperienceArt(asset: part.artAsset!),
                            const SizedBox(height: 16),
                          ],
                          if (part.intro != null && part.intro!.trim().isNotEmpty) ...[
                            Text(part.intro!),
                            const SizedBox(height: 16),
                          ],
                          for (final id in part.experienceIds)
                            if (app.pack.find(id) != null)
                              ExperienceTile(experience: app.pack.find(id)!),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Text('Signature sessions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (app.pack.signatures.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${app.pack.requiredSignatureIds.join(', ')} are part of the finished book. None are in the v0.1 baseline, so this library does not invent them.',
              ),
            ),
          )
        else
          for (final signature in app.pack.signatures)
            ExperienceTile(experience: signature.asExperience()),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Search')),
                  body: const DiscoverScreen(),
                ),
              ),
            );
          },
          child: Text(draft ? 'Search the book' : 'Search the whole inventory'),
        ),
      ],
    );
  }
}
