import 'package:flutter_test/flutter_test.dart';

import 'package:closer_project/domain/session_engine.dart';

void main() {
  test('private answers stay hidden until both people opt in', () {
    final engine = SessionEngine(InteractionDefinition.fromJson(sessionEnginePreview));
    expect(engine.current.type, 'prepare');
    engine.next();
    engine.answer(engine.current.id, 'a secret');
    engine.next();
    engine.answer(engine.current.id, 'another secret');
    engine.next();
    expect(engine.current.type, 'reveal');
    expect(engine.revealedAnswer('answer-a'), isNull);
    engine.consentA = true;
    expect(engine.canReveal, isFalse);
    engine.consentB = true;
    expect(engine.revealedAnswer('answer-a'), 'a secret');
    expect(engine.revealedAnswer('answer-b'), 'another secret');
  });

  test('pause and pass do not skip ahead while paused', () {
    final engine = SessionEngine(InteractionDefinition.fromJson(sessionEnginePreview));
    engine.pause();
    engine.next();
    engine.pass();
    expect(engine.index, 0);
    expect(engine.paused, isTrue);
    engine.resume();
    engine.pass();
    expect(engine.index, 1);
  });

  test('the preview is labeled as a fixture', () {
    final definition = InteractionDefinition.fromJson(sessionEnginePreview);
    expect(definition.notice, contains('not a chapter'));
    expect(definition.steps.map((step) => step.type), containsAll(['timer', 'debrief', 'reveal']));
    expect(definition.steps.firstWhere((step) => step.type == 'timer').eyesOffPhone, isTrue);
  });
}
