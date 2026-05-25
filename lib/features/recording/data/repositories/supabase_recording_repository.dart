import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vlog.dart';
import '../models/daily_log.dart';

class SupabaseRecordingRepository {
  final _vlogs = Supabase.instance.client.from('vlogs');
  final _logs = Supabase.instance.client.from('daily_logs');

  Future<void> upsertVlog(Vlog vlog, String userId) async {
    await _vlogs.upsert({
      'id': vlog.id,
      'user_id': userId,
      'habit_id': vlog.habitId,
      'habit_name': vlog.habitName,
      'day_number': vlog.dayNumber,
      'date': vlog.date.toIso8601String().split('T')[0],
      'duration_seconds': vlog.durationSeconds,
      'file_size_bytes': vlog.fileSizeBytes,
      'is_shared': vlog.isShared,
      'shared_at': vlog.sharedAt?.toIso8601String(),
      'created_at': vlog.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateVlogShared(String vlogId) async {
    await _vlogs.update({
      'is_shared': true,
      'shared_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', vlogId);
  }

  Future<void> deleteVlog(String vlogId) async {
    await _vlogs.delete().eq('id', vlogId);
  }

  Future<void> upsertDailyLog(DailyLog log, String userId) async {
    await _logs.upsert({
      'id': log.id,
      'user_id': userId,
      'habit_id': log.habitId,
      'date': log.date.toIso8601String().split('T')[0],
      'day_number': log.dayNumber,
      'status': log.status.name,
      'completed_at': log.completedAt?.toIso8601String(),
      'xp_earned': log.xpEarned,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchDailyLogs(String userId) async {
    return await _logs
        .select()
        .eq('user_id', userId)
        .eq('status', 'vlogCompiled')
        .order('date', ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchVlogMetadata(String userId) async {
    return await _vlogs
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
