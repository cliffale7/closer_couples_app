import 'package:flutter_test/flutter_test.dart';

import 'package:closer_project/domain/content_pack.dart';
import 'package:closer_project/domain/discovery.dart';

import 'support/sample_pack.dart';

void main() {
  test('time filter excludes unclassified experiences and stays deterministic', () {
    final pack = samplePack();
    final quick = eligibleExperiences(pack, const DiscoveryQuery(timeBuckets: {'5-10'}));
    expect(quick.map((experience) => experience.stableId), ['100']);

    final none = surpriseUs(pack, const DiscoveryQuery(timeBuckets: {'90-180'}), 1);
    expect(none.experience, isNull);
    expect(none.emptyReason, contains('will not substitute'));

    final first = surpriseUs(pack, const DiscoveryQuery(timeBuckets: {'5-10'}), 4);
    final second = surpriseUs(pack, const DiscoveryQuery(timeBuckets: {'5-10'}), 4);
    expect(first.experience!.stableId, second.experience!.stableId);

    final passed = surpriseUs(
      pack,
      const DiscoveryQuery(timeBuckets: {'5-10'}, excludeIds: {'100'}),
      4,
    );
    expect(passed.experience, isNull);
    expect(passed.emptyReason, contains('set aside'));
  });

  test('search matches an id and an alias without ignoring other filters', () {
    final pack = samplePack();
    final byNumber = eligibleExperiences(pack, const DiscoveryQuery(text: '17'));
    expect(byNumber.map((experience) => experience.stableId), ['017']);

    final crossed = eligibleExperiences(
      pack,
      const DiscoveryQuery(timeBuckets: {'5-10'}, outcomes: {'trust'}),
    );
    expect(crossed, isEmpty);
  });

  test('a renamed id is still found through its alias and archive', () {
    final pack = ContentPack.fromJson({
      ...samplePackJson(),
      'experiences': [
        {
          'stable_id': '027',
          'numeric_id': 27,
          'title': 'The Moment We Knew',
          'aliases': ['The Moment I Knew'],
          'part_id': 'part-01',
          'prose_blocks': [
            {'block_id': 'b', 'kind': 'full_chapter', 'text': 'Edited paragraph.', 'origin': 'fixture'},
          ],
          'metadata': {'time_buckets': ['20-45']},
          'source_gaps': <String>[],
        },
      ],
      'legacy_archive': [
        {
          'stable_id': '050',
          'numeric_id': 50,
          'title': 'Archived chapter',
          'part_id': 'part-01',
          'archive_reason': 'removed_or_deprecated',
          'prose_blocks': [
            {'block_id': 'b', 'kind': 'full_chapter', 'text': 'Kept for old notes.', 'origin': 'fixture'},
          ],
          'source_gaps': <String>[],
        },
      ],
    });
    expect(eligibleExperiences(pack, const DiscoveryQuery(text: 'Moment I Knew')).single.stableId, '027');
    expect(eligibleExperiences(pack, const DiscoveryQuery()).map((item) => item.stableId), isNot(contains('050')));
    expect(pack.find('050')!.title, 'Archived chapter');
    expect(pack.find('027')!.hasFullChapter, isTrue);
  });
}
