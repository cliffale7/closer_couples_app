import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/content_pack.dart';
import 'journal_draft.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key, required this.experience});

  final Experience experience;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _text = TextEditingController();
  JournalDraft? _draft;
  Timer? _debounce;
  var _ready = false;
  var _applying = false;
  var _rebinding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    final profile = app.activeProfile;
    if (profile == null) {
      return;
    }
    _draft ??= JournalDraft(
      journal: app.journal,
      experience: widget.experience,
      contentEditionId: app.pack.edition.editionId,
    );
    if (_draft!.boundProfileId != profile.id) {
      _rebind(profile.id);
    }
  }

  Future<void> _rebind(String profileId) async {
    final draft = _draft;
    if (draft == null || _rebinding) {
      return;
    }
    _rebinding = true;
    try {
      await draft.bind(profileId);
      if (!mounted) {
        return;
      }
      _applyText(draft.body);
      setState(() => _ready = true);
    } finally {
      _rebinding = false;
    }
  }

  void _applyText(String value) {
    _applying = true;
    _text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _applying = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final draft = _draft;
    if (draft != null) {
      draft.body = _text.text;
      unawaited(draft.persist());
    }
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final name = app.activeProfile?.displayLabel ?? 'You';
    final draft = _draft;
    final history = draft?.history ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text('Notes · ${widget.experience.stableId}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(widget.experience.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Writing as $name. A private note stays with this profile. A shared note is a choice, not a default.'),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'private', label: Text('Private'), icon: Icon(Icons.lock_outline)),
              ButtonSegment(value: 'shared', label: Text('Shared'), icon: Icon(Icons.people_outline)),
            ],
            selected: {draft?.scope ?? 'private'},
            onSelectionChanged: (selection) => _changeScope(selection.first),
          ),
          if (draft?.scope == 'shared') ...[
            const SizedBox(height: 8),
            const Text('Both profiles can read a shared note. The private draft is left where it is.'),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            minLines: 6,
            maxLines: 12,
            enabled: _ready,
            decoration: InputDecoration(
              labelText: draft?.scope == 'shared' ? 'Our note' : 'Private note for $name',
              alignLabelWithHint: true,
            ),
            onChanged: _onChanged,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _ready ? _newVisit : null,
            child: const Text('Start a new visit'),
          ),
          const SizedBox(height: 20),
          Text('Earlier notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Text('Nothing saved for this profile yet.')
          else
            for (final entry in history)
              Card(
                child: ListTile(
                  title: Text(entry.scope == 'shared' ? 'Shared' : 'Private'),
                  subtitle: Text('${entry.updatedAt}\n${entry.body}'),
                  isThreeLine: true,
                ),
              ),
        ],
      ),
    );
  }

  void _onChanged(String value) {
    if (_applying) {
      return;
    }
    _draft?.body = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_draft?.persist());
    });
  }

  Future<void> _changeScope(String scope) async {
    final draft = _draft;
    final profile = AppScope.of(context).activeProfile;
    if (draft == null || profile == null) {
      return;
    }
    if (scope == 'shared') {
      final allowed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share this note?'),
          content: const Text('A shared note can be read from both profiles. Your private note is not copied across.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it private')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Share')),
          ],
        ),
      );
      if (allowed != true || !mounted) {
        setState(() {});
        return;
      }
    }
    draft.body = _text.text;
    await draft.setScope(scope);
    if (!mounted) {
      return;
    }
    _applyText(draft.body);
    setState(() {});
  }

  Future<void> _newVisit() async {
    final draft = _draft;
    final profile = AppScope.of(context).activeProfile;
    if (draft == null || profile == null) {
      return;
    }
    draft.body = _text.text;
    await draft.startNewVisit(profile.id);
    if (!mounted) {
      return;
    }
    _applyText('');
    setState(() {});
    await AppScope.of(context).refreshSessions();
  }
}
