import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:closer_project/domain/content_pack.dart';
import 'package:closer_project/domain/discovery.dart';

void main() {
  test('baseline pack is the 108-id inventory and not a finished book', () {
    final file = File('content/canonical/baseline-v0.1/content_pack.json');
    expect(file.existsSync(), isTrue);
    final pack = contentPackFromJsonString(file.readAsStringSync());
    expect(pack.experiences, hasLength(108));
    expect(pack.parts, hasLength(13));
    expect(pack.signatures, isEmpty);
    expect(pack.edition.approvalState, 'baseline_inventory_only');
    expect(pack.isFinishedBook, isFalse);
    expect(pack.experiences.map((experience) => experience.stableId).toSet(), hasLength(108));
    expect(pack.experiences.every((experience) => experience.sourceGaps.contains('full_chapter')), isTrue);
    expect(pack.find('097')!.proseBlocks.any((block) => block.kind == 'design_brief'), isTrue);
    expect(pack.find('001')!.title, 'The Stranger Across From Me');

    final timed = eligibleExperiences(pack, const DiscoveryQuery(timeBuckets: {'5-10'}));
    expect(timed, isEmpty);
    expect(
      emptyDiscoveryReason(pack, const DiscoveryQuery(timeBuckets: {'5-10'})),
      contains('no duration'),
    );
  });
}
