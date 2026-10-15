import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:closer_project/data/private/journal_repository.dart';
import 'package:closer_project/features/journal/journal_draft.dart';

import 'support/sample_pack.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // The FFI isolate deadlocks the Windows widget tester once a frame is drawn.
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  test('private notes stay with their owner and revisits do not overwrite', () async {
    var tick = 0;
    final journal = await JournalRepository.openMemory(
      clock: () => DateTime.utc(2026, 1, 1, 0, tick++),
      ids: _ids(),
    );
    final profiles = await journal.profiles();
    final partnerA = profiles.firstWhere((profile) => profile.slot == 'partner_a');
    final partnerB = profiles.firstWhere((profile) => profile.slot == 'partner_b');
    final first = await journal.ensureOpenSession(
      experienceId: '034',
      contentEditionId: 'edition-1',
    );
    final saved = await journal.saveEntry(
      sessionId: first.id,
      scope: 'private',
      authorProfileId: partnerA.id,
      ownerProfileId: partnerA.id,
      promptId: '034-boundary',
      promptRevision: 1,
      body: 'fictional no',
    );
    await journal.saveEntry(
      sessionId: first.id,
      scope: 'shared',
      authorProfileId: partnerA.id,
      body: 'a shared sentence',
    );
    final second = await journal.startNewVisit(
      experienceId: '034',
      contentEditionId: 'edition-1.1',
    );
    expect(second.id, isNot(first.id));
    final visits = await journal.inProgressSessions();
    expect(visits.where((session) => session.experienceStableId == '034').length, 1);

    await journal.saveEntry(
      sessionId: second.id,
      scope: 'private',
      authorProfileId: partnerA.id,
      ownerProfileId: partnerA.id,
      promptId: '034-boundary',
      promptRevision: 1,
      body: 'still fictional no',
    );
    final visibleToA = await journal.entriesVisibleTo(partnerA.id);
    final visibleToB = await journal.entriesVisibleTo(partnerB.id);
    expect(visibleToA.map((entry) => entry.body), containsAll(['fictional no', 'still fictional no', 'a shared sentence']));
    expect(visibleToB.map((entry) => entry.body), ['a shared sentence']);
    expect(visibleToA.firstWhere((entry) => entry.id == saved.id).promptRevision, 1);
    expect(visibleToA.firstWhere((entry) => entry.id == saved.id).contentEditionId, 'edition-1');

    final edited = await journal.saveEntry(
      sessionId: first.id,
      scope: 'private',
      authorProfileId: partnerA.id,
      ownerProfileId: partnerA.id,
      promptId: '034-boundary',
      promptRevision: 1,
      body: 'fictional no, revised',
    );
    expect(await journal.revisionsFor(edited.id), [1, 2]);
    expect(edited.promptRevision, 1);
    await expectLater(
      journal.saveEntry(
        sessionId: first.id,
        scope: 'private',
        authorProfileId: partnerA.id,
        body: 'missing owner',
      ),
      throwsArgumentError,
    );
  });

  test('switching profiles and scopes does not copy a private draft', () async {
    final journal = await JournalRepository.openMemory(ids: _ids());
    final profiles = await journal.profiles();
    final partnerA = profiles.firstWhere((profile) => profile.slot == 'partner_a');
    final partnerB = profiles.firstWhere((profile) => profile.slot == 'partner_b');
    final draft = JournalDraft(
      journal: journal,
      experience: samplePack().find('001')!,
      contentEditionId: 'test-edition',
    );
    await draft.bind(partnerA.id);
    draft.body = 'only A wrote this';
    await draft.persist();
    await draft.bind(partnerB.id);
    expect(draft.body, isEmpty);
    await draft.bind(partnerA.id);
    expect(draft.body, 'only A wrote this');
    await draft.setScope('shared');
    expect(draft.body, isEmpty);
    expect(draft.scope, 'shared');
    final bPrivate = await journal.entriesVisibleTo(partnerB.id);
    expect(bPrivate.map((entry) => entry.body), isNot(contains('only A wrote this')));
  });

  test('an export restores a private note onto the same profile slot', () async {
    var sourceCount = 0;
    final source = await JournalRepository.openMemory(
      ids: () => 'source-${sourceCount++}',
      singleInstance: false,
    );
    final sourceProfiles = await source.profiles();
    final sourceA = sourceProfiles.firstWhere((profile) => profile.slot == 'partner_a');
    final sourceB = sourceProfiles.firstWhere((profile) => profile.slot == 'partner_b');
    final session = await source.ensureOpenSession(experienceId: '001', contentEditionId: 'v1-draft');
    await source.saveEntry(
      sessionId: session.id,
      scope: 'private',
      authorProfileId: sourceA.id,
      ownerProfileId: sourceA.id,
      promptId: '001-partner_a-1',
      promptRevision: 1,
      body: 'secret from A',
    );
    final encoded = jsonDecode(jsonEncode(await source.exportArchive()));
    final archive = (encoded as Map).map((key, value) => MapEntry(key.toString(), value));

    var targetCount = 0;
    final target = await JournalRepository.openMemory(
      ids: () => 'target-${targetCount++}',
      singleInstance: false,
    );
    final restored = await target.restoreArchive(archive);
    expect(restored.entriesAdded, 1);
    final targetProfiles = await target.profiles();
    final targetA = targetProfiles.firstWhere((profile) => profile.slot == 'partner_a');
    final targetB = targetProfiles.firstWhere((profile) => profile.slot == 'partner_b');
    expect((await target.entriesVisibleTo(targetA.id)).map((entry) => entry.body), contains('secret from A'));
    expect((await target.entriesVisibleTo(targetB.id)).map((entry) => entry.body), isNot(contains('secret from A')));
    expect(targetA.id, isNot(sourceA.id));
    expect(sourceB.id, isNot(targetB.id));

    final again = await target.restoreArchive(archive);
    expect(again.entriesAdded, 0);
    expect((await target.entriesVisibleTo(targetA.id)).length, 1);
  });
}

String Function() _ids() {
  var count = 0;
  return () => 'id-${count++}';
}
