import 'package:flutter/material.dart';
import 'habit_enums.dart';

/// Habit model representing a user's habit
class Habit {
  final String id;
  final String name;
  final String? description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final DateTime createdAt;
  final DateTime? archivedAt;

  // Notification settings
  final bool notificationsEnabled;
  final TimeOfDay? reminderTime;

  // Stats (tracked separately but denormalized for quick access)
  final int currentStreak;
  final int bestStreak;
  final int totalDaysCompleted;
  final int currentDayNumber;
  final DateTime? lastCompletedAt;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.frequency,
    required this.createdAt,
    this.archivedAt,
    this.notificationsEnabled = true,
    this.reminderTime,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalDaysCompleted = 0,
    this.currentDayNumber = 1,
    this.lastCompletedAt,
  });

  /// Create a new habit with generated ID
  factory Habit.create({
    required String name,
    String? description,
    required HabitCategory category,
    required HabitFrequency frequency,
    bool notificationsEnabled = true,
    TimeOfDay? reminderTime,
  }) {
    return Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      frequency: frequency,
      createdAt: DateTime.now(),
      notificationsEnabled: notificationsEnabled,
      reminderTime: reminderTime,
    );
  }

  /// Check if habit is active (not archived)
  bool get isActive => archivedAt == null;

  /// Get display string for day number
  String get dayDisplay => 'Day $currentDayNumber';

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// True if user completed this habit today
  bool get completedToday {
    if (lastCompletedAt == null) return false;
    return _dateOnly(lastCompletedAt!) == _dateOnly(DateTime.now());
  }

  /// True if streak > 0 and user hasn't completed today — streak will expire at midnight
  bool get isStreakAtRisk {
    if (currentStreak == 0 || lastCompletedAt == null) return false;
    if (completedToday) return false;
    final lastDate = _dateOnly(lastCompletedAt!);
    final today = _dateOnly(DateTime.now());
    return lastDate == today.subtract(const Duration(days: 1));
  }

  /// Hours remaining until streak expires (null if not at risk)
  int? get hoursUntilStreakExpires {
    if (!isStreakAtRisk) return null;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now).inHours;
  }

  /// Minutes until habit resets for next day (for completed habits)
  int get minutesUntilDailyReset {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now).inMinutes;
  }

  /// Copy with method for immutable updates
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? createdAt,
    DateTime? archivedAt,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    int? currentStreak,
    int? bestStreak,
    int? totalDaysCompleted,
    int? currentDayNumber,
    DateTime? lastCompletedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalDaysCompleted: totalDaysCompleted ?? this.totalDaysCompleted,
      currentDayNumber: currentDayNumber ?? this.currentDayNumber,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'frequency': frequency.name,
      'createdAt': createdAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalDaysCompleted': totalDaysCompleted,
      'currentDayNumber': currentDayNumber,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      reminderTime: json['reminderHour'] != null
          ? TimeOfDay(
              hour: json['reminderHour'] as int,
              minute: json['reminderMinute'] as int? ?? 0,
            )
          : null,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalDaysCompleted: json['totalDaysCompleted'] as int? ?? 0,
      currentDayNumber: json['currentDayNumber'] as int? ?? 1,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
