import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import '../models/daily_log.dart';
import '../models/video_clip.dart';
import '../models/clip_type.dart';
import '../models/vlog.dart';
import '../services/compilation_service.dart';

/// State container for RecordingRepository
class RecordingRepositoryState {
  final Map<String, DailyLog> dailyLogs;
  final Map<String, Vlog> vlogs;
  final bool isInitialized;

  const RecordingRepositoryState({
    this.dailyLogs = const {},
    this.vlogs = const {},
    this.isInitialized = false,
  });

  RecordingRepositoryState copyWith({
    Map<String, DailyLog>? dailyLogs,
    Map<String, Vlog>? vlogs,
    bool? isInitialized,
  }) {
    return RecordingRepositoryState(
      dailyLogs: dailyLogs ?? this.dailyLogs,
      vlogs: vlogs ?? this.vlogs,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Repository for managing daily logs and video clips
///
/// This repository uses StateNotifier for Riverpod reactivity:
/// - Vlogs are saved to a JSON index file on disk
/// - On initialization, vlogs are loaded from disk
/// - StateNotifier pattern ensures UI updates when state changes
class RecordingRepository extends StateNotifier<RecordingRepositoryState> {
  final CompilationService _compilationService = CompilationService();

  RecordingRepository() : super(const RecordingRepositoryState()) {
    initialize();
  }

  /// Initialize the repository - loads persisted vlogs from disk
  Future<void> initialize() async {
    if (state.isInitialized) return;

    await _loadVlogsFromDisk();
    state = state.copyWith(isInitialized: true);
    debugPrint('📦 RecordingRepository initialized with ${state.vlogs.length} vlogs');
  }

  /// Ensure repository is initialized before operations
  Future<void> _ensureInitialized() async {
    if (!state.isInitialized) {
      await initialize();
    }
  }

  /// Save vlogs index to disk for persistence
  Future<void> _saveVlogsIndex() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final indexFile = File('${appDir.path}/vlogs_index.json');
      final vlogsList = state.vlogs.values.map((v) => v.toJson()).toList();
      await indexFile.writeAsString(jsonEncode(vlogsList));
      debugPrint('💾 Saved ${vlogsList.length} vlogs to index');
    } catch (e) {
      debugPrint('❌ Error saving vlogs index: $e');
    }
  }

  /// Load vlogs from disk on initialization
  Future<void> _loadVlogsFromDisk() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final indexFile = File('${appDir.path}/vlogs_index.json');

      if (!await indexFile.exists()) {
        debugPrint('📂 No vlogs index found, starting fresh');
        return;
      }

      final content = await indexFile.readAsString();
      final List<dynamic> vlogsList = jsonDecode(content);

      final Map<String, Vlog> loadedVlogs = {};
      int loadedCount = 0;
      int skippedCount = 0;

      for (final json in vlogsList) {
        try {
          final vlog = Vlog.fromJson(json as Map<String, dynamic>);
          // Verify video file still exists before adding to memory
          if (await File(vlog.videoPath).exists()) {
            loadedVlogs[vlog.id] = vlog;
            loadedCount++;
          } else {
            skippedCount++;
            debugPrint('⚠️ Skipped vlog ${vlog.id} - video file missing');
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing vlog: $e');
          skippedCount++;
        }
      }

      debugPrint('📂 Loaded $loadedCount vlogs from disk ($skippedCount skipped)');

      // Update state with loaded vlogs
      state = state.copyWith(vlogs: loadedVlogs);

      // If we skipped any, save the cleaned index
      if (skippedCount > 0) {
        await _saveVlogsIndex();
      }
    } catch (e) {
      debugPrint('❌ Error loading vlogs from disk: $e');
    }
  }

