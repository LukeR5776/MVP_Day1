import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_progress.dart';

/// Persists [UserProgress] to disk as a JSON file.
///
/// Pure I/O class — not a StateNotifier. The reactive state lives in
/// [GamificationNotifier]. This class only handles reading/writing.
class ProgressRepository {
  static const _fileName = 'user_progress.json';

  /// Load progress from disk. Returns a default [UserProgress] if no file exists.
  Future<UserProgress> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        debugPrint('📊 No progress file found — starting fresh');
        return const UserProgress();
      }
      final contents = await file.readAsString();
      final progress = UserProgress.fromJsonString(contents);
      debugPrint(
        '📊 Loaded progress: level ${progress.level}, ${progress.totalXP} XP, '
        '${progress.unlockedAchievementIds.length} achievements',
      );
      return progress;
    } catch (e) {
      debugPrint('❌ Error loading progress: $e');
      return const UserProgress();
    }
  }

  /// Save progress to disk.
  Future<void> save(UserProgress progress) async {
    try {
      final file = await _file();
      await file.writeAsString(progress.toJsonString());
      debugPrint(
        '💾 Saved progress: level ${progress.level}, ${progress.totalXP} XP',
      );
    } catch (e) {
      debugPrint('❌ Error saving progress: $e');
    }
  }

  Future<File> _file() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_fileName');
  }
}
