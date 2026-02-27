import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/daily_log.dart';
import '../data/models/clip_type.dart';
import '../data/repositories/recording_repository.dart';

/// Provider for the recording repository singleton with StateNotifier
/// Initializes on first access to load persisted vlogs from disk
/// UI updates automatically when state changes (vlogs added/removed)
final recordingRepositoryProvider =
    StateNotifierProvider<RecordingRepository, RecordingRepositoryState>((ref) {
  return RecordingRepository();
});

/// Provider for available cameras
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  try {
    return await availableCameras();
  } catch (e) {
    debugPrint('Error getting cameras: $e');
    return [];
  }
});

/// Provider for camera permission status
final cameraPermissionProvider = StateNotifierProvider<CameraPermissionNotifier, PermissionStatus>((ref) {
  return CameraPermissionNotifier();
});

/// Provider for today's daily log for a specific habit
/// Watches the repository state to rebuild when logs are added/updated
final todayLogProvider = Provider.family<DailyLog?, String>((ref, habitId) {
  ref.watch(recordingRepositoryProvider); // Watch state for reactivity
  final repository = ref.read(recordingRepositoryProvider.notifier);
  return repository.getTodayLog(habitId);
});

/// Provider for all logs for a habit
final habitLogsProvider = Provider.family<List<DailyLog>, String>((ref, habitId) {
  ref.watch(recordingRepositoryProvider); // Watch state for reactivity
  final repository = ref.read(recordingRepositoryProvider.notifier);
  return repository.getLogsForHabit(habitId);
});

/// Recording session state
class RecordingSessionState {
  final String? habitId;
  final String? habitName;
  final int dayNumber;
  final ClipType currentClipType;
  final bool isRecording;
  final int recordingSeconds;
  final bool isFrontCamera;
  final DailyLog? dailyLog;
  final String? lastRecordedPath;
  final bool isInitialized;
  final String? error;

  const RecordingSessionState({
    this.habitId,
    this.habitName,
    this.dayNumber = 1,
    this.currentClipType = ClipType.intention,
    this.isRecording = false,
    this.recordingSeconds = 0,
    this.isFrontCamera = true,
    this.dailyLog,
    this.lastRecordedPath,
    this.isInitialized = false,
    this.error,
  });

  RecordingSessionState copyWith({
    String? habitId,
    String? habitName,
    int? dayNumber,
    ClipType? currentClipType,
    bool? isRecording,
    int? recordingSeconds,
    bool? isFrontCamera,
    DailyLog? dailyLog,
    String? lastRecordedPath,
    bool? isInitialized,
    String? error,
  }) {
    return RecordingSessionState(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      dayNumber: dayNumber ?? this.dayNumber,
      currentClipType: currentClipType ?? this.currentClipType,
      isRecording: isRecording ?? this.isRecording,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      dailyLog: dailyLog ?? this.dailyLog,
      lastRecordedPath: lastRecordedPath ?? this.lastRecordedPath,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }

  /// Get formatted recording time
  String get formattedTime {
    final minutes = recordingSeconds ~/ 60;
    final seconds = recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if current clip type has been recorded
  bool get currentClipRecorded {
    return dailyLog?.hasClip(currentClipType) ?? false;
  }

  /// Get the next clip type to record
  ClipType? get nextClipType => dailyLog?.nextClipType ?? currentClipType;
}

/// Notifier for recording session state
final recordingSessionProvider = StateNotifierProvider<RecordingSessionNotifier, RecordingSessionState>((ref) {
  final repository = ref.read(recordingRepositoryProvider.notifier);
  return RecordingSessionNotifier(repository);
});

class RecordingSessionNotifier extends StateNotifier<RecordingSessionState> {
  final RecordingRepository _repository;

  RecordingSessionNotifier(this._repository) : super(const RecordingSessionState());

  /// Initialize a recording session for a habit
  void initSession({
    required String habitId,
    required String habitName,
    required int dayNumber,
  }) {
    final dailyLog = _repository.getOrCreateTodayLog(habitId, dayNumber);
    final nextClip = dailyLog.nextClipType ?? ClipType.intention;

    state = state.copyWith(
      habitId: habitId,
      habitName: habitName,
      dayNumber: dayNumber,
      dailyLog: dailyLog,
      currentClipType: nextClip,
      isFrontCamera: nextClip.preferFrontCamera,
      isInitialized: true,
      error: null,
    );
  }

  /// Start recording
  void startRecording() {
    state = state.copyWith(
      isRecording: true,
      recordingSeconds: 0,
    );
  }

  /// Stop recording
  void stopRecording(String videoPath) {
    state = state.copyWith(
      isRecording: false,
      lastRecordedPath: videoPath,
    );
  }

  /// Update recording time
  void updateRecordingTime(int seconds) {
    state = state.copyWith(recordingSeconds: seconds);
  }

  /// Toggle camera
  void toggleCamera() {
    state = state.copyWith(isFrontCamera: !state.isFrontCamera);
  }

  /// Set clip type
  void setClipType(ClipType type) {
    state = state.copyWith(
      currentClipType: type,
      isFrontCamera: type.preferFrontCamera,
    );
  }

  /// Save the current clip
  Future<void> saveClip() async {
    if (state.lastRecordedPath == null || state.habitId == null) return;

    try {
      final updatedLog = await _repository.addClip(
        habitId: state.habitId!,
        dayNumber: state.dayNumber,
        clipType: state.currentClipType,
        tempVideoPath: state.lastRecordedPath!,
      );

      // Move to next clip type if available
      final nextClip = updatedLog.nextClipType;

      state = state.copyWith(
        dailyLog: updatedLog,
        currentClipType: nextClip ?? state.currentClipType,
        isFrontCamera: nextClip?.preferFrontCamera ?? state.isFrontCamera,
        lastRecordedPath: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to save clip: $e');
    }
  }

  /// Discard the current recording
  void discardRecording() {
    state = state.copyWith(lastRecordedPath: null);
  }

  /// Re-record a specific clip type
  Future<void> reRecord(ClipType type) async {
    if (state.dailyLog == null) return;

    await _repository.removeClip(state.dailyLog!.id, type);

    final updatedLog = _repository.getById(state.dailyLog!.id);
    state = state.copyWith(
      dailyLog: updatedLog,
      currentClipType: type,
      isFrontCamera: type.preferFrontCamera,
    );
  }

  /// Clear session
  void clearSession() {
    state = const RecordingSessionState();
  }

  /// Set error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

/// Notifier for camera permission
class CameraPermissionNotifier extends StateNotifier<PermissionStatus> {
  CameraPermissionNotifier() : super(PermissionStatus.denied);
  // Note: checkPermission() should be called manually after initialization
  // to avoid async operations in constructor

  Future<void> checkPermission() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    // Both must be granted
    if (cameraStatus.isGranted && micStatus.isGranted) {
      state = PermissionStatus.granted;
    } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      state = PermissionStatus.permanentlyDenied;
    } else {
      state = PermissionStatus.denied;
    }
  }

  Future<bool> requestPermission() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      state = PermissionStatus.granted;
      return true;
    } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      state = PermissionStatus.permanentlyDenied;
      return false;
    } else {
      state = PermissionStatus.denied;
      return false;
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
