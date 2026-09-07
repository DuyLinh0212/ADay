import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/activity_event.dart';
import '../../domain/models/aday_snapshot.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/task_item.dart';
import '../../domain/repositories/aday_repository.dart';
import 'shared_preferences_aday_repository.dart';

/// SQLite-backed local storage for ADay.
///
/// Persists goals, tasks, activity history, and settings in dedicated,
/// normalized tables without embedding raw JSON blobs into single columns.
class SqliteADayRepository implements ADayRepository {
  SqliteADayRepository({
    SharedPreferences? legacyPreferences,
    Future<Database> Function()? databaseOpener,
  }) : _legacyPreferences = legacyPreferences,
       _databaseOpener = databaseOpener;

  static const databaseName = 'aday.db';
  static const legacyMigrationKey = 'legacy_shared_preferences_v1_imported';

  final SharedPreferences? _legacyPreferences;
  final Future<Database> Function()? _databaseOpener;
  Future<Database>? _databaseFuture;

  Future<Database> get _database =>
      _databaseFuture ??= (_databaseOpener?.call() ?? _open());

  Future<Database> _open() async {
    final directory = await getDatabasesPath();
    final database = await openDatabase(
      '$directory/$databaseName',
      version: 6,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await createSchema(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS activity_event_metadata (
              event_id TEXT NOT NULL,
              key TEXT NOT NULL,
              value TEXT NOT NULL,
              PRIMARY KEY (event_id, key),
              FOREIGN KEY(event_id) REFERENCES activity_events(id) ON DELETE CASCADE
            )
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS tasks_goal_id_idx ON tasks(goal_id)',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE app_settings ADD COLUMN theme_id TEXT NOT NULL DEFAULT 'default'",
          );
          await db.execute(
            "ALTER TABLE app_settings ADD COLUMN daily_quotes_json TEXT NOT NULL DEFAULT '[]'",
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN drive_account_email TEXT',
          );
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN drive_last_backup_at TEXT',
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN avatar_path TEXT',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            "ALTER TABLE app_settings ADD COLUMN email TEXT NOT NULL DEFAULT 'minh.aday@gmail.com'",
          );
        }
      },
    );
    await _importLegacySnapshotIfNeeded(database);
    return database;
  }

  /// Creates all normalized schema tables and indexes.
  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        kind TEXT NOT NULL,
        priority TEXT NOT NULL,
        start_date TEXT NOT NULL,
        deadline TEXT,
        reminder_enabled INTEGER NOT NULL,
        reminder_minute INTEGER,
        repeat_daily INTEGER NOT NULL,
        status TEXT NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        completed_at TEXT,
        postponed_until TEXT,
        status_reason TEXT,
        recurrence_source_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        start_minute INTEGER,
        end_minute INTEGER,
        status TEXT NOT NULL,
        completed_at TEXT,
        carried_from_date TEXT,
        FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_events (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        occurred_at TEXT NOT NULL,
        goal_id TEXT,
        task_id TEXT,
        reason TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_event_metadata (
        event_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        PRIMARY KEY (event_id, key),
        FOREIGN KEY(event_id) REFERENCES activity_events(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        singleton_id INTEGER PRIMARY KEY CHECK(singleton_id = 1),
        display_name TEXT NOT NULL,
        email TEXT NOT NULL DEFAULT 'minh.aday@gmail.com',
        daily_review_enabled INTEGER NOT NULL,
        daily_review_minute INTEGER NOT NULL,
        notifications_allowed INTEGER NOT NULL
        ,theme_id TEXT NOT NULL DEFAULT 'default'
        ,daily_quotes_json TEXT NOT NULL DEFAULT '[]'
        ,drive_account_email TEXT
        ,drive_last_backup_at TEXT
        ,avatar_path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS tasks_scheduled_date_idx ON tasks(scheduled_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS tasks_goal_id_idx ON tasks(goal_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS activity_events_occurred_at_idx ON activity_events(occurred_at)',
    );
  }

  @override
  Future<ADaySnapshot> load() async {
    final database = await _database;
    final goals = await _readGoals(database);
    final events = await _readEvents(database);
    final settings = await _readSettings(database);
    return ADaySnapshot(goals: goals, events: events, settings: settings);
  }

  @override
  Future<void> save(ADaySnapshot snapshot) async {
    final database = await _database;
    await database.transaction((txn) async {
      await _writeSnapshot(txn, snapshot);
    });
  }

  /// Writes all snapshot entities into tables using the provided [executor].
  ///
  /// Reusable in transactions and startup migrations without re-entrancy issues.
  Future<void> _writeSnapshot(
    DatabaseExecutor executor,
    ADaySnapshot snapshot,
  ) async {
    await executor.delete('activity_event_metadata');
    await executor.delete('activity_events');
    await executor.delete('tasks');
    await executor.delete('goals');

    for (final goal in snapshot.goals) {
      await executor.insert('goals', goalValues(goal));
      for (final task in goal.tasks) {
        await executor.insert('tasks', taskValues(goal.id, task));
      }
    }
    for (final event in snapshot.events) {
      await executor.insert('activity_events', eventValues(event));
      for (final entry in event.metadata.entries) {
        await executor.insert('activity_event_metadata', {
          'event_id': event.id,
          'key': entry.key,
          'value': entry.value,
        });
      }
    }
    await executor.insert(
      'app_settings',
      settingsValues(snapshot.settings),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _importLegacySnapshotIfNeeded(Database database) async {
    final migrated = await database.query(
      'app_metadata',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [legacyMigrationKey],
      limit: 1,
    );
    if (migrated.isNotEmpty) return;

    final countResult = await database.rawQuery(
      'SELECT COUNT(*) as cnt FROM goals',
    );
    final hasLocalRows = (Sqflite.firstIntValue(countResult) ?? 0) > 0;

    if (!hasLocalRows && _legacyPreferences != null) {
      try {
        final legacy = SharedPreferencesADayRepository(_legacyPreferences);
        final snapshot = await legacy.load();
        if (snapshot.goals.isNotEmpty ||
            snapshot.events.isNotEmpty ||
            snapshot.settings != const AppSettings()) {
          await database.transaction((txn) async {
            await _writeSnapshot(txn, snapshot);
          });
        }
      } on FormatException {
        // Keep a corrupt legacy payload untouched; SQLite starts safely empty.
      }
    }

    await database.insert('app_metadata', {
      'key': legacyMigrationKey,
      'value': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Goal>> _readGoals(Database database) async {
    final goalRows = await database.query('goals', orderBy: 'created_at ASC');
    final taskRows = await database.query(
      'tasks',
      orderBy: 'scheduled_date ASC, start_minute ASC',
    );
    final tasksByGoal = <String, List<TaskItem>>{};
    for (final row in taskRows) {
      final goalId = row['goal_id']! as String;
      (tasksByGoal[goalId] ??= []).add(taskFromRow(row));
    }
    return goalRows
        .map((row) => goalFromRow(row, tasksByGoal[row['id']] ?? const []))
        .toList(growable: false);
  }

  Future<List<ActivityEvent>> _readEvents(Database database) async {
    final rows = await database.query(
      'activity_events',
      orderBy: 'occurred_at ASC',
    );
    final metaRows = await database.query('activity_event_metadata');
    final metaByEvent = <String, Map<String, String>>{};
    for (final row in metaRows) {
      final eventId = row['event_id']! as String;
      final key = row['key']! as String;
      final value = row['value']! as String;
      (metaByEvent[eventId] ??= {})[key] = value;
    }
    return rows
        .map((row) => eventFromRow(row, metaByEvent[row['id']] ?? const {}))
        .toList(growable: false);
  }

  Future<AppSettings> _readSettings(Database database) async {
    final rows = await database.query(
      'app_settings',
      where: 'singleton_id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return const AppSettings();
    return settingsFromRow(rows.single);
  }

  static Map<String, Object?> goalValues(Goal goal) => {
    'id': goal.id,
    'title': goal.title,
    'description': goal.description,
    'category': goal.category,
    'kind': goal.kind.name,
    'priority': goal.priority.name,
    'start_date': goal.startDate.toIso8601String(),
    'deadline': goal.deadline?.toIso8601String(),
    'reminder_enabled': goal.reminderEnabled ? 1 : 0,
    'reminder_minute': goal.reminderMinute,
    'repeat_daily': goal.repeatDaily ? 1 : 0,
    'status': goal.status.name,
    'note': goal.note,
    'created_at': goal.createdAt.toIso8601String(),
    'updated_at': goal.updatedAt.toIso8601String(),
    'completed_at': goal.completedAt?.toIso8601String(),
    'postponed_until': goal.postponedUntil?.toIso8601String(),
    'status_reason': goal.statusReason,
    'recurrence_source_id': goal.recurrenceSourceId,
  };

  static Map<String, Object?> taskValues(String goalId, TaskItem task) => {
    'id': task.id,
    'goal_id': goalId,
    'title': task.title,
    'note': task.note,
    'scheduled_date': task.scheduledDate.toIso8601String(),
    'start_minute': task.startMinute,
    'end_minute': task.endMinute,
    'status': task.status.name,
    'completed_at': task.completedAt?.toIso8601String(),
    'carried_from_date': task.carriedFromDate?.toIso8601String(),
  };

  static Map<String, Object?> eventValues(ActivityEvent event) => {
    'id': event.id,
    'type': event.type.name,
    'occurred_at': event.occurredAt.toIso8601String(),
    'goal_id': event.goalId,
    'task_id': event.taskId,
    'reason': event.reason,
  };

  static Map<String, Object?> settingsValues(AppSettings settings) => {
    'singleton_id': 1,
    'display_name': settings.displayName,
    'email': settings.email,
    'daily_review_enabled': settings.dailyReviewEnabled ? 1 : 0,
    'daily_review_minute': settings.dailyReviewMinute,
    'notifications_allowed': settings.notificationsAllowed ? 1 : 0,
    'theme_id': settings.themeId,
    'daily_quotes_json': jsonEncode(settings.dailyQuotes),
    'drive_account_email': settings.driveAccountEmail,
    'drive_last_backup_at': settings.driveLastBackupAt?.toIso8601String(),
    'avatar_path': settings.avatarPath,
  };

  static Goal goalFromRow(Map<String, Object?> row, List<TaskItem> tasks) =>
      Goal(
        id: row['id']! as String,
        title: row['title']! as String,
        description: row['description']! as String,
        category: row['category']! as String,
        kind: GoalKind.values.byName(row['kind']! as String),
        priority: GoalPriority.values.byName(row['priority']! as String),
        startDate: DateTime.parse(row['start_date']! as String),
        deadline: parseDate(row['deadline']),
        reminderEnabled: parseBool(row['reminder_enabled']),
        reminderMinute: row['reminder_minute'] as int?,
        repeatDaily: parseBool(row['repeat_daily']),
        status: GoalStatus.values.byName(row['status']! as String),
        tasks: tasks,
        note: row['note']! as String,
        createdAt: DateTime.parse(row['created_at']! as String),
        updatedAt: DateTime.parse(row['updated_at']! as String),
        completedAt: parseDate(row['completed_at']),
        postponedUntil: parseDate(row['postponed_until']),
        statusReason: row['status_reason'] as String?,
        recurrenceSourceId: row['recurrence_source_id'] as String?,
      );

  static TaskItem taskFromRow(Map<String, Object?> row) => TaskItem(
    id: row['id']! as String,
    title: row['title']! as String,
    note: row['note']! as String,
    scheduledDate: DateTime.parse(row['scheduled_date']! as String),
    startMinute: row['start_minute'] as int?,
    endMinute: row['end_minute'] as int?,
    status: TaskStatus.values.byName(row['status']! as String),
    completedAt: parseDate(row['completed_at']),
    carriedFromDate: parseDate(row['carried_from_date']),
  );

  static ActivityEvent eventFromRow(
    Map<String, Object?> row, [
    Map<String, String> metadata = const {},
  ]) {
    var combinedMetadata = metadata;
    if (combinedMetadata.isEmpty && row.containsKey('metadata_json')) {
      final raw = row['metadata_json'];
      if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            combinedMetadata = Map<String, String>.from(decoded);
          }
        } catch (_) {}
      }
    }
    return ActivityEvent(
      id: row['id']! as String,
      type: ActivityType.values.byName(row['type']! as String),
      occurredAt: DateTime.parse(row['occurred_at']! as String),
      goalId: row['goal_id'] as String?,
      taskId: row['task_id'] as String?,
      reason: row['reason'] as String?,
      metadata: combinedMetadata,
    );
  }

  static AppSettings settingsFromRow(Map<String, Object?> row) => AppSettings(
    displayName: row['display_name']! as String,
    email: row['email'] as String? ?? 'minh.aday@gmail.com',
    dailyReviewEnabled: parseBool(row['daily_review_enabled']),
    dailyReviewMinute: row['daily_review_minute']! as int,
    notificationsAllowed: parseBool(row['notifications_allowed']),
    themeId: row['theme_id'] as String? ?? 'default',
    dailyQuotes: _quotesFromJson(row['daily_quotes_json']),
    driveAccountEmail: row['drive_account_email'] as String?,
    driveLastBackupAt: parseDate(row['drive_last_backup_at']),
    avatarPath: row['avatar_path'] as String?,
  );

  static List<String> _quotesFromJson(Object? value) {
    if (value is! String || value.isEmpty) return const [];
    try {
      return (jsonDecode(value) as List<Object?>)
          .whereType<String>()
          .where((quote) => quote.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static bool parseBool(Object? value) => value == true || value == 1;

  static DateTime? parseDate(Object? value) =>
      value is String && value.isNotEmpty ? DateTime.parse(value) : null;
}
