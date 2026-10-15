import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'journal_database.dart';

class Profile {
  const Profile({required this.id, required this.slot, required this.displayLabel});

  final String id;
  final String slot;
  final String displayLabel;
}

class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.experienceStableId,
    required this.contentEditionId,
    required this.state,
    required this.startedAt,
    required this.rulesSnapshot,
  });

  final String id;
  final String experienceStableId;
  final String contentEditionId;
  final String state;
  final String startedAt;
  final Map<String, dynamic>? rulesSnapshot;
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.sessionId,
    required this.experienceStableId,
    required this.scope,
    required this.ownerProfileId,
    required this.authorProfileId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.promptId,
    required this.promptRevision,
    required this.contentEditionId,
  });

  final String id;
  final String sessionId;
  final String experienceStableId;
  final String scope;
  final String? ownerProfileId;
  final String authorProfileId;
  final String body;
  final String createdAt;
  final String updatedAt;
  final String? promptId;
  final int? promptRevision;
  final String contentEditionId;
}

class JournalRepository {
  JournalRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? ids,
  })  : _clock = clock ?? DateTime.now,
        _ids = ids ?? _uuid.v4;

  final JournalDatabase _database;
  final DateTime Function() _clock;
  final String Function() _ids;
  static const _uuid = Uuid();

  Database get _db => _database.database;

  static Future<JournalRepository> openDefault() async {
    final database = await JournalDatabase.open();
    final repository = JournalRepository(database);
    await repository.ensureProfiles();
    return repository;
  }

  static Future<JournalRepository> openMemory({
    DateTime Function()? clock,
    String Function()? ids,
    bool singleInstance = true,
  }) async {
    final database = await JournalDatabase.open(path: inMemoryDatabasePath, singleInstance: singleInstance);
    final repository = JournalRepository(database, clock: clock, ids: ids);
    await repository.ensureProfiles();
    return repository;
  }

  Future<void> ensureProfiles() async {
    final existing = await profiles();
    if (existing.isNotEmpty) {
      return;
    }
    final now = _stamp();
    await _db.insert('profiles', {
      'id': _ids(),
      'slot': 'partner_a',
      'display_label': 'Partner A',
      'created_at': now,
    });
    await _db.insert('profiles', {
      'id': _ids(),
      'slot': 'partner_b',
      'display_label': 'Partner B',
      'created_at': now,
    });
  }

  Future<List<Profile>> profiles() async {
    final rows = await _db.query('profiles', orderBy: 'slot');
    return rows
        .map(
          (row) => Profile(
            id: row['id'] as String,
            slot: row['slot'] as String,
            displayLabel: row['display_label'] as String,
          ),
        )
        .toList();
  }

  Future<void> renameProfile(String id, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await _db.update(
      'profiles',
      {'display_label': trimmed},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> preference(String key) async {
    final rows = await _db.query('app_prefs', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String;
  }

  Future<void> setPreference(String key, String value) async {
    await _db.insert('app_prefs', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<SessionRecord> ensureOpenSession({
    required String experienceId,
    required String contentEditionId,
  }) async {
    final rows = await _db.query(
      'sessions',
      where: 'experience_stable_id = ? AND state = ?',
      whereArgs: [experienceId, 'in_progress'],
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return _session(rows.first);
    }
    return _insertSession(experienceId: experienceId, contentEditionId: contentEditionId);
  }

  Future<SessionRecord> startNewVisit({
    required String experienceId,
    required String contentEditionId,
  }) async {
    final now = _stamp();
    await _db.update(
      'sessions',
      {'state': 'completed', 'updated_at': now, 'completed_at': now},
      where: 'experience_stable_id = ? AND state = ?',
      whereArgs: [experienceId, 'in_progress'],
    );
    return _insertSession(experienceId: experienceId, contentEditionId: contentEditionId);
  }

  Future<List<SessionRecord>> inProgressSessions() async {
    final rows = await _db.query(
      'sessions',
      where: 'state = ?',
      whereArgs: ['in_progress'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_session).toList();
  }

  Future<JournalEntry> saveEntry({
    required String sessionId,
    required String scope,
    required String authorProfileId,
    String? ownerProfileId,
    required String body,
    String? promptId,
    int? promptRevision,
  }) async {
    if (scope != 'private' && scope != 'shared') {
      throw ArgumentError('scope must be private or shared');
    }
    if (scope == 'private' && (ownerProfileId == null || ownerProfileId.isEmpty)) {
      throw ArgumentError('a private note needs an owner');
    }
    if (scope == 'shared') {
      ownerProfileId = null;
    }
    final now = _stamp();
    final existing = await _db.query(
      'journal_entries',
      where: scope == 'private'
          ? "session_id = ? AND scope = ? AND owner_profile_id = ? AND ifnull(prompt_id, '') = ?"
          : "session_id = ? AND scope = ? AND ifnull(prompt_id, '') = ?",
      whereArgs: scope == 'private'
          ? [sessionId, scope, ownerProfileId, promptId ?? '']
          : [sessionId, scope, promptId ?? ''],
      limit: 1,
    );
    if (existing.isEmpty) {
      final id = _ids();
      await _db.insert('journal_entries', {
        'id': id,
        'session_id': sessionId,
        'scope': scope,
        'owner_profile_id': ownerProfileId,
        'author_profile_id': authorProfileId,
        'prompt_id': promptId,
        'prompt_revision': promptRevision,
        'body': body,
        'created_at': now,
        'updated_at': now,
      });
      await _db.insert('journal_revisions', {
        'entry_id': id,
        'revision': 1,
        'body': body,
        'edited_at': now,
      });
      await _touchSession(sessionId, now);
      return (await _entryById(id))!;
    }
    final current = existing.first;
    final id = current['id'] as String;
    if (current['body'] == body) {
      return (await _entryById(id))!;
    }
    final revisionRows = await _db.rawQuery(
      'SELECT COALESCE(MAX(revision), 0) AS revision FROM journal_revisions WHERE entry_id = ?',
      [id],
    );
    final nextRevision = (revisionRows.first['revision'] as int) + 1;
    await _db.update(
      'journal_entries',
      {
        'body': body,
        'updated_at': now,
        'author_profile_id': authorProfileId,
        'prompt_revision': promptRevision ?? current['prompt_revision'],
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.insert('journal_revisions', {
      'entry_id': id,
      'revision': nextRevision,
      'body': body,
      'edited_at': now,
    });
    await _touchSession(sessionId, now);
    return (await _entryById(id))!;
  }

  Future<List<int>> revisionsFor(String entryId) async {
    final rows = await _db.query(
      'journal_revisions',
      columns: ['revision'],
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'revision',
    );
    return rows.map((row) => row['revision'] as int).toList();
  }

  Future<JournalEntry?> draft({
    required String sessionId,
    required String scope,
    String? ownerProfileId,
    String? promptId,
  }) async {
    final rows = await _db.query(
      'journal_entries',
      where: scope == 'private'
          ? "session_id = ? AND scope = ? AND owner_profile_id = ? AND ifnull(prompt_id, '') = ?"
          : "session_id = ? AND scope = ? AND ifnull(prompt_id, '') = ?",
      whereArgs: scope == 'private'
          ? [sessionId, scope, ownerProfileId, promptId ?? '']
          : [sessionId, scope, promptId ?? ''],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _entryFromRow(rows.first, await _sessionEdition(rows.first['session_id'] as String));
  }

  Future<List<JournalEntry>> entriesVisibleTo(String viewerProfileId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT e.*, s.experience_stable_id, s.content_edition_id
      FROM journal_entries e
      JOIN sessions s ON s.id = e.session_id
      WHERE e.scope = 'shared' OR e.owner_profile_id = ?
      ORDER BY e.updated_at DESC
      ''',
      [viewerProfileId],
    );
    return rows.map(_entryJoined).toList();
  }

  Future<List<JournalEntry>> entriesForExperience({
    required String experienceId,
    required String viewerProfileId,
  }) async {
    final rows = await entriesVisibleTo(viewerProfileId);
    return rows.where((entry) => entry.experienceStableId == experienceId).toList();
  }

  Future<void> setFavorite(String experienceId, {required bool favorite}) async {
    if (favorite) {
      await _db.insert('favorites', {
        'experience_stable_id': experienceId,
        'created_at': _stamp(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await _db.delete(
        'favorites',
        where: 'experience_stable_id = ?',
        whereArgs: [experienceId],
      );
    }
  }

  Future<Set<String>> favoriteIds() async {
    final rows = await _db.query('favorites');
    return rows.map((row) => row['experience_stable_id'] as String).toSet();
  }

  Future<SessionRecord> _insertSession({
    required String experienceId,
    required String contentEditionId,
  }) async {
    final now = _clock();
    final id = _ids();
    await _db.insert('sessions', {
      'id': id,
      'experience_stable_id': experienceId,
      'content_edition_id': contentEditionId,
      'state': 'in_progress',
      'step_index': 0,
      'started_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'timezone_name': now.timeZoneName,
      'timezone_offset_minutes': now.timeZoneOffset.inMinutes,
    });
    final rows = await _db.query('sessions', where: 'id = ?', whereArgs: [id], limit: 1);
    return _session(rows.first);
  }

  Future<void> _touchSession(String sessionId, String now) async {
    await _db.update('sessions', {'updated_at': now}, where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<JournalEntry?> _entryById(String id) async {
    final rows = await _db.rawQuery(
      '''
      SELECT e.*, s.experience_stable_id, s.content_edition_id
      FROM journal_entries e
      JOIN sessions s ON s.id = e.session_id
      WHERE e.id = ?
      ''',
      [id],
    );
    if (rows.isEmpty) {
      return null;
    }
    return _entryJoined(rows.first);
  }

  Future<String> _sessionEdition(String sessionId) async {
    final rows = await _db.query(
      'sessions',
      columns: ['content_edition_id'],
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return rows.first['content_edition_id'] as String;
  }

  SessionRecord _session(Map<String, Object?> row) {
    final snapshot = row['rules_snapshot_json'] as String?;
    return SessionRecord(
      id: row['id'] as String,
      experienceStableId: row['experience_stable_id'] as String,
      contentEditionId: row['content_edition_id'] as String,
      state: row['state'] as String,
      startedAt: row['started_at'] as String,
      rulesSnapshot: snapshot == null ? null : jsonDecode(snapshot) as Map<String, dynamic>,
    );
  }

  JournalEntry _entryJoined(Map<String, Object?> row) {
    return _entryFromRow(row, row['content_edition_id'] as String, experienceId: row['experience_stable_id'] as String);
  }

  JournalEntry _entryFromRow(
    Map<String, Object?> row,
    String editionId, {
    String? experienceId,
  }) {
    return JournalEntry(
      id: row['id'] as String,
      sessionId: row['session_id'] as String,
      experienceStableId: experienceId ?? '',
      scope: row['scope'] as String,
      ownerProfileId: row['owner_profile_id'] as String?,
      authorProfileId: row['author_profile_id'] as String,
      body: row['body'] as String,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
      promptId: row['prompt_id'] as String?,
      promptRevision: row['prompt_revision'] as int?,
      contentEditionId: editionId,
    );
  }

  String _stamp() => _clock().toIso8601String();

  Future<Map<String, Object?>> exportArchive() async {
    return {
      'format': journalExportFormat,
      'exported_at': _stamp(),
      'profiles': await _db.query('profiles'),
      'sessions': await _db.query('sessions'),
      'journal_entries': await _db.query('journal_entries'),
      'journal_revisions': await _db.query('journal_revisions'),
      'favorites': await _db.query('favorites'),
    };
  }

  /// Adds notes from an export onto this phone. Existing rows are left in place.
  /// Profile ids are matched by slot, so a private note stays with Partner A or Partner B.
  Future<JournalRestoreResult> restoreArchive(Map<String, Object?> archive) async {
    if (archive['format'] != journalExportFormat) {
      throw FormatException('This file is not a Closer Project journal export.');
    }
    final localProfiles = await profiles();
    final slotToLocal = {for (final profile in localProfiles) profile.slot: profile.id};
    final profileMap = <String, String>{};
    for (final row in _rows(archive['profiles'])) {
      final slot = row['slot']?.toString() ?? '';
      final oldId = row['id']?.toString() ?? '';
      if (slot.isEmpty || oldId.isEmpty) {
        continue;
      }
      final localId = slotToLocal[slot];
      if (localId != null) {
        profileMap[oldId] = localId;
        continue;
      }
      profileMap[oldId] = oldId;
      slotToLocal[slot] = oldId;
      await _db.insert('profiles', {
        'id': oldId,
        'slot': slot,
        'display_label': row['display_label']?.toString() ?? slot,
        'created_at': row['created_at']?.toString() ?? _stamp(),
      });
    }

    var sessionsAdded = 0;
    for (final row in _rows(archive['sessions'])) {
      final id = row['id']?.toString() ?? '';
      if (id.isEmpty) {
        continue;
      }
      final existing = await _db.query('sessions', where: 'id = ?', whereArgs: [id], limit: 1);
      if (existing.isNotEmpty) {
        continue;
      }
      await _db.insert('sessions', {
        'id': id,
        'experience_stable_id': row['experience_stable_id'],
        'content_edition_id': row['content_edition_id'],
        'variant_id': row['variant_id'],
        'state': row['state'] ?? 'completed',
        'step_index': row['step_index'] ?? 0,
        'started_at': row['started_at'],
        'updated_at': row['updated_at'],
        'completed_at': row['completed_at'],
        'timezone_name': row['timezone_name'] ?? 'UTC',
        'timezone_offset_minutes': row['timezone_offset_minutes'] ?? 0,
        'rules_snapshot_json': row['rules_snapshot_json'],
      });
      sessionsAdded += 1;
    }

    var entriesAdded = 0;
    var entriesSkipped = 0;
    for (final row in _rows(archive['journal_entries'])) {
      final id = row['id']?.toString() ?? '';
      final sessionId = row['session_id']?.toString() ?? '';
      if (id.isEmpty || sessionId.isEmpty) {
        entriesSkipped += 1;
        continue;
      }
      final session = await _db.query('sessions', where: 'id = ?', whereArgs: [sessionId], limit: 1);
      if (session.isEmpty) {
        entriesSkipped += 1;
        continue;
      }
      final existing = await _db.query('journal_entries', where: 'id = ?', whereArgs: [id], limit: 1);
      if (existing.isNotEmpty) {
        entriesSkipped += 1;
        continue;
      }
      final scope = row['scope']?.toString() ?? '';
      final owner = row['owner_profile_id']?.toString();
      final author = row['author_profile_id']?.toString() ?? '';
      final mappedOwner = owner == null ? null : profileMap[owner];
      final mappedAuthor = profileMap[author] ?? author;
      if (scope == 'private' && (mappedOwner == null || mappedOwner.isEmpty)) {
        entriesSkipped += 1;
        continue;
      }
      if (author.isEmpty || (scope != 'private' && scope != 'shared')) {
        entriesSkipped += 1;
        continue;
      }
      try {
        await _db.insert('journal_entries', {
          'id': id,
          'session_id': sessionId,
          'scope': scope,
          'owner_profile_id': scope == 'shared' ? null : mappedOwner,
          'author_profile_id': mappedAuthor,
          'prompt_id': row['prompt_id'],
          'prompt_revision': row['prompt_revision'],
          'body': row['body'] ?? '',
          'created_at': row['created_at'] ?? _stamp(),
          'updated_at': row['updated_at'] ?? _stamp(),
        });
      } on DatabaseException {
        entriesSkipped += 1;
        continue;
      }
      entriesAdded += 1;
    }

    for (final row in _rows(archive['journal_revisions'])) {
      final entryId = row['entry_id']?.toString() ?? '';
      final revision = row['revision'];
      if (entryId.isEmpty || revision == null) {
        continue;
      }
      final entry = await _db.query('journal_entries', where: 'id = ?', whereArgs: [entryId], limit: 1);
      if (entry.isEmpty) {
        continue;
      }
      await _db.insert('journal_revisions', {
        'entry_id': entryId,
        'revision': revision,
        'body': row['body'] ?? '',
        'edited_at': row['edited_at'] ?? _stamp(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    for (final row in _rows(archive['favorites'])) {
      final id = row['experience_stable_id']?.toString() ?? '';
      if (id.isEmpty) {
        continue;
      }
      await _db.insert('favorites', {
        'experience_stable_id': id,
        'created_at': row['created_at'] ?? _stamp(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    return JournalRestoreResult(
      sessionsAdded: sessionsAdded,
      entriesAdded: entriesAdded,
      entriesSkipped: entriesSkipped,
    );
  }
}

const journalExportFormat = 'closer-journal-1';

class JournalRestoreResult {
  const JournalRestoreResult({
    required this.sessionsAdded,
    required this.entriesAdded,
    required this.entriesSkipped,
  });

  final int sessionsAdded;
  final int entriesAdded;
  final int entriesSkipped;
}

List<Map<String, Object?>> _rows(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row is Map) row.map((key, item) => MapEntry(key.toString(), item)),
  ];
}
