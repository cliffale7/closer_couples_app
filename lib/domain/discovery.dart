import 'dart:math';

import 'content_pack.dart';

class FacetOption {
  const FacetOption(this.id, this.label, this.detail);
  final String id;
  final String label;
  final String detail;
}

const timeBuckets = <FacetOption>[
  FacetOption('5-10', '5–10 min', 'Quick Connections'),
  FacetOption('10-20', '10–20 min', 'Little Discoveries'),
  FacetOption('20-45', '20–45 min', 'Meaningful Sessions'),
  FacetOption('45-90', '45–90 min', 'Deep Dives'),
  FacetOption('90-180', '90 min–3 hours', 'Full Experiences'),
  FacetOption('multi-day', 'Multi-day', 'The Long Game'),
];

const outcomeOptions = <FacetOption>[
  FacetOption('laugh', 'Laugh / play', ''),
  FacetOption('secret', 'A new perspective', ''),
  FacetOption('history', 'Personal history', ''),
  FacetOption('vulnerability', 'Vulnerability', ''),
  FacetOption('trust', 'Trust', ''),
  FacetOption('loved', 'Feeling loved', ''),
  FacetOption('reconnect', 'Reconnect', ''),
  FacetOption('romance', 'Romance', ''),
  FacetOption('sensuality', 'Sensuality', ''),
  FacetOption('philosophy', 'Philosophy', ''),
  FacetOption('create', 'Create together', ''),
  FacetOption('adventure', 'Adventure', ''),
  FacetOption('support', 'Support', ''),
  FacetOption('future', 'Future vision', ''),
  FacetOption('discover', 'Discover', ''),
  FacetOption('philosophize', 'Philosophize', ''),
  FacetOption('explore', 'Explore', ''),
  FacetOption('steady', 'Steady', ''),
  FacetOption('feel loved', 'Feel loved', ''),
  FacetOption('deepen vulnerability', 'Deepen vulnerability', ''),
  FacetOption('desire', 'Desire', ''),
  FacetOption('play', 'Play', ''),
  FacetOption('quiet', 'Quiet', ''),
  FacetOption('care', 'Care', ''),
  FacetOption('meaning', 'Meaning', ''),
  FacetOption('tender', 'Tender', ''),
  FacetOption('reflect', 'Reflect', ''),
  FacetOption('notice', 'Notice', ''),
  FacetOption('affection', 'Affection', ''),
  FacetOption('memory', 'Memory', ''),
  FacetOption('candor', 'Candor', ''),
  FacetOption('clarify', 'Clarify', ''),
  FacetOption('warm', 'Warm', ''),
  FacetOption('direct', 'Direct', ''),
  FacetOption('settle', 'Settle', ''),
  FacetOption('listen', 'Listen', ''),
  FacetOption('careful', 'Careful', ''),
  FacetOption('attention', 'Attention', ''),
  FacetOption('ordinary', 'Ordinary', ''),
  FacetOption('closeness', 'Closeness', ''),
  FacetOption('attraction', 'Attraction', ''),
  FacetOption('design', 'Design', ''),
  FacetOption('repair', 'Repair', ''),
  FacetOption('curious', 'Curious', ''),
  FacetOption('honest', 'Honest', ''),
  FacetOption('map', 'Map', ''),
  FacetOption('have an adventure', 'Have an adventure', ''),
  FacetOption('build trust', 'Build trust', ''),
  FacetOption('comfort', 'Comfort', ''),
  FacetOption('gratitude', 'Gratitude', ''),
];

const energyOptions = <FacetOption>[
  FacetOption('low', 'Low / restful', ''),
  FacetOption('medium', 'Medium', ''),
  FacetOption('high', 'High / active', ''),
];

const depthOptions = <FacetOption>[
  FacetOption('light', 'Light & playful', ''),
  FacetOption('personal', 'Personal', ''),
  FacetOption('deep', 'Deep & vulnerable', ''),
  FacetOption('intense', 'Very intense', ''),
];

const formatOptions = <FacetOption>[
  FacetOption('conversation', 'Conversation', ''),
  FacetOption('qa', 'Questions', ''),
  FacetOption('cooperative', 'Cooperative game', ''),
  FacetOption('competitive', 'Light competition', ''),
  FacetOption('writing', 'Writing', ''),
  FacetOption('reflection', 'Reflection', ''),
  FacetOption('improv', 'Improv', ''),
  FacetOption('making', 'Make something', ''),
  FacetOption('mindfulness', 'Mindfulness', ''),
  FacetOption('touch', 'Affectionate touch', ''),
  FacetOption('sensual', 'Sensual', ''),
  FacetOption('outdoor', 'Outdoors', ''),
  FacetOption('ritual', 'Ritual', ''),
  FacetOption('multi-day', 'Multi-day', ''),
  FacetOption('game', 'Game', ''),
  FacetOption('roleplay', 'Role play', ''),
  FacetOption('adventure', 'Adventure', ''),
  FacetOption('presence', 'Presence', ''),
  FacetOption('storytelling', 'Storytelling', ''),
  FacetOption('movement', 'Movement', ''),
  FacetOption('activity', 'Activity', ''),
  FacetOption('gesture', 'Gesture', ''),
  FacetOption('listening', 'Listening', ''),
  FacetOption('guidance', 'Guidance', ''),
  FacetOption('discovery', 'Discovery', ''),
  FacetOption('sensory', 'Sensory', ''),
  FacetOption('creative project', 'Creative project', ''),
  FacetOption('puzzle', 'Puzzle', ''),
];

