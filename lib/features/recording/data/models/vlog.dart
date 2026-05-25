import 'package:uuid/uuid.dart';

/// Represents a compiled vlog from a daily log
class Vlog {
  final String id;
  final String habitId;
  final String habitName;
  final int dayNumber;
  final DateTime date;
  final String videoPath;
  final String? thumbnailPath;
  final int durationSeconds;
  final int fileSizeBytes;
  final DateTime createdAt;
  final bool isShared;
  final DateTime? sharedAt;
  final bool isAvailableLocally;

  const Vlog({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.dayNumber,
    required this.date,
    required this.videoPath,
    this.thumbnailPath,
    required this.durationSeconds,
    required this.fileSizeBytes,
    required this.createdAt,
    this.isShared = false,
    this.sharedAt,
    this.isAvailableLocally = true,
  });

  /// Create a new vlog
  factory Vlog.create({
    required String habitId,
    required String habitName,
    required int dayNumber,
    required DateTime date,
    required String videoPath,
    String? thumbnailPath,
    required int durationSeconds,
    required int fileSizeBytes,
  }) {
    return Vlog(
      id: const Uuid().v4(),
      habitId: habitId,
      habitName: habitName,
      dayNumber: dayNumber,
      date: date,
      videoPath: videoPath,
      thumbnailPath: thumbnailPath,
      durationSeconds: durationSeconds,
      fileSizeBytes: fileSizeBytes,
      createdAt: DateTime.now(),
      isShared: false,
    );
  }

  /// Copy with modifications
  Vlog copyWith({
    String? id,
    String? habitId,
    String? habitName,
    int? dayNumber,
    DateTime? date,
    String? videoPath,
    String? thumbnailPath,
    int? durationSeconds,
    int? fileSizeBytes,
    DateTime? createdAt,
    bool? isShared,
    DateTime? sharedAt,
    bool? isAvailableLocally,
  }) {
    return Vlog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      videoPath: videoPath ?? this.videoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
      sharedAt: sharedAt ?? this.sharedAt,
      isAvailableLocally: isAvailableLocally ?? this.isAvailableLocally,
    );
  }

  /// Get formatted duration
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Mark as shared
  Vlog markAsShared() {
    return copyWith(
      isShared: true,
      sharedAt: DateTime.now(),
    );
  }

  /// Create from JSON (for persistence)
  factory Vlog.fromJson(Map<String, dynamic> json) {
    return Vlog(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      dayNumber: json['dayNumber'] as int,
      date: DateTime.parse(json['date'] as String),
      videoPath: json['videoPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      durationSeconds: json['durationSeconds'] as int,
      fileSizeBytes: json['fileSizeBytes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isShared: json['isShared'] as bool? ?? false,
      sharedAt: json['sharedAt'] != null
          ? DateTime.parse(json['sharedAt'] as String)
          : null,
    );
  }

  /// Create from a Supabase `vlogs` row (snake_case keys, no video path).
  factory Vlog.fromSupabaseRow(Map<String, dynamic> row) {
    return Vlog(
      id: row['id'] as String,
      habitId: row['habit_id'] as String,
      habitName: row['habit_name'] as String,
      dayNumber: row['day_number'] as int,
      date: DateTime.parse(row['date'] as String),
      videoPath: '',
      thumbnailPath: null,
      durationSeconds: row['duration_seconds'] as int,
      fileSizeBytes: row['file_size_bytes'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      isShared: row['is_shared'] as bool? ?? false,
      sharedAt: row['shared_at'] != null
          ? DateTime.parse(row['shared_at'] as String)
          : null,
      isAvailableLocally: false,
    );
  }

  /// Convert to JSON (for persistence)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'habitName': habitName,
      'dayNumber': dayNumber,
      'date': date.toIso8601String(),
      'videoPath': videoPath,
      'thumbnailPath': thumbnailPath,
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'isShared': isShared,
      'sharedAt': sharedAt?.toIso8601String(),
    };
  }
}
