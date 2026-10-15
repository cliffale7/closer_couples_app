import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:closer_project/app/app_controller.dart';
import 'package:closer_project/app/closer_app.dart';
import 'package:closer_project/data/private/journal_repository.dart';

import 'support/sample_pack.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // The FFI background isolate deadlocks flutter_tester on Windows after a frame.
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  testWidgets('onboarding, surprise, and private timeline stay honest', (tester) async {
    tester.view.physicalSize = const Size(900, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final journal = await JournalRepository.openMemory(ids: _ids());
    final controller = AppController(pack: samplePack(), journal: journal);
    await controller.restore();
    await tester.pumpWidget(CloserApp(controller: controller));
    expect(find.text('The Closer Project'), findsOneWidget);

    await tester.tap(find.text('Skip names for now'));
    await _until(tester, find.text('Surprise us'));

    final longSession = find.textContaining('90 min–3 hours');
    await tester.tap(longSession);
    await tester.pump();
    await tester.tap(find.text('Surprise us'));
    await tester.pump();
    expect(find.textContaining('will not substitute'), findsOneWidget);
    expect(find.text('The Emotional Weather Report'), findsNothing);

    await tester.tap(longSession);
    await tester.pump();
    await tester.tap(find.textContaining('5–10 min'));
    await tester.pump();
    await tester.tap(find.text('Surprise us'));
    await tester.pump();
    expect(find.text('The Emotional Weather Report'), findsWidgets);

    final partnerA = controller.profiles.firstWhere((profile) => profile.slot == 'partner_a');
    final session = await journal.ensureOpenSession(
      experienceId: '001',
      contentEditionId: controller.pack.edition.editionId,
    );
    await journal.saveEntry(
      sessionId: session.id,
      scope: 'private',
      authorProfileId: partnerA.id,
      ownerProfileId: partnerA.id,
      body: 'secret from A',
    );

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await _until(tester, find.textContaining('secret from A'));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Partner B'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _until(tester, find.textContaining('actually write'));
    expect(find.textContaining('secret from A'), findsNothing);
  });
}

Future<void> _until(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Did not find $finder');
}

String Function() _ids() {
  var count = 0;
  return () => 'widget-id-${count++}';
}
