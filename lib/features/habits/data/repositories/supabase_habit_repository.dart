import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';

class SupabaseHabitRepository {
  final _db = Supabase.instance.client.from('habits');

  Future<List<Habit>> fetchAll(String userId) async {
    final rows = await _db
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return rows.map((r) => _fromRow(r)).toList();
  }

  Future<void> upsertHabit(Habit habit, String userId) async {
    await _db.upsert(_toRow(habit, userId));
  }

  Future<void> deleteHabit(String habitId) async {
    await _db.delete().eq('id', habitId);
  }

  Future<void> archiveHabit(String habitId, DateTime archivedAt) async {
    await _db
        .update({'archived_at': archivedAt.toIso8601String(), 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', habitId);
  }

  static Map<String, dynamic> _toRow(Habit habit, String userId) => {
        'id': habit.id,
        'user_id': userId,
        'name': habit.name,
        'description': habit.description,
        'category': habit.category.name,
        'frequency': habit.frequency.name,
        'notifications_enabled': habit.notificationsEnabled,
        'reminder_hour': habit.reminderTime?.hour,
        'reminder_minute': habit.reminderTime?.minute,
        'current_streak': habit.currentStreak,
        'best_streak': habit.bestStreak,
        'total_days_completed': habit.totalDaysCompleted,
        'current_day_number': habit.currentDayNumber,
        'created_at': habit.createdAt.toIso8601String(),
        'archived_at': habit.archivedAt?.toIso8601String(),
        'last_completed_at': habit.lastCompletedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  static Habit _fromRow(Map<String, dynamic> r) {
    final json = {
      'id': r['id'],
      'name': r['name'],
      'description': r['description'],
      'category': r['category'],
      'frequency': r['frequency'],
      'notificationsEnabled': r['notifications_enabled'],
      'reminderHour': r['reminder_hour'],
      'reminderMinute': r['reminder_minute'],
      'currentStreak': r['current_streak'],
      'bestStreak': r['best_streak'],
      'totalDaysCompleted': r['total_days_completed'],
      'currentDayNumber': r['current_day_number'],
      'createdAt': r['created_at'],
      'archivedAt': r['archived_at'],
      'lastCompletedAt': r['last_completed_at'],
    };
    return Habit.fromJson(json);
  }
}
