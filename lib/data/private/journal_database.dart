import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Private journal database. Book content never lives in this file.
class JournalDatabase {
  JournalDatabase(this.database);

  final Database database;
  static const schemaVersion = 1;

  static Future<JournalDatabase> open({String? path, bool singleInstance = true}) async {
    final location = path ?? p.join(await getDatabasesPath(), 'closer_private_journal.sqlite');
    final database = await openDatabase(
      location,
      singleInstance: singleInstance,
      version: schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _create(db);
      },
      onUpgrade: (db, from, to) async {
        throw StateError(
          'No journal migration is defined for $from -> $to. Refusing to erase private notes.',
        );
      },
    );
    return JournalDatabase(database);
  }

  static Future<void> _create(Database db) async {
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        slot TEXT NOT NULL UNIQUE,
        display_label TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        experience_stable_id TEXT NOT NULL,
        content_edition_id TEXT NOT NULL,
        variant_id TEXT,
        state TEXT NOT NULL,
        step_index INTEGER NOT NULL DEFAULT 0,
        started_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        completed_at TEXT,
        timezone_name TEXT NOT NULL,
        timezone_offset_minutes INTEGER NOT NULL,
        rules_snapshot_json TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        scope TEXT NOT NULL CHECK (scope IN ('private', 'shared')),
        owner_profile_id TEXT,
        author_profile_id TEXT NOT NULL,
        prompt_id TEXT,
        prompt_revision INTEGER,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX journal_one_private
      ON journal_entries(session_id, owner_profile_id, ifnull(prompt_id, ''))
      WHERE scope = 'private'
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX journal_one_shared
      ON journal_entries(session_id, ifnull(prompt_id, ''))
      WHERE scope = 'shared'
    ''');
    await db.execute('''
      CREATE TABLE journal_revisions (
        entry_id TEXT NOT NULL,
        revision INTEGER NOT NULL,
        body TEXT NOT NULL,
        edited_at TEXT NOT NULL,
        PRIMARY KEY (entry_id, revision),
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites (
        experience_stable_id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE app_prefs (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
