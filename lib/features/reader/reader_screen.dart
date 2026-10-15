import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/closer_theme.dart';
import '../../domain/content_pack.dart';
import '../common/experience_art.dart';
import '../common/source_gap_banner.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final palette = ReaderPalette.named(app.readerTheme);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        title: Text(experience.stableId),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Reading theme',
            onSelected: (value) {
              app.setReaderTheme(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'parchment', child: Text('Parchment')),
              PopupMenuItem(value: 'ink', child: Text('Ink')),
              PopupMenuItem(value: 'night', child: Text('Night')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 48),
        children: [
          Text(
            experience.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: palette.foreground),
          ),
          const SizedBox(height: 8),
          if (experience.partId != null) ...[
            const SizedBox(height: 8),
            Text(
              app.pack.partName(experience.partId),
              style: TextStyle(color: palette.muted),
            ),
          ],
          const SizedBox(height: 16),
          if (experience.artAsset != null) ...[
            ExperienceArt(asset: experience.artAsset!),
            const SizedBox(height: 16),
          ],
          if (!experience.hasFullChapter) const SourceGapBanner(),
          const SizedBox(height: 16),
          for (final block in experience.proseBlocks) ...[
            Text(
              block.heading ?? _label(block.kind),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.foreground),
            ),
            if (block.kind == 'design_brief')
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'From the baseline notes. This is not the finished chapter.',
                  style: TextStyle(color: palette.muted),
                ),
              ),
            const SizedBox(height: 8),
            SelectableText(
              block.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.foreground,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 22),
          ],
        ],
      ),
    );
  }

  String _label(String kind) {
    switch (kind) {
      case 'source_premise':
        return 'Premise from the inventory';
      case 'design_brief':
        return 'Design brief';
      case 'full_chapter':
        return 'Chapter';
      default:
        return kind;
    }
  }
}