class DiscoveryQuery {
  const DiscoveryQuery({
    this.timeBuckets = const {},
    this.outcomes = const {},
    this.energy = const {},
    this.depth = const {},
    this.formats = const {},
    this.excludeIds = const {},
    this.text = '',
    this.partId,
    this.favoriteIds = const {},
    this.favoritesOnly = false,
    this.inProgressIds = const {},
    this.inProgressOnly = false,
  });

  final Set<String> timeBuckets;
  final Set<String> outcomes;
  final Set<String> energy;
  final Set<String> depth;
  final Set<String> formats;
  final Set<String> excludeIds;
  final String text;
  final String? partId;
  final Set<String> favoriteIds;
  final bool favoritesOnly;
  final Set<String> inProgressIds;
  final bool inProgressOnly;

  bool get hasFacet =>
      timeBuckets.isNotEmpty ||
      outcomes.isNotEmpty ||
      energy.isNotEmpty ||
      depth.isNotEmpty ||
      formats.isNotEmpty;
}

class SurpriseResult {
  const SurpriseResult({this.experience, this.emptyReason});
  final Experience? experience;
  final String? emptyReason;
}

List<Experience> eligibleExperiences(ContentPack pack, DiscoveryQuery query) {
  final pool = <Experience>[...pack.experiences, ...pack.signatures.map((item) => item.asExperience())];
  final results = pool.where((experience) {
    if (query.excludeIds.contains(experience.stableId)) {
      return false;
    }
    if (query.partId != null && experience.partId != query.partId) {
      return false;
    }
    if (query.favoritesOnly && !query.favoriteIds.contains(experience.stableId)) {
      return false;
    }
    if (query.inProgressOnly && !query.inProgressIds.contains(experience.stableId)) {
      return false;
    }
    if (!_facet(experience.metadata.timeBuckets, query.timeBuckets)) {
      return false;
    }
    if (!_facet(experience.metadata.outcomes, query.outcomes)) {
      return false;
    }
    if (!_facet(experience.metadata.energy, query.energy)) {
      return false;
    }
    if (!_facet(experience.metadata.depth, query.depth)) {
      return false;
    }
    if (!_facet(experience.metadata.formats, query.formats)) {
      return false;
    }
    return _textMatch(experience, query.text);
  }).toList();
  results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return results;
}

SurpriseResult surpriseUs(ContentPack pack, DiscoveryQuery query, int seed) {
  final matches = eligibleExperiences(pack, query);
  if (matches.isEmpty) {
    return SurpriseResult(emptyReason: emptyDiscoveryReason(pack, query));
  }
  final index = Random(seed).nextInt(matches.length);
  return SurpriseResult(experience: matches[index]);
}

String emptyDiscoveryReason(ContentPack pack, DiscoveryQuery query) {
  if (query.excludeIds.isNotEmpty &&
      eligibleExperiences(pack, DiscoveryQuery(
        timeBuckets: query.timeBuckets,
        outcomes: query.outcomes,
        energy: query.energy,
        depth: query.depth,
        formats: query.formats,
        text: query.text,
        partId: query.partId,
      )).isNotEmpty) {
    return 'The remaining matches were set aside for this roll. Clear the pass list to see them again.';
  }
  if (query.timeBuckets.isNotEmpty &&
      pack.experiences.every((experience) => experience.metadata.timeBuckets.isEmpty)) {
    return 'Nothing matches. This edition has no duration metadata, so a time limit excludes every experience. Clear the time limit, or import an approved book that classifies the sessions.';
  }
  if (query.hasFacet && pack.experiences.every((experience) => _metadataEmpty(experience))) {
    return 'Nothing matches. Filters are not relaxed to fill a result. This inventory has no mood, energy, depth, or format metadata yet.';
  }
  return 'Nothing matches those limits. Change or clear a filter. The chooser will not substitute a different chapter.';
}

bool _facet(List<String> values, Set<String> selected) {
  if (selected.isEmpty) {
    return true;
  }
  if (values.isEmpty) {
    return false;
  }
  return values.any(selected.contains);
}

bool _textMatch(Experience experience, String text) {
  final query = text.trim().toLowerCase();
  if (query.isEmpty) {
    return true;
  }
  final haystack = [
    experience.title,
    experience.stableId,
    experience.numericId?.toString() ?? '',
    ...experience.aliases,
    ...experience.proseBlocks.map((block) => block.text),
  ].join('\n').toLowerCase();
  return haystack.contains(query);
}

bool _metadataEmpty(Experience experience) {
  final metadata = experience.metadata;
  return metadata.timeBuckets.isEmpty &&
      metadata.outcomes.isEmpty &&
      metadata.energy.isEmpty &&
      metadata.depth.isEmpty &&
      metadata.formats.isEmpty;
}
