import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/private/journal_repository.dart';
import '../../domain/content_pack.dart';
import '../../domain/session_engine.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.definition, this.experience});

  final InteractionDefinition definition;
  final Experience? experience;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SessionEngine _engine = SessionEngine(widget.definition);
  final _answer = TextEditingController();
  String? _sessionId;
  var _sessionReady = false;
  var _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.experience != null && !_sessionReady) {
      _sessionReady = true;
      _openSession();
    }
  }

  Future<void> _openSession() async {
    final experience = widget.experience;
    if (experience == null) {
      return;
    }
    final app = AppScope.of(context);
    final session = await app.journal.ensureOpenSession(
      experienceId: experience.stableId,
      contentEditionId: app.pack.edition.editionId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _sessionId = session.id);
    await _loadDraft();
  }

  Future<void> _newVisit() async {
    final experience = widget.experience;
    if (experience == null) {
      return;
    }
    await _persistCurrent();
    if (!mounted) {
      return;
    }
    final app = AppScope.of(context);
    final session = await app.journal.startNewVisit(
      experienceId: experience.stableId,
      contentEditionId: app.pack.edition.editionId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionId = session.id;
      _answer.clear();
    });
  }

  Future<void> _loadDraft() async {
    final step = _engine.current;
    final sessionId = _sessionId;
    if (sessionId == null || step.promptId == null || step.scope == null) {
      return;
    }
    final owner = _ownerFor(step);
    if (step.scope == 'private' && owner == null) {
      return;
    }
    final entry = await AppScope.of(context).journal.draft(
      sessionId: sessionId,
      scope: step.scope!,
      ownerProfileId: owner?.id,
      promptId: step.promptId,
    );
    if (!mounted || entry == null) {
      return;
    }
    _answer.text = entry.body;
  }

  Future<void> _persistCurrent() async {
    final step = _engine.current;
    final sessionId = _sessionId;
    final experience = widget.experience;
    if (experience == null || sessionId == null || step.promptId == null || step.scope == null) {
      return;
    }
    final body = _answer.text;
    final owner = _ownerFor(step);
    final app = AppScope.of(context);
    final author = step.scope == 'shared' ? app.activeProfile : owner;
    if (author == null || (step.scope == 'private' && owner == null)) {
      return;
    }
    if (body.trim().isEmpty) {
      final existing = await app.journal.draft(
        sessionId: sessionId,
        scope: step.scope!,
        ownerProfileId: owner?.id,
        promptId: step.promptId,
      );
      if (existing == null || existing.body.isEmpty) {
        return;
      }
    }
    _saving = true;
    try {
      await app.journal.saveEntry(
        sessionId: sessionId,
        scope: step.scope!,
        authorProfileId: author.id,
        ownerProfileId: step.scope == 'private' ? owner!.id : null,
        body: body,
        promptId: step.promptId,
        promptRevision: step.promptRevision,
      );
    } finally {
      _saving = false;
    }
  }

  Profile? _ownerFor(InteractionStep step) {
    final app = AppScope.of(context);
    final slot = step.role;
    if (slot == null) {
      return app.activeProfile;
    }
    for (final profile in app.profiles) {
      if (profile.slot == slot) {
        return profile;
      }
    }
    return null;
  }

  Future<void> _stop() async {
    await _persistCurrent();
    if (!mounted) {
      return;
    }
    setState(_engine.stop);
    Navigator.of(context).maybePop();
  }

  Future<void> _finish() async {
    _rememberAnswer();
    await _persistCurrent();
    if (!mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _move(void Function() action) async {
    _rememberAnswer();
    await _persistCurrent();
    if (!mounted) {
      return;
    }
    setState(() {
      action();
      _answer.clear();
    });
    await _loadDraft();
  }

  void _rememberAnswer() {
    final step = _engine.current;
    if (step.type == 'answer_private' && _answer.text.trim().isNotEmpty) {
      _engine.answer(step.role ?? step.id, _answer.text.trim());
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _engine.current;
    final writing = step.type == 'answer_private' || step.type == 'answer_shared';
    final waitingForVisit = widget.experience != null && _sessionId == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.definition.title),
        actions: [
          if (widget.experience != null)
            TextButton(
              onPressed: _saving || waitingForVisit ? null : _newVisit,
              child: const Text('New visit'),
            ),
          TextButton(
            onPressed: _stop,
            child: const Text('Stop'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          if (widget.definition.notice.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(widget.definition.notice),
            ),
          Text('Step ${_engine.index + 1} of ${widget.definition.steps.length}'),
          if (waitingForVisit) ...[
            const SizedBox(height: 12),
            Text('Opening this visit', style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 12),
          Text(step.heading ?? _fallbackHeading(step), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SelectableText(step.text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          if (writing)
            TextField(
              controller: _answer,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: step.scope == 'private' ? 'Private note' : 'Shared note',
                alignLabelWithHint: true,
              ),
            ),
          if (step.type == 'reveal') ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Partner A agrees to reveal'),
              value: _engine.consentA,
              onChanged: (value) => setState(() => _engine.consentA = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Partner B agrees to reveal'),
              value: _engine.consentB,
              onChanged: (value) => setState(() => _engine.consentB = value),
            ),
            const SizedBox(height: 8),
            Text(_engine.canReveal ? 'Both agreed.' : 'Hidden until both agree. A maybe is not consent to reveal.'),
            if (_engine.canReveal)
              for (final entry in _engine.privateAnswers.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
          ],
          if (step.type == 'timer') ...[
            Text(step.eyesOffPhone ? 'Put the phone down. The words will wait.' : 'Timer'),
            const SizedBox(height: 8),
            Text(step.seconds == null ? 'No duration set.' : '${step.seconds} seconds, only if you want them.'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => setState(() => _engine.timerAcknowledged = true),
              child: Text(_engine.timerAcknowledged ? 'You came back' : 'We are back'),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _engine.paused ? () => setState(_engine.resume) : () => setState(_engine.pause),
                  child: Text(_engine.paused ? 'Resume' : 'Pause'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _engine.paused || _engine.isLast || waitingForVisit ? null : () => _move(_engine.pass),
                  child: const Text('Pass'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _engine.paused || waitingForVisit
                      ? null
                      : () {
                          if (_engine.isLast) {
                            _finish();
                            return;
                          }
                          _move(_engine.next);
                        },
                  child: Text(_engine.isLast ? 'Done' : 'Next'),
                ),
              ),
            ],
          ),
          if (_engine.paused)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Paused. Nothing advances until you resume.'),
            ),
        ],
      ),
    );
  }

  String _fallbackHeading(InteractionStep step) {
    switch (step.type) {
      case 'prepare':
        return 'Before you start';
      case 'answer_private':
        return 'Private page';
      case 'answer_shared':
        return 'Shared page';
      default:
        return 'Chapter';
    }
  }
}
