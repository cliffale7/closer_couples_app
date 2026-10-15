import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:closer_project/domain/content_pack.dart';
import 'package:closer_project/domain/discovery.dart';

void main() {
  test('v1 draft pack has the copyedited chapters and stays unapproved', () {
    final packFile = File('content/canonical/v1-draft/content_pack.json');
    final pointer = File('content/active/active_edition.json');
    expect(packFile.existsSync(), isTrue);
    final pack = contentPackFromJsonString(packFile.readAsStringSync());
    expect(pack.edition.editionId, 'v1-draft');
    expect(pack.edition.approvalState, 'draft');
    expect(pack.edition.completeness, 'copyedited_draft');
    expect(pack.isFinishedBook, isFalse);
    expect(pack.experiences, hasLength(108));
    expect(pack.signatures, hasLength(6));
    expect(pack.frontMatter, isNotEmpty);
    expect(pack.parts.every((part) => (part.intro ?? '').trim().isNotEmpty), isTrue);

    final stranger = pack.find('001')!;
    expect(stranger.hasFullChapter, isTrue);
    expect(stranger.premise, contains('Interview'));
    expect(stranger.proseBlocks.any((block) => block.heading == 'The hook'), isTrue);
    expect(stranger.metadata.timeBuckets, ['20-45']);
    expect(stranger.artAsset, 'content/canonical/v1-draft/art/001.svg');
    expect(File(stranger.artAsset!).existsSync(), isTrue);

    final signature = pack.find('S01')!;
    expect(signature.title, 'The Long Table');
    expect(signature.hasFullChapter, isTrue);
    expect(File(signature.artAsset!).existsSync(), isTrue);

    final quick = eligibleExperiences(pack, const DiscoveryQuery(timeBuckets: {'5-10'}));
    expect(quick, isNotEmpty);
    expect(quick.every((experience) => experience.metadata.timeBuckets.contains('5-10')), isTrue);

    final active = pointer.readAsStringSync();
    expect(active, contains('BLOCKED_PENDING_APPROVED_BOOK'));
    expect(active, contains(pack.edition.checksum));
  });
}
