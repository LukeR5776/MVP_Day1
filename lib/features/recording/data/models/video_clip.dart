import 'clip_type.dart';

/// Represents a single video clip recording
class VideoClip {
  final String id;
  final String habitId;
  final String dailyLogId;
  final ClipType type;
  final String localPath;
  final int durationSeconds;
  final DateTime recordedAt;
  final bool isProcessed;
  final String? processedPath;
  final String? thumbnailPath;

  const VideoClip({
    required this.id,
    required this.habitId,
    required this.dailyLogId,
    required this.type,
    required this.localPath,
    required this.durationSeconds,
    required this.recordedAt,
    this.isProcessed = false,
    this.processedPath,
    this.thumbnailPath,
  });

  /// Create a new video clip with generated ID
  factory VideoClip.create({
    required String habitId,
    required String dailyLogId,
    required ClipType type,
    required String localPath,
    required int durationSeconds,
  }) {
    return VideoClip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: habitId,
      dailyLogId: dailyLogId,
      type: type,
      localPath: localPath,
      durationSeconds: durationSeconds,
      recordedAt: DateTime.now(),
    );
  }

  /// Copy with method for immutable updates
  VideoClip copyWith({
    String? id,
    String? habitId,
    String? dailyLogId,
    ClipType? type,
    String? localPath,
    int? durationSeconds,
    DateTime? recordedAt,
    bool? isProcessed,
    String? processedPath,
    String? thumbnailPath,
  }) {
    return VideoClip(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recordedAt: recordedAt ?? this.recordedAt,
      isProcessed: isProcessed ?? this.isProcessed,
      processedPath: processedPath ?? this.processedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Duration formatted as MM:SS
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'dailyLogId': dailyLogId,
      'type': type.name,
      'localPath': localPath,
      'durationSeconds': durationSeconds,
      'recordedAt': recordedAt.toIso8601String(),
      'isProcessed': isProcessed,
      'processedPath': processedPath,
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Create from JSON
  factory VideoClip.fromJson(Map<String, dynamic> json) {
    return VideoClip(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      dailyLogId: json['dailyLogId'] as String,
      type: ClipType.values.firstWhere((e) => e.name == json['type']),
      localPath: json['localPath'] as String,
      durationSeconds: json['durationSeconds'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      isProcessed: json['isProcessed'] as bool? ?? false,
      processedPath: json['processedPath'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoClip && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
