import 'dart:convert';

import 'package:aday/data/local/shared_preferences_aday_repository.dart';
import 'package:aday/data/local/sqlite_aday_repository.dart';
import 'package:aday/domain/models/activity_event.dart';
import 'package:aday/domain/models/app_settings.dart';
import 'package:aday/domain/models/goal.dart';
import 'package:aday/domain/models/task_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('SqliteADayRepository schema & value mappers', () {
    final now = DateTime(2026, 9, 7, 18, 30);

    test('round-trips Goal entity to row and back', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Học Flutter Architecture',
        description: 'Nắm vững SQLite & Clean Code',
        category: 'Học tập',
        kind: GoalKind.longTerm,
        priority: GoalPriority.high,
        startDate: now,
        deadline: now.add(const Duration(days: 30)),
        reminderEnabled: true,
        reminderMinute: 480,
        repeatDaily: false,
        status: GoalStatus.active,
        note: 'Ghi chú học tập',
        createdAt: now,
        updatedAt: now,
        completedAt: null,
        postponedUntil: null,
        statusReason: null,
        recurrenceSourceId: 'rec-1',
      );

      final row = SqliteADayRepository.goalValues(goal);
      expect(row['id'], 'goal-1');
      expect(row['title'], 'Học Flutter Architecture');
      expect(row['kind'], 'longTerm');
      expect(row['priority'], 'high');
      expect(row['reminder_enabled'], 1);
      expect(row['reminder_minute'], 480);
      expect(row['repeat_daily'], 0);
      expect(row['status'], 'active');
      expect(row['start_date'], now.toIso8601String());

      final restored = SqliteADayRepository.goalFromRow(row, const []);
      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.description, goal.description);
      expect(restored.category, goal.category);
      expect(restored.kind, goal.kind);
      expect(restored.priority, goal.priority);
      expect(restored.startDate, goal.startDate);
      expect(restored.deadline, goal.deadline);
      expect(restored.reminderEnabled, true);
      expect(restored.reminderMinute, 480);
      expect(restored.repeatDaily, false);
      expect(restored.status, GoalStatus.active);
      expect(restored.note, goal.note);
      expect(restored.createdAt, goal.createdAt);
      expect(restored.updatedAt, goal.updatedAt);
      expect(restored.recurrenceSourceId, 'rec-1');
    });

    test('round-trips TaskItem entity to row and back', () {
      final task = TaskItem(
        id: 'task-1',
        title: 'Làm bài tập SQLite',
        note: 'Kiểm tra foreign key',
        scheduledDate: DateTime(2026, 9, 8),
        startMinute: 540,
        endMinute: 660,
        status: TaskStatus.completed,
        completedAt: now,
        carriedFromDate: DateTime(2026, 9, 7),
      );

      final row = SqliteADayRepository.taskValues('goal-1', task);
      expect(row['id'], 'task-1');
      expect(row['goal_id'], 'goal-1');
      expect(row['title'], 'Làm bài tập SQLite');
      expect(row['start_minute'], 540);
      expect(row['end_minute'], 660);
      expect(row['status'], 'completed');
      expect(row['completed_at'], now.toIso8601String());
      expect(row['carried_from_date'], DateTime(2026, 9, 7).toIso8601String());

      final restored = SqliteADayRepository.taskFromRow(row);
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.note, task.note);
      expect(restored.scheduledDate, task.scheduledDate);
      expect(restored.startMinute, task.startMinute);
      expect(restored.endMinute, task.endMinute);
      expect(restored.status, task.status);
      expect(restored.completedAt, task.completedAt);
      expect(restored.carriedFromDate, task.carriedFromDate);
    });

    test('round-trips ActivityEvent with relational metadata and back', () {
      final event = ActivityEvent(
        id: 'event-1',
        type: ActivityType.taskCarriedForward,
        occurredAt: now,
        goalId: 'goal-1',
        taskId: 'task-1',
        reason: 'Chưa kịp hoàn thành',
        metadata: {'toDate': '2026-09-08T00:00:00.000'},
      );

      final row = SqliteADayRepository.eventValues(event);
      expect(row['id'], 'event-1');
      expect(row['type'], 'taskCarriedForward');
      expect(row['occurred_at'], now.toIso8601String());
      expect(row['goal_id'], 'goal-1');
      expect(row['task_id'], 'task-1');
      expect(row['reason'], 'Chưa kịp hoàn thành');
      expect(row.containsKey('metadata_json'), isFalse);

      final restored = SqliteADayRepository.eventFromRow(row, {
        'toDate': '2026-09-08T00:00:00.000',
      });
      expect(restored.id, event.id);
      expect(restored.type, ActivityType.taskCarriedForward);
      expect(restored.occurredAt, event.occurredAt);
      expect(restored.goalId, 'goal-1');
      expect(restored.taskId, 'task-1');
      expect(restored.reason, 'Chưa kịp hoàn thành');
      expect(restored.metadata['toDate'], '2026-09-08T00:00:00.000');
    });

    test(
      'falls back gracefully to legacy metadata_json if row contains it',
      () {
        final legacyRow = <String, Object?>{
          'id': 'event-legacy',
          'type': 'goalCreated',
          'occurred_at': now.toIso8601String(),
          'goal_id': 'goal-2',
          'task_id': null,
          'reason': null,
          'metadata_json': '{"source":"import"}',
        };

        final restored = SqliteADayRepository.eventFromRow(legacyRow);
        expect(restored.id, 'event-legacy');
        expect(restored.metadata['source'], 'import');
      },
    );

    test('round-trips AppSettings entity to row and back', () {
      const settings = AppSettings(
        displayName: 'Duy Linh',
        dailyReviewEnabled: true,
        dailyReviewMinute: 1300,
        notificationsAllowed: true,
      );

      final row = SqliteADayRepository.settingsValues(settings);
      expect(row['singleton_id'], 1);
      expect(row['display_name'], 'Duy Linh');
      expect(row['daily_review_enabled'], 1);
      expect(row['daily_review_minute'], 1300);
      expect(row['notifications_allowed'], 1);

      final restored = SqliteADayRepository.settingsFromRow(row);
      expect(restored.displayName, 'Duy Linh');
      expect(restored.dailyReviewEnabled, true);
      expect(restored.dailyReviewMinute, 1300);
      expect(restored.notificationsAllowed, true);
    });

    test(
      'legacy SharedPreferences snapshot round-trips correctly for migration',
      () async {
        SharedPreferences.setMockInitialValues({
          'aday.snapshot.v1': jsonEncode({
            'schemaVersion': 1,
            'goals': [
              {
                'id': 'goal-legacy',
                'title': 'Kế hoạch cũ từ SharedPreferences',
                'description': 'Mô tả cũ',
                'category': 'Sức khỏe',
                'kind': 'daily',
                'priority': 'medium',
                'startDate': '2026-09-07T00:00:00.000',
                'deadline': null,
                'reminderEnabled': false,
                'reminderMinute': null,
                'repeatDaily': true,
                'status': 'active',
                'tasks': [
                  {
                    'id': 'task-legacy',
                    'title': 'Chạy bộ 30 phút',
                    'note': '',
                    'scheduledDate': '2026-09-07T00:00:00.000',
                    'startMinute': 360,
                    'endMinute': 390,
                    'status': 'pending',
                  },
                ],
                'note': '',
                'createdAt': '2026-09-07T00:00:00.000',
                'updatedAt': '2026-09-07T00:00:00.000',
              },
            ],
            'events': [],
            'settings': {
              'displayName': 'Minh',
              'dailyReviewEnabled': true,
              'dailyReviewMinute': 1305,
              'notificationsAllowed': false,
            },
          }),
        });

        final prefs = await SharedPreferences.getInstance();
        final legacy = SharedPreferencesADayRepository(prefs);
        final snapshot = await legacy.load();

        expect(snapshot.goals.length, 1);
        expect(snapshot.goals.single.title, 'Kế hoạch cũ từ SharedPreferences');
        expect(snapshot.goals.single.tasks.single.title, 'Chạy bộ 30 phút');
        expect(snapshot.settings.displayName, 'Minh');

        // Verify that the loaded legacy snapshot can be converted into SQLite rows
        final goalRow = SqliteADayRepository.goalValues(snapshot.goals.single);
        expect(goalRow['id'], 'goal-legacy');
        expect(goalRow['repeat_daily'], 1);

        final taskRow = SqliteADayRepository.taskValues(
          snapshot.goals.single.id,
          snapshot.goals.single.tasks.single,
        );
        expect(taskRow['id'], 'task-legacy');
        expect(taskRow['goal_id'], 'goal-legacy');
      },
    );

    test(
      'createSchema executes valid DDL for all 6 tables and 3 indexes',
      () async {
        final executor = _RecordingDatabaseExecutor();
        await SqliteADayRepository.createSchema(executor);
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('CREATE TABLE IF NOT EXISTS goals'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('CREATE TABLE IF NOT EXISTS tasks'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('CREATE TABLE IF NOT EXISTS activity_events'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains(
              'CREATE TABLE IF NOT EXISTS activity_event_metadata',
            ),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('CREATE TABLE IF NOT EXISTS app_settings'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('CREATE TABLE IF NOT EXISTS app_metadata'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('tasks_scheduled_date_idx'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('tasks_goal_id_idx'),
          ),
          isTrue,
        );
        expect(
          executor.executedStatements.any(
            (sql) => sql.contains('activity_events_occurred_at_idx'),
          ),
          isTrue,
        );
      },
    );
  });
}

class _RecordingDatabaseExecutor extends Fake implements DatabaseExecutor {
  final List<String> executedStatements = [];

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    executedStatements.add(sql);
  }
}
