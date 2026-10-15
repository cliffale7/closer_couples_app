import 'dart:convert';

class ContentPack {
  const ContentPack({
    required this.schemaVersion,
    required this.edition,
    required this.parts,
    required this.experiences,
    required this.signatures,
    required this.frontMatter,
    required this.legacyArchive,
    required this.requiredSignatureIds,
  });

  final String schemaVersion;
  final EditionInfo edition;
  final List<BookPart> parts;
  final List<Experience> experiences;
  final List<SignatureExperience> signatures;
  final List<Experience> frontMatter;
  final List<Experience> legacyArchive;
  final List<String> requiredSignatureIds;

  factory ContentPack.fromJson(Map<String, dynamic> json) {
    return ContentPack(
      schemaVersion: json['content_schema_version']?.toString() ?? '',
      edition: EditionInfo.fromJson(_map(json['edition'])),
      parts: _list(json['parts']).map(BookPart.fromJson).toList(),
      experiences: _list(json['experiences']).map(Experience.fromJson).toList(),
      signatures: _list(json['signatures']).map(SignatureExperience.fromJson).toList(),
      frontMatter: _list(json['front_matter']).map(Experience.fromJson).toList(),
      legacyArchive: _list(json['legacy_archive']).map(Experience.fromJson).toList(),
      requiredSignatureIds: _strings(json['required_signature_ids']),
    );
  }

  Experience? find(String stableId) {
    for (final experience in [...experiences, ...frontMatter, ...legacyArchive]) {
      if (experience.stableId == stableId) {
        return experience;
      }
    }
    for (final signature in signatures) {
      if (signature.stableId == stableId) {
        return signature.asExperience();
      }
    }
    return null;
  }

  String partName(String? partId) {
    for (final part in parts) {
      if (part.stableId == partId) {
        return part.name;
      }
    }
    return 'Unassigned';
  }

  bool get isFinishedBook =>
      edition.approvalState == 'owner_approved' && edition.completeness == 'full_chapters';
}

class EditionInfo {
  const EditionInfo({
    required this.editionId,
    required this.version,
    required this.approvalState,
    required this.completeness,
    required this.provenance,
    required this.checksum,
    this.coverAsset,
    this.backCoverAsset,
  });

  final String editionId;
  final String version;
  final String approvalState;
  final String completeness;
  final String provenance;
  final String checksum;
  final String? coverAsset;
  final String? backCoverAsset;

  factory EditionInfo.fromJson(Map<String, dynamic> json) {
    return EditionInfo(
      editionId: json['edition_id']?.toString() ?? 'unknown',
      version: json['version']?.toString() ?? '',
      approvalState: json['approval_state']?.toString() ?? 'unknown',
      completeness: json['completeness']?.toString() ?? 'unknown',
      provenance: json['provenance']?.toString() ?? '',
      checksum: json['checksum']?.toString() ?? '',
      coverAsset: json['cover_asset']?.toString(),
      backCoverAsset: json['back_cover_asset']?.toString(),
    );
  }
}

class BookPart {
  const BookPart({
    required this.stableId,
    required this.ordinal,
    required this.name,
    required this.intro,
    required this.experienceIds,
    this.artAsset,
  });

  final String stableId;
  final int ordinal;
  final String name;
  final String? intro;
  final List<String> experienceIds;
  final String? artAsset;

  factory BookPart.fromJson(Map<String, dynamic> json) {
    return BookPart(
      stableId: json['stable_id']?.toString() ?? '',
      ordinal: json['ordinal'] is int ? json['ordinal'] as int : int.tryParse('${json['ordinal']}') ?? 0,
      name: json['name']?.toString() ?? '',
      intro: json['intro']?.toString(),
      experienceIds: _strings(json['experience_ids']),
      artAsset: json['art_asset']?.toString(),
    );
  }
}

