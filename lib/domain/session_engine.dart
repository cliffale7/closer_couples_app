class InteractionDefinition {
  const InteractionDefinition({
    required this.id,
    required this.title,
    required this.notice,
    required this.steps,
  });

  final String id;
  final String title;
  final String notice;
  final List<InteractionStep> steps;

  factory InteractionDefinition.fromJson(Map json) {
    final rawSteps = json['steps'];
    final steps = rawSteps is List
        ? rawSteps.whereType<Map>().map((step) => InteractionStep.fromJson(step)).toList()
        : <InteractionStep>[];
    return InteractionDefinition(
      id: json['id']?.toString() ?? 'session',
      title: json['title']?.toString() ?? 'Session',
      notice: json['notice']?.toString() ?? '',
      steps: steps,
    );
  }
}

class InteractionStep {
  const InteractionStep({
    required this.id,
    required this.type,
    required this.text,
    this.heading,
    this.seconds,
    this.eyesOffPhone = false,
    this.role,
    this.promptId,
    this.promptRevision,
    this.scope,
  });

  final String id;
  final String type;
  final String text;
  final String? heading;
  final int? seconds;
  final bool eyesOffPhone;
  final String? role;
  final String? promptId;
  final int? promptRevision;
  final String? scope;

  factory InteractionStep.fromJson(Map json) {
    return InteractionStep(
      id: json['id']?.toString() ?? json['type']?.toString() ?? 'step',
      type: json['type']?.toString() ?? 'read',
      text: json['text']?.toString() ?? '',
      heading: json['heading']?.toString(),
      seconds: json['seconds'] is int ? json['seconds'] as int : int.tryParse('${json['seconds']}'),
      eyesOffPhone: json['eyes_off_phone'] == true,
      role: json['role']?.toString(),
      promptId: json['prompt_id']?.toString(),
      promptRevision: json['prompt_revision'] is int ? json['prompt_revision'] as int : int.tryParse('${json['prompt_revision']}'),
      scope: json['scope']?.toString(),
    );
  }
}

/// Development fixture for the session runner. Not a book chapter.
const sessionEnginePreview = <String, Object>{
  'id': 'engine-preview',
  'title': 'Session engine preview',
  'notice': 'Development fixture. This is not a chapter from the book.',
  'steps': [
    {
      'id': 'prepare',
      'type': 'prepare',
      'text': 'Agree that either person can pass any step.',
    },
    {
      'id': 'answer-a',
      'type': 'answer_private',
      'role': 'partner_a',
      'text': 'Partner A writes a private answer.',
    },
    {
      'id': 'answer-b',
      'type': 'answer_private',
      'role': 'partner_b',
      'text': 'Partner B writes a private answer.',
    },
    {
      'id': 'reveal',
      'type': 'reveal',
      'text': 'Show the private answers only after both people opt in.',
    },
    {
      'id': 'timer',
      'type': 'timer',
      'seconds': 4,
      'eyes_off_phone': true,
      'text': 'Optional short timer. Put the phone down.',
    },
    {
      'id': 'debrief',
      'type': 'debrief',
      'text': 'What, if anything, do you want to remember?',
    },
  ],
};

class SessionEngine {
  SessionEngine(this.definition);

  final InteractionDefinition definition;
  int index = 0;
  bool paused = false;
  bool stopped = false;
  bool timerAcknowledged = false;
  final Map<String, String> privateAnswers = {};
  bool consentA = false;
  bool consentB = false;

  InteractionStep get current => definition.steps[index];
  bool get isLast => index >= definition.steps.length - 1;
  bool get canReveal => consentA && consentB;

  void next() {
    if (paused || stopped || isLast) {
      return;
    }
    index += 1;
    timerAcknowledged = false;
  }

  void pass() => next();

  void pause() => paused = true;

  void resume() => paused = false;

  void stop() => stopped = true;

  void answer(String stepId, String value) {
    privateAnswers[stepId] = value;
  }

  String? revealedAnswer(String stepId) {
    if (!canReveal) {
      return null;
    }
    return privateAnswers[stepId];
  }
}