  /// Get or create today's daily log for a habit
  DailyLog getOrCreateTodayLog(String habitId, int dayNumber) {
    final today = DateTime.now();
    final dateKey = '${habitId}_${today.toIso8601String().split('T')[0]}';

    if (state.dailyLogs.containsKey(dateKey)) {
      return state.dailyLogs[dateKey]!;
    }

    final newLog = DailyLog.create(
      habitId: habitId,
      dayNumber: dayNumber,
      date: today,
    );

    // Update state with new log
    state = state.copyWith(
      dailyLogs: {...state.dailyLogs, dateKey: newLog},
    );

    return newLog;
  }

  /// Get a daily log by ID
  DailyLog? getById(String id) {
    return state.dailyLogs[id];
  }

  /// Get all daily logs for a habit
  List<DailyLog> getLogsForHabit(String habitId) {
    return state.dailyLogs.values
        .where((log) => log.habitId == habitId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get today's log for a habit if it exists
  DailyLog? getTodayLog(String habitId) {
    final today = DateTime.now();
    final dateKey = '${habitId}_${today.toIso8601String().split('T')[0]}';
    return state.dailyLogs[dateKey];
  }

  /// Add a clip to a daily log
  Future<DailyLog> addClip({
    required String habitId,
    required int dayNumber,
    required ClipType clipType,
    required String tempVideoPath,
  }) async {
    // Ensure repository is initialized before adding clips
    await _ensureInitialized();

    // Get or create today's log
    final log = getOrCreateTodayLog(habitId, dayNumber);

    // Get permanent storage path
    final permanentPath = await _saveClipPermanently(
      tempVideoPath,
      habitId,
      log.id,
      clipType,
    );

    // Get video duration (simplified - would use video_player in real app)
    final duration = await _getVideoDuration(permanentPath);

    // Create the clip
    final clip = VideoClip.create(
      habitId: habitId,
      dailyLogId: log.id,
      type: clipType,
      localPath: permanentPath,
      durationSeconds: duration,
    );

    // Update the log with the new clip
    final updatedLog = log.addClip(clip);

    // Update state
    state = state.copyWith(
      dailyLogs: {...state.dailyLogs, log.id: updatedLog},
    );

    return updatedLog;
  }

  /// Remove a clip from a daily log
  Future<void> removeClip(String logId, ClipType clipType) async {
    final log = state.dailyLogs[logId];
    if (log == null) return;

    // Get the clip to delete
    final clip = log.getClip(clipType);
    if (clip != null) {
      // Delete the file
      try {
        final file = File(clip.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting clip file: $e');
      }
    }

    // Update the log
    final updatedLog = log.removeClip(clipType);

    // Update state
    state = state.copyWith(
      dailyLogs: {...state.dailyLogs, logId: updatedLog},
    );
  }

  /// Save a clip from temp location to permanent storage
  Future<String> _saveClipPermanently(
    String tempPath,
    String habitId,
    String logId,
    ClipType clipType,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final clipsDir = Directory('${appDir.path}/clips/$habitId');

    if (!await clipsDir.exists()) {
      await clipsDir.create(recursive: true);
    }

    final fileName = '${logId}_${clipType.name}.mp4';
    final permanentPath = '${clipsDir.path}/$fileName';

    // Copy file to permanent location
    final tempFile = File(tempPath);
    await tempFile.copy(permanentPath);

    // Save to photo library - must await to ensure it completes before function returns
    try {
      final result = await ImageGallerySaver.saveFile(
        permanentPath,
        isReturnPathOfIOS: true,
        name: fileName,
      );
      debugPrint('✅ Clip saved to photo library: $result');
    } catch (e) {
      debugPrint('⚠️ Could not save to photo library: $e');
      // Don't rethrow - clip is already saved to app storage
    }

    // Delete temp file
    try {
      await tempFile.delete();
    } catch (e) {
      debugPrint('Could not delete temp file: $e');
    }

    return permanentPath;
  }

  /// Get actual video duration using FFprobe
  Future<int> _getVideoDuration(String path) async {
    try {
      final session = await FFprobeKit.getMediaInformation(path);
      final mediaInfo = session.getMediaInformation();

      if (mediaInfo != null) {
        final durationStr = mediaInfo.getDuration();
        if (durationStr != null) {
          final duration = double.tryParse(durationStr);
          if (duration != null) {
            debugPrint('📹 Video duration: ${duration.toInt()}s for $path');
            return duration.toInt();
          }
        }
      }

      // Fallback: estimate from file size if FFprobe fails
      debugPrint('⚠️ Could not get duration from FFprobe, estimating...');
      final file = File(path);
      final size = await file.length();
      return (size / (1024 * 1024) * 5).round().clamp(1, 300);
    } catch (e) {
      debugPrint('❌ Error getting video duration: $e');
      return 10; // Default 10 seconds
    }
  }

  /// Mark a daily log as compiled
  void markAsCompiled(String logId, String vlogPath, String? thumbnailPath) {
    final log = state.dailyLogs[logId];
    if (log == null) return;

    final updatedLog = log.copyWith(
      status: DailyLogStatus.vlogCompiled,
      compiledVlogPath: vlogPath,
      thumbnailPath: thumbnailPath,
      completedAt: DateTime.now(),
    );

    // Update state
    state = state.copyWith(
      dailyLogs: {...state.dailyLogs, logId: updatedLog},
    );
  }

  /// Delete a daily log and all its clips
  Future<void> deleteLog(String logId) async {
    final log = state.dailyLogs[logId];
    if (log == null) return;

    // Delete all clip files
    for (final clip in log.clips) {
      try {
        final file = File(clip.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting clip: $e');
      }
    }

    // Delete compiled vlog if exists
    if (log.compiledVlogPath != null) {
      try {
        final file = File(log.compiledVlogPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting vlog: $e');
      }
    }

    // Update state (remove log)
    final newDailyLogs = Map<String, DailyLog>.from(state.dailyLogs);
    newDailyLogs.remove(logId);
    state = state.copyWith(dailyLogs: newDailyLogs);
  }

  /// Compile a daily log into a vlog
  Future<Vlog> compileLog({
    required String logId,
    required String habitName,
    required Function(double progress, String status) onProgress,
  }) async {
    final log = state.dailyLogs[logId];
    if (log == null) {
      throw Exception('Daily log not found');
    }

    // Compile the vlog
    final vlog = await _compilationService.compileDailyLog(
      dailyLog: log,
      habitName: habitName,
      onProgress: onProgress,
    );

    // Update state with new vlog
    state = state.copyWith(
      vlogs: {...state.vlogs, vlog.id: vlog},
      dailyLogs: {
        ...state.dailyLogs,
        logId: log.copyWith(
          status: DailyLogStatus.vlogCompiled,
          compiledVlogPath: vlog.videoPath,
          thumbnailPath: vlog.thumbnailPath,
          completedAt: DateTime.now(),
        ),
      },
    );

    // Persist vlogs to disk
    await _saveVlogsIndex();

    return vlog;
  }

  /// Get all vlogs
  List<Vlog> getAllVlogs() {
    return state.vlogs.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get vlogs for a specific habit
  List<Vlog> getVlogsForHabit(String habitId) {
    return state.vlogs.values
        .where((vlog) => vlog.habitId == habitId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get a vlog by ID
  Vlog? getVlogById(String id) {
    return state.vlogs[id];
  }

  /// Mark vlog as shared
  Future<void> markVlogAsShared(String vlogId) async {
    final vlog = state.vlogs[vlogId];
    if (vlog != null) {
      // Update state
      state = state.copyWith(
        vlogs: {...state.vlogs, vlogId: vlog.markAsShared()},
      );

      // Persist the change
      await _saveVlogsIndex();
    }
  }

  /// Delete a vlog
  Future<void> deleteVlog(String vlogId) async {
    final vlog = state.vlogs[vlogId];
    if (vlog == null) return;

    await _compilationService.deleteVlog(vlog);

    // Update state (remove vlog)
    final newVlogs = Map<String, Vlog>.from(state.vlogs);
    newVlogs.remove(vlogId);
    state = state.copyWith(vlogs: newVlogs);

    // Persist the change
    await _saveVlogsIndex();
  }
}