class Experience {
  const Experience({
    required this.stableId,
    required this.numericId,
    required this.title,
    required this.aliases,
    required this.partId,
    required this.provenance,
    required this.proseBlocks,
    required this.metadata,
    required this.interactionDefinition,
    required this.interactionVersion,
    required this.sourceGaps,
    required this.archiveReason,
    this.artAsset,
  });

  final String stableId;
  final int? numericId;
  final String title;
  final List<String> aliases;
  final String? partId;
  final String provenance;
  final List<ProseBlock> proseBlocks;
  final ExperienceMetadata metadata;
  final Map<String, dynamic>? interactionDefinition;
  final String? interactionVersion;
  final List<String> sourceGaps;
  final String? archiveReason;
  final String? artAsset;

  bool get hasFullChapter =>
      !sourceGaps.contains('full_chapter') &&
      proseBlocks.any(
        (block) => block.kind != 'deck' && block.kind != 'design_brief' && block.kind != 'source_premise' && block.text.trim().isNotEmpty,
      );

  String get premise {
    for (final block in proseBlocks) {
      if (block.kind == 'deck' || block.kind == 'source_premise') {
        return block.text;
      }
    }
    return '';
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    final interaction = json['interaction_definition'];
    return Experience(
      stableId: json['stable_id']?.toString() ?? '',
      numericId: json['numeric_id'] is int ? json['numeric_id'] as int : int.tryParse('${json['numeric_id']}'),
      title: json['title']?.toString() ?? '',
      aliases: _strings(json['aliases']),
      partId: json['part_id']?.toString(),
      provenance: json['provenance']?.toString() ?? '',
      proseBlocks: _list(json['prose_blocks']).map(ProseBlock.fromJson).toList(),
      metadata: ExperienceMetadata.fromJson(_map(json['metadata'])),
      interactionDefinition: interaction is Map ? _map(interaction) : null,
      interactionVersion: json['interaction_version']?.toString(),
      sourceGaps: _strings(json['source_gaps']),
      archiveReason: json['archive_reason']?.toString(),
      artAsset: json['art_asset']?.toString(),
    );
  }
}

class ProseBlock {
  const ProseBlock({
    required this.blockId,
    required this.kind,
    required this.text,
    required this.origin,
    this.heading,
  });

  final String blockId;
  final String kind;
  final String text;
  final String origin;
  final String? heading;

  factory ProseBlock.fromJson(Map<String, dynamic> json) {
    return ProseBlock(
      blockId: json['block_id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'text',
      text: json['text']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      heading: json['heading']?.toString(),
    );
  }
}

class ExperienceMetadata {
  const ExperienceMetadata({
    required this.timeBuckets,
    required this.outcomes,
    required this.energy,
    required this.depth,
    required this.formats,
    this.materials = const [],
    this.durationSummary = '',
  });

  final List<String> timeBuckets;
  final List<String> outcomes;
  final List<String> energy;
  final List<String> depth;
  final List<String> formats;
  final List<String> materials;
  final String durationSummary;

  factory ExperienceMetadata.fromJson(Map<String, dynamic> json) {
    return ExperienceMetadata(
      timeBuckets: _strings(json['time_buckets']),
      outcomes: _strings(json['outcomes']),
      energy: _strings(json['energy']),
      depth: _strings(json['depth']),
      formats: _strings(json['formats']),
      materials: _strings(json['materials_required']),
      durationSummary: json['duration_summary']?.toString() ?? '',
    );
  }
}

class SignatureExperience {
  const SignatureExperience({required this.stableId, required this.title, required this.experience});

  final String stableId;
  final String title;
  final Experience experience;

  Experience asExperience() => experience;

  factory SignatureExperience.fromJson(Map<String, dynamic> json) {
    final experience = Experience.fromJson(json);
    return SignatureExperience(
      stableId: experience.stableId,
      title: experience.title,
      experience: experience,
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const {};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_map).toList();
}

List<String> _strings(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map((item) => item.toString()).toList();
}

ContentPack contentPackFromJsonString(String source) {
  return ContentPack.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
