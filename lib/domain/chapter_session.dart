import 'content_pack.dart';
import 'session_engine.dart';

/// A guided sitting built from the chapter that is already in the pack.
///
/// The steps are the book's own sections and Our Story prompts. This does not
/// invent a separate scoring engine for a game.
InteractionDefinition chapterSession(Experience experience) {
  final steps = <InteractionStep>[
    InteractionStep(
      id: '${experience.stableId}-prepare',
      type: 'prepare',
      heading: 'Before you start',
      text: _prepareText(experience),
    ),
  ];
  for (final block in experience.proseBlocks) {
    if (block.kind == 'deck') {
      steps.add(_read(experience.stableId, 'deck', block.heading ?? 'In short', block.text));
      continue;
    }
    if (block.kind != 'section') {
      continue;
    }
    final heading = block.heading ?? 'Chapter';
    if (heading == 'Our Story') {
      steps.addAll(journalStepsFromStory(experience.stableId, block.text));
      continue;
    }
    steps.add(_read(experience.stableId, heading, heading, block.text));
  }
  if (steps.length == 1) {
    steps.add(
      InteractionStep(
        id: '${experience.stableId}-missing',
        type: 'read',
        heading: experience.title,
        text: 'This edition has no chapter text to guide.',
      ),
    );
  }
  return InteractionDefinition(
    id: experience.stableId,
    title: experience.title,
    notice: 'From the chapter. Either of you can pass or pause. Private pages stay with the person who wrote them.',
    steps: steps,
  );
}

List<InteractionStep> journalStepsFromStory(String experienceId, String storyText) {
  final fence = RegExp(r'```journal\s*([\s\S]*?)```').firstMatch(storyText);
  final instructions = (fence == null ? storyText : storyText.substring(0, fence.start)).trim();
  final steps = <InteractionStep>[];
  if (instructions.isNotEmpty) {
    steps.add(_read(experienceId, 'our-story', 'Our Story', instructions));
  }
  if (fence == null) {
    steps.add(
      InteractionStep(
        id: '$experienceId-our-story-note',
        type: 'answer_shared',
        heading: 'Our Story',
        text: storyText.trim(),
        promptId: '$experienceId-our-story',
        promptRevision: 1,
        scope: 'shared',
      ),
    );
    return steps;
  }
  String? section;
  final counts = <String, int>{};
  for (final rawLine in fence.group(1)!.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final header = RegExp(r'^(session|partner_a|partner_b|shared|revisit):\s*(.*)$').firstMatch(line);
    if (header != null) {
      section = header.group(1);
      final inline = header.group(2)!.trim();
      if (inline.isNotEmpty) {
        steps.add(_promptStep(experienceId, section!, inline, counts));
      }
      continue;
    }
    if (section != null && line.startsWith('- ')) {
      steps.add(_promptStep(experienceId, section, line.substring(2).trim(), counts));
    }
  }
  return steps;
}

InteractionStep _promptStep(String experienceId, String section, String text, Map<String, int> counts) {
  final number = (counts[section] ?? 0) + 1;
  counts[section] = number;
  final private = section == 'partner_a' || section == 'partner_b';
  return InteractionStep(
    id: '$experienceId-$section-$number',
    type: private ? 'answer_private' : 'answer_shared',
    heading: _sectionLabel(section),
    text: text,
    role: private ? section : null,
    promptId: '$experienceId-$section-$number',
    promptRevision: 1,
    scope: private ? 'private' : 'shared',
  );
}

InteractionStep _read(String experienceId, String slug, String heading, String text) {
  final safe = slug.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return InteractionStep(
    id: '$experienceId-$safe',
    type: 'read',
    heading: heading,
    text: text.trim(),
  );
}

String _prepareText(Experience experience) {
  final duration = experience.metadata.durationSummary;
  final materials = experience.metadata.materials;
  final pieces = <String>[
    'Agree that either person can pass any step, and that a pass needs no substitute confession.',
  ];
  if (duration.isNotEmpty) {
    pieces.add(duration);
  }
  if (materials.isNotEmpty) {
    pieces.add('Materials: ${materials.join(', ')}.');
  }
  return pieces.join('\n\n');
}

String _sectionLabel(String section) {
  switch (section) {
    case 'partner_a':
      return 'Private page · Partner A';
    case 'partner_b':
      return 'Private page · Partner B';
    case 'shared':
      return 'Shared page';
    case 'revisit':
      return 'Revisit';
    case 'session':
      return 'Session';
    default:
      return section;
  }
}
