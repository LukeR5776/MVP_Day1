import 'habit_enums.dart';

/// Preset habit template for quick habit creation
class HabitTemplate {
  final String name;
  final String description;
  final HabitCategory category;
  final HabitFrequency defaultFrequency;

  const HabitTemplate({
    required this.name,
    required this.description,
    required this.category,
    this.defaultFrequency = HabitFrequency.daily,
  });
}

/// All preset habit templates organized by category
class HabitTemplates {
  static const List<HabitTemplate> physical = [
    HabitTemplate(
      name: 'Cold Showers',
      description: 'Start every day with a cold shower',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'Morning Workout',
      description: 'Exercise first thing in the morning',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: '10K Steps',
      description: 'Walk 10,000 steps every day',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'Stretching',
      description: '5-minute stretch routine',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'No Junk Food',
      description: 'Avoid processed/fast food',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'Drink Water',
      description: '8 glasses of water daily',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'Sleep by 11',
      description: 'In bed by 11 PM',
      category: HabitCategory.physical,
    ),
    HabitTemplate(
      name: 'Wake at 6',
      description: 'Rise at 6 AM consistently',
      category: HabitCategory.physical,
    ),
  ];

  static const List<HabitTemplate> mental = [
    HabitTemplate(
      name: 'Meditation',
      description: '10 minutes of mindfulness',
      category: HabitCategory.mental,
    ),
    HabitTemplate(
      name: 'Reading',
      description: 'Read for 20 minutes',
      category: HabitCategory.mental,
    ),
    HabitTemplate(
      name: 'Journaling',
      description: 'Write in journal daily',
      category: HabitCategory.mental,
    ),
    HabitTemplate(
      name: 'No Phone AM',
      description: 'No phone for first hour',
      category: HabitCategory.mental,
    ),
    HabitTemplate(
      name: 'Gratitude',
      description: 'Write 3 things you\'re grateful for',
      category: HabitCategory.mental,
    ),
    HabitTemplate(
      name: 'Deep Work',
      description: '2 hours of focused work',
      category: HabitCategory.mental,
      defaultFrequency: HabitFrequency.weekdays,
    ),
  ];

  static const List<HabitTemplate> creative = [
    HabitTemplate(
      name: 'Draw/Sketch',
      description: 'Create one drawing',
      category: HabitCategory.creative,
    ),
    HabitTemplate(
      name: 'Write',
      description: 'Write 500 words',
      category: HabitCategory.creative,
    ),
    HabitTemplate(
      name: 'Music Practice',
      description: '30 minutes instrument practice',
      category: HabitCategory.creative,
    ),
    HabitTemplate(
      name: 'Photography',
      description: 'Take one intentional photo',
      category: HabitCategory.creative,
    ),
    HabitTemplate(
      name: 'Content Creation',
      description: 'Create one piece of content',
      category: HabitCategory.creative,
    ),
    HabitTemplate(
      name: 'Coding',
      description: 'Work on coding project',
      category: HabitCategory.creative,
    ),
  ];

  static const List<HabitTemplate> growth = [
    HabitTemplate(
      name: 'Language Learning',
      description: '15 min language practice',
      category: HabitCategory.growth,
    ),
    HabitTemplate(
      name: 'Networking',
      description: 'Reach out to one person',
      category: HabitCategory.growth,
      defaultFrequency: HabitFrequency.weekdays,
    ),
    HabitTemplate(
      name: 'Skill Practice',
      description: 'Practice a specific skill',
      category: HabitCategory.growth,
    ),
    HabitTemplate(
      name: 'Course Work',
      description: 'Complete course lesson',
      category: HabitCategory.growth,
    ),
    HabitTemplate(
      name: 'Public Speaking',
      description: 'Practice speaking',
      category: HabitCategory.growth,
      defaultFrequency: HabitFrequency.threePerWeek,
    ),
    HabitTemplate(
      name: 'Side Project',
      description: 'Work on side business',
      category: HabitCategory.growth,
    ),
  ];

  /// Get all templates
  static List<HabitTemplate> get all => [
        ...physical,
        ...mental,
        ...creative,
        ...growth,
      ];

  /// Get templates by category
  static List<HabitTemplate> byCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.physical:
        return physical;
      case HabitCategory.mental:
        return mental;
      case HabitCategory.creative:
        return creative;
      case HabitCategory.growth:
        return growth;
    }
  }
}
