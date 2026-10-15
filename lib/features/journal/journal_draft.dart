import '../../data/private/journal_repository.dart';
import '../../domain/content_pack.dart';

class JournalDraft {
  JournalDraft({required this.journal, required this.experience, required this.contentEditionId});

  final JournalRepository journal;
  final Experience experience;
  final String contentEditionId;

  String scope = 'private';
  String body = '';
  String? sessionId;
  String? boundProfileId;
  List<JournalEntry> history = const [];

  Future<void> bind(String profileId) async {
    if (boundProfileId != null && boundProfileId != profileId && scope == 'private') {
      await persist(ownerProfileId: boundProfileId!);
    } else if (boundProfileId != null && scope == 'shared') {
      await persist(ownerProfileId: null);
    }
    boundProfileId = profileId;
    final session = await journal.ensureOpenSession(
      experienceId: experience.stableId,
      contentEditionId: contentEditionId,
    );
    sessionId = session.id;
    await _loadBody();
    history = await journal.entriesForExperience(
      experienceId: experience.stableId,
      viewerProfileId: profileId,
    );
  }

  Future<void> setScope(String nextScope) async {
    if (nextScope == scope || boundProfileId == null) {
      return;
    }
    await persist(ownerProfileId: scope == 'private' ? boundProfileId : null);
    scope = nextScope;
    await _loadBody();
    history = await journal.entriesForExperience(
      experienceId: experience.stableId,
      viewerProfileId: boundProfileId!,
    );
  }

  Future<void> persist({String? ownerProfileId}) async {
    final session = sessionId;
    final author = boundProfileId;
    if (session == null || author == null) {
      return;
    }
    final owner = scope == 'private' ? (ownerProfileId ?? author) : null;
    final existing = await journal.draft(
      sessionId: session,
      scope: scope,
      ownerProfileId: owner,
    );
    if (body.trim().isEmpty && existing == null) {
      return;
    }
    if (existing != null && existing.body == body) {
      return;
    }
    await journal.saveEntry(
      sessionId: session,
      scope: scope,
      authorProfileId: author,
      ownerProfileId: owner,
      body: body,
    );
  }

  Future<void> startNewVisit(String profileId) async {
    await persist();
    final session = await journal.startNewVisit(
      experienceId: experience.stableId,
      contentEditionId: contentEditionId,
    );
    sessionId = session.id;
    body = '';
    history = await journal.entriesForExperience(
      experienceId: experience.stableId,
      viewerProfileId: profileId,
    );
  }

  Future<void> _loadBody() async {
    final session = sessionId;
    final profile = boundProfileId;
    if (session == null || profile == null) {
      body = '';
      return;
    }
    final existing = await journal.draft(
      sessionId: session,
      scope: scope,
      ownerProfileId: scope == 'private' ? profile : null,
    );
    body = existing?.body ?? '';
  }
}
