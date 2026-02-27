import 'clip_type.dart';
import 'video_clip.dart';

/// Status of a daily log
enum DailyLogStatus {
  notStarted,
  inProgress,
  clipsComplete,
  vlogCompiled;

  String get displayName {
    switch (this) {
      case DailyLogStatus.notStarted:
        return 'Not started';
      case DailyLogStatus.inProgress:
        return 'In progress';
      case DailyLogStatus.clipsComplete:
        return 'Ready to compile';
      case DailyLogStatus.vlogCompiled:
        return 'Complete';
    }
  }
}

/// Represents a single day's recording session for a habit
class DailyLog {
  final String id;
  final String habitId;
  final DateTime date;
  final int dayNumber;
  final DailyLogStatus status;
  final List<VideoClip> clips;
  final String? compiledVlogPath;
  final String? thumbnailPath;
  final DateTime? completedAt;
  final int xpEarned;

  const DailyLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.dayNumber,
    this.status = DailyLogStatus.notStarted,
    this.clips = const [],
    this.compiledVlogPath,
    this.thumbnailPath,
    this.completedAt,
    this.xpEarned = 0,
  });

  /// Create a new daily log with generated ID
  factory DailyLog.create({
    required String habitId,
    required int dayNumber,
    DateTime? date,
  }) {
    final logDate = date ?? DateTime.now();
    return DailyLog(
      id: '${habitId}_${logDate.toIso8601String().split('T')[0]}',
      habitId: habitId,
      date: DateTime(logDate.year, logDate.month, logDate.day),
      dayNumber: dayNumber,
    );
  }

  /// Check if a specific clip type has been recorded
  bool hasClip(ClipType type) {
    return clips.any((clip) => clip.type == type);
  }

  /// Get clip for a specific type
  VideoClip? getClip(ClipType type) {
    try {
      return clips.firstWhere((clip) => clip.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Check if all clips are recorded
  bool get hasAllClips {
    return hasClip(ClipType.intention) &&
        hasClip(ClipType.evidence) &&
        hasClip(ClipType.reflection);
  }

  /// Get count of recorded clips
  int get clipCount => clips.length;

  /// Get the next clip type to record
  ClipType? get nextClipType {
    if (!hasClip(ClipType.intention)) return ClipType.intention;
    if (!hasClip(ClipType.evidence)) return ClipType.evidence;
    if (!hasClip(ClipType.reflection)) return ClipType.reflection;
    return null;
  }

  /// Progress text like "2/3 clips"
  String get progressText {
    if (status == DailyLogStatus.vlogCompiled) return 'Complete';
    return '$clipCount/3 clips';
  }

  /// Check if this log is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Copy with method for immutable updates
  DailyLog copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    int? dayNumber,
    DailyLogStatus? status,
    List<VideoClip>? clips,
    String? compiledVlogPath,
    String? thumbnailPath,
    DateTime? completedAt,
    int? xpEarned,
  }) {
    return DailyLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      status: status ?? this.status,
      clips: clips ?? this.clips,
      compiledVlogPath: compiledVlogPath ?? this.compiledVlogPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  /// Add a clip to this log
  DailyLog addClip(VideoClip clip) {
    final newClips = List<VideoClip>.from(clips)..add(clip);
    final newStatus = newClips.length >= 3
        ? DailyLogStatus.clipsComplete
        : DailyLogStatus.inProgress;
    return copyWith(
      clips: newClips,
      status: newStatus,
    );
  }

  /// Remove a clip from this log
  DailyLog removeClip(ClipType type) {
    final newClips = clips.where((c) => c.type != type).toList();
    final newStatus = newClips.isEmpty
        ? DailyLogStatus.notStarted
        : DailyLogStatus.inProgress;
    return copyWith(
      clips: newClips,
      status: newStatus,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'dayNumber': dayNumber,
      'status': status.name,
      'clips': clips.map((c) => c.toJson()).toList(),
      'compiledVlogPath': compiledVlogPath,
      'thumbnailPath': thumbnailPath,
      'completedAt': completedAt?.toIso8601String(),
      'xpEarned': xpEarned,
    };
  }

  /// Create from JSON
  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      dayNumber: json['dayNumber'] as int,
      status: DailyLogStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DailyLogStatus.notStarted,
      ),
      clips: (json['clips'] as List<dynamic>?)
              ?.map((c) => VideoClip.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      compiledVlogPath: json['compiledVlogPath'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLog && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
