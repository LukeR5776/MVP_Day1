import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress.dart';

class SupabaseProgressRepository {
  final _db = Supabase.instance.client.from('user_progress');

  Future<UserProgress?> fetch(String userId) async {
    final row = await _db
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return UserProgress.fromJson({
      'totalXP': row['total_xp'],
      'totalVlogsCreated': row['total_vlogs_created'],
      'totalVlogsShared': row['total_vlogs_shared'],
      'totalRecordingSeconds': row['total_recording_seconds'],
      'unlockedAchievementIds':
          (row['unlocked_achievement_ids'] as List<dynamic>).cast<String>(),
    });
  }

  Future<void> upsert(UserProgress progress, String userId) async {
    await _db.upsert({
      'user_id': userId,
      'total_xp': progress.totalXP,
      'total_vlogs_created': progress.totalVlogsCreated,
      'total_vlogs_shared': progress.totalVlogsShared,
      'total_recording_seconds': progress.totalRecordingSeconds,
      'unlocked_achievement_ids': progress.unlockedAchievementIds,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
