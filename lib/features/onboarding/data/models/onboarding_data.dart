class OnboardingData {
  final String name;
  final String? goal;
  final List<String> habits;
  final String? frequency;
  final String? timeOfDay;

  const OnboardingData({
    required this.name,
    this.goal,
    required this.habits,
    this.frequency,
    this.timeOfDay,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'goal': goal,
        'habits': habits,
        'frequency': frequency,
        'timeOfDay': timeOfDay,
      };
}
