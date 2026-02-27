import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/habit_enums.dart';

/// Repository for managing habits
/// Currently uses in-memory storage, can be migrated to Isar later
class HabitRepository {
  final List<Habit> _habits = [];
  final _listeners = <VoidCallback>[];

  /// Get all active habits
  List<Habit> getAll() {
    return _habits.where((h) => h.isActive).toList();
  }

  /// Get habits by category
  List<Habit> getByCategory(HabitCategory category) {
    return _habits.where((h) => h.isActive && h.category == category).toList();
  }

  /// Get a single habit by ID
  Habit? getById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new habit
  void add(Habit habit) {
    _habits.add(habit);
    _notifyListeners();
  }

  /// Update an existing habit
  void update(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      _notifyListeners();
    }
  }

  /// Archive a habit (soft delete)
  void archive(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        archivedAt: DateTime.now(),
      );
      _notifyListeners();
    }
  }

  /// Permanently delete a habit
  void delete(String id) {
    _habits.removeWhere((h) => h.id == id);
    _notifyListeners();
  }

  /// Increment day number for a habit (when completing a day)
  void incrementDayNumber(String id) {
    final habit = getById(id);
    if (habit != null) {
      update(habit.copyWith(
        currentDayNumber: habit.currentDayNumber + 1,
        totalDaysCompleted: habit.totalDaysCompleted + 1,
      ));
    }
  }

  /// Update streak for a habit
  void updateStreak(String id, int newStreak) {
    final habit = getById(id);
    if (habit != null) {
      update(habit.copyWith(
        currentStreak: newStreak,
        bestStreak: newStreak > habit.bestStreak ? newStreak : habit.bestStreak,
      ));
    }
  }

  /// Get count of active habits
  int get activeCount => _habits.where((h) => h.isActive).length;

  /// Check if user can add more habits (max 6)
  bool get canAddMore => activeCount < 6;

  /// Listen to changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Export all habits as JSON
  String exportToJson() {
    return jsonEncode(_habits.map((h) => h.toJson()).toList());
  }

  /// Import habits from JSON
  void importFromJson(String json) {
    final List<dynamic> data = jsonDecode(json);
    _habits.clear();
    _habits.addAll(data.map((h) => Habit.fromJson(h as Map<String, dynamic>)));
    _notifyListeners();
  }
}
