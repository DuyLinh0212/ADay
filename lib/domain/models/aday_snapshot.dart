import 'activity_event.dart';
import 'app_settings.dart';
import 'goal.dart';

class ADaySnapshot {
  const ADaySnapshot({
    this.schemaVersion = currentSchemaVersion,
    this.goals = const [],
    this.events = const [],
    this.settings = const AppSettings(),
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final List<Goal> goals;
  final List<ActivityEvent> events;
  final AppSettings settings;

  ADaySnapshot copyWith({
    List<Goal>? goals,
    List<ActivityEvent>? events,
    AppSettings? settings,
  }) {
    return ADaySnapshot(
      schemaVersion: schemaVersion,
      goals: goals ?? this.goals,
      events: events ?? this.events,
      settings: settings ?? this.settings,
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'goals': goals.map((goal) => goal.toJson()).toList(),
    'events': events.map((event) => event.toJson()).toList(),
    'settings': settings.toJson(),
  };

  factory ADaySnapshot.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'] as int? ?? 1;
    if (version > currentSchemaVersion) {
      throw FormatException('Unsupported ADay schema version: $version');
    }
    return ADaySnapshot(
      schemaVersion: version,
      goals: (json['goals'] as List<Object?>? ?? const [])
          .map((goal) => Goal.fromJson(Map<String, Object?>.from(goal! as Map)))
          .toList(growable: false),
      events: (json['events'] as List<Object?>? ?? const [])
          .map(
            (event) => ActivityEvent.fromJson(
              Map<String, Object?>.from(event! as Map),
            ),
          )
          .toList(growable: false),
      settings: AppSettings.fromJson(
        Map<String, Object?>.from(json['settings'] as Map? ?? const {}),
      ),
    );
  }
}
