import 'dart:convert';

/// Tracks the user's overall gamification progress.
class UserProgress {
  final int totalXP;
  final List<String> unlockedAchievementIds;
  final int totalVlogsCreated;
  final int totalVlogsShared;
  final int totalRecordingSeconds;

  const UserProgress({
    this.totalXP = 0,
    this.unlockedAchievementIds = const [],
    this.totalVlogsCreated = 0,
    this.totalVlogsShared = 0,
    this.totalRecordingSeconds = 0,
  });

  // ── Level computation ────────────────────────────────────────────────────────

  /// Cumulative XP needed to *reach* level [n] (level 1 = 0 XP).
  static int xpThresholdForLevel(int n) {
    if (n <= 1) return 0;
    int total = 0;
    for (int i = 1; i < n; i++) {
      total += (100 * _pow15(i)).floor();
    }
    return total;
  }

  static double _pow15(int i) => i * _sqrt(i);
  static double _sqrt(int i) {
    // Simple integer square root via dart:math approximation
    double x = i.toDouble();
    // Newton's method for sqrt
    if (x == 0) return 0;
    double r = x;
    for (int k = 0; k < 20; k++) {
      r = (r + x / r) / 2.0;
    }
    return r;
  }

  /// Current level (1-based).
  int get level {
    int lvl = 1;
    while (xpThresholdForLevel(lvl + 1) <= totalXP) {
      lvl++;
    }
    return lvl;
  }

  /// Human-readable title for the current level.
  String get levelTitle {
    final lvl = level;
    if (lvl >= 50) return 'Main Character 👑';
    if (lvl >= 40) return 'Legend';
    if (lvl >= 30) return 'Champion';
    if (lvl >= 20) return 'Warrior';
    if (lvl >= 15) return 'Dedicated';
    if (lvl >= 10) return 'Rising Star';
    if (lvl >= 5) return 'Apprentice';
    return 'Beginner';
  }

  /// Cumulative XP at the start of the current level.
  int get xpForCurrentLevel => xpThresholdForLevel(level);

  /// Cumulative XP required to reach the next level.
  int get xpForNextLevel => xpThresholdForLevel(level + 1);

  /// XP earned within the current level (resets to 0 at each level boundary).
  int get xpProgressInCurrentLevel => totalXP - xpForCurrentLevel;

  /// XP needed within the current level to advance.
  int get xpNeededForNextLevel => xpForNextLevel - xpForCurrentLevel;

  /// Progress fraction 0.0–1.0 within the current level.
  double get levelProgressFraction {
    final needed = xpNeededForNextLevel;
    if (needed <= 0) return 1.0;
    return (xpProgressInCurrentLevel / needed).clamp(0.0, 1.0);
  }

  // ── Serialization ────────────────────────────────────────────────────────────

  UserProgress copyWith({
    int? totalXP,
    List<String>? unlockedAchievementIds,
    int? totalVlogsCreated,
    int? totalVlogsShared,
    int? totalRecordingSeconds,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      totalVlogsCreated: totalVlogsCreated ?? this.totalVlogsCreated,
      totalVlogsShared: totalVlogsShared ?? this.totalVlogsShared,
      totalRecordingSeconds:
          totalRecordingSeconds ?? this.totalRecordingSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXP': totalXP,
        'unlockedAchievementIds': unlockedAchievementIds,
        'totalVlogsCreated': totalVlogsCreated,
        'totalVlogsShared': totalVlogsShared,
        'totalRecordingSeconds': totalRecordingSeconds,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
        unlockedAchievementIds:
            (json['unlockedAchievementIds'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
        totalVlogsCreated: (json['totalVlogsCreated'] as num?)?.toInt() ?? 0,
        totalVlogsShared: (json['totalVlogsShared'] as num?)?.toInt() ?? 0,
        totalRecordingSeconds:
            (json['totalRecordingSeconds'] as num?)?.toInt() ?? 0,
      );

  factory UserProgress.fromJsonString(String source) =>
      UserProgress.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
