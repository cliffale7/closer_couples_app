import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:closer_project/domain/chapter_session.dart';
import 'package:closer_project/domain/content_pack.dart';

void main() {
  test('a chapter session follows the book sections and story pages', () {
    final experience = Experience.fromJson({
      'stable_id': '001',
      'numeric_id': 1,
      'title': 'The Stranger Across From Me',
      'prose_blocks': [
        {'block_id': 'deck', 'kind': 'deck', 'heading': 'In short', 'text': 'Interview the person you know.'},
        {'block_id': 'play', 'kind': 'section', 'heading': 'The experience', 'text': 'Ask one question.'},
        {
          'block_id': 'story',
          'kind': 'section',
          'heading': 'Our Story',
          'text': '''
Write the date.

```journal
session: date, place, done or paused
partner_a:
- The question I asked
partner_b:
- The pass I used
shared:
- What actually happened
revisit:
- What changed
```
''',
        },
      ],
      'metadata': {
        'time_buckets': ['20-45'],
        'duration_summary': 'Short 10 minutes · Standard 30 minutes',
        'materials_required': ['two seats'],
      },
      'source_gaps': [],
    });

    final session = chapterSession(experience);
    expect(session.notice, contains('Private pages'));
    expect(session.steps.first.text, contains('Standard 30 minutes'));
    expect(session.steps.map((step) => step.heading), contains('The experience'));
    final privateA = session.steps.firstWhere((step) => step.promptId == '001-partner_a-1');
    expect(privateA.scope, 'private');
    expect(privateA.role, 'partner_a');
    expect(privateA.text, 'The question I asked');
    expect(session.steps.firstWhere((step) => step.promptId == '001-shared-1').scope, 'shared');
    expect(session.steps.firstWhere((step) => step.promptId == '001-revisit-1').heading, 'Revisit');
  });

  test('chapter 001 in the draft uses the book prompts', () {
    final pack = contentPackFromJsonString(File('content/canonical/v1-draft/content_pack.json').readAsStringSync());
    final session = chapterSession(pack.find('001')!);
    expect(session.steps.where((step) => step.heading == 'The experience'), isNotEmpty);
    expect(session.steps.where((step) => step.promptId == '001-partner_a-1'), isNotEmpty);
    expect(session.steps.where((step) => step.role == 'partner_b'), isNotEmpty);
    final signature = chapterSession(pack.find('S01')!.hasFullChapter ? pack.find('S01')! : pack.find('001')!);
    expect(signature.steps.length, greaterThan(3));
  });
}
