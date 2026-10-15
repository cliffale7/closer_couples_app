import 'package:closer_project/domain/content_pack.dart';

Map<String, dynamic> samplePackJson() {
  return {
    'content_schema_version': '1.0.0',
    'edition': {
      'edition_id': 'test-edition',
      'version': '0',
      'approval_state': 'baseline_inventory_only',
      'completeness': 'inventory_not_full_chapters',
      'provenance': 'fixture',
      'checksum': 'abc',
    },
    'parts': [
      {
        'stable_id': 'part-01',
        'ordinal': 1,
        'name': 'Knowing',
        'intro': null,
        'experience_ids': ['001', '017', '100'],
      },
    ],
    'experiences': [
      _experience(
        id: '001',
        number: 1,
        title: 'The Stranger Across From Me',
        text: 'Interview one another as fascinating strangers.',
      ),
      _experience(
        id: '017',
        number: 17,
        title: 'Four Minutes of Forever',
        text: 'A quiet span of attention.',
      ),
      _experience(
        id: '100',
        number: 100,
        title: 'The Emotional Weather Report',
        text: 'Forecast the inner weather.',
        metadata: {
          'time_buckets': ['5-10'],
          'outcomes': ['laugh'],
          'energy': ['low'],
          'depth': ['light'],
          'formats': ['ritual'],
        },
      ),
    ],
    'signatures': [],
    'legacy_archive': [],
    'required_signature_ids': ['S01', 'S02', 'S03', 'S04', 'S05', 'S06'],
  };
}

ContentPack samplePack() => ContentPack.fromJson(samplePackJson());

Map<String, dynamic> _experience({
  required String id,
  required int number,
  required String title,
  required String text,
  Map<String, dynamic>? metadata,
}) {
  return {
    'stable_id': id,
    'numeric_id': number,
    'title': title,
    'aliases': <String>[],
    'part_id': 'part-01',
    'provenance': 'fixture',
    'prose_blocks': [
      {'block_id': '$id-premise', 'kind': 'source_premise', 'text': text, 'origin': 'fixture'},
    ],
    'metadata': metadata ?? <String, dynamic>{},
    'interaction_definition': null,
    'source_gaps': ['full_chapter'],
  };
}
