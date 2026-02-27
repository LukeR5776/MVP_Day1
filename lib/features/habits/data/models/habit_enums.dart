import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Habit categories - The 4 Wins Framework
enum HabitCategory {
  physical,
  mental,
  creative,
  growth;

  String get displayName {
    switch (this) {
      case HabitCategory.physical:
        return 'Physical';
      case HabitCategory.mental:
        return 'Mental';
      case HabitCategory.creative:
        return 'Creative';
      case HabitCategory.growth:
        return 'Growth';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.physical:
        return '💪';
      case HabitCategory.mental:
        return '🧠';
      case HabitCategory.creative:
        return '🎨';
      case HabitCategory.growth:
        return '🌱';
    }
  }

  Color get color {
    switch (this) {
      case HabitCategory.physical:
        return AppColors.physical;
      case HabitCategory.mental:
        return AppColors.mental;
      case HabitCategory.creative:
        return AppColors.creative;
      case HabitCategory.growth:
        return AppColors.growth;
    }
  }

  String get description {
    switch (this) {
      case HabitCategory.physical:
        return 'Body & fitness';
      case HabitCategory.mental:
        return 'Mind & focus';
      case HabitCategory.creative:
        return 'Art & expression';
      case HabitCategory.growth:
        return 'Skills & learning';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.physical:
        return Icons.fitness_center;
      case HabitCategory.mental:
        return Icons.psychology;
      case HabitCategory.creative:
        return Icons.palette;
      case HabitCategory.growth:
        return Icons.trending_up;
    }
  }
}

/// Habit frequency options
enum HabitFrequency {
  daily,
  weekdays,
  weekends,
  threePerWeek,
  custom;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.weekends:
        return 'Weekends';
      case HabitFrequency.threePerWeek:
        return '3x per week';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }

  String get shortName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekdays:
        return 'Mon-Fri';
      case HabitFrequency.weekends:
        return 'Sat-Sun';
      case HabitFrequency.threePerWeek:
        return '3x/week';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case HabitFrequency.daily:
        return 'Build consistency every single day';
      case HabitFrequency.weekdays:
        return 'Monday through Friday';
      case HabitFrequency.weekends:
        return 'Saturday and Sunday only';
      case HabitFrequency.threePerWeek:
        return 'Any 3 days each week';
      case HabitFrequency.custom:
        return 'Choose specific days';
    }
  }
}
