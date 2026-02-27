import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../models/daily_log.dart';
import '../models/vlog.dart';
import '../models/clip_type.dart';

/// Service for compiling video clips into a single vlog using FFmpeg
///
/// This service uses ffmpeg_kit_flutter_new to:
/// 1. Concatenate the 3 clips (Intention, Evidence, Reflection) into one video
/// 2. Generate a thumbnail from the compiled video
/// 3. Save the compiled video to the camera roll
class CompilationService {
  /// Compile a daily log's clips into a single vlog video
  Future<Vlog> compileDailyLog({
    required DailyLog dailyLog,
    required String habitName,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      onProgress(0.05, 'Validating clips...');

      // Validate that all clips are present
      if (!dailyLog.hasAllClips) {
        throw Exception('Not all clips are recorded');
      }

      // Get clips in order: Intention → Evidence → Reflection
      final intentionClip = dailyLog.getClip(ClipType.intention);
      final evidenceClip = dailyLog.getClip(ClipType.evidence);
      final reflectionClip = dailyLog.getClip(ClipType.reflection);

      if (intentionClip == null ||
          evidenceClip == null ||
          reflectionClip == null) {
        throw Exception('Missing clips');
      }

      final clips = [intentionClip, evidenceClip, reflectionClip];

      // Verify all clip files exist
      onProgress(0.1, 'Checking files...');
      for (final clip in clips) {
        final file = File(clip.localPath);
        if (!await file.exists()) {
          throw Exception('Clip file not found: ${clip.localPath}');
        }
      }

      onProgress(0.15, 'Preparing compilation...');

      // Create output directories if needed
      final appDir = await getApplicationDocumentsDirectory();
      final vlogsDir = Directory('${appDir.path}/vlogs');
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');
      final tempDir = Directory('${appDir.path}/temp');

      for (final dir in [vlogsDir, thumbnailsDir, tempDir]) {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }

      // Calculate estimated duration for progress tracking (sum of clips)
      final estimatedDuration = intentionClip.durationSeconds +
          evidenceClip.durationSeconds +
          reflectionClip.durationSeconds;

      // Output paths
      final outputFileName =
          'day${dailyLog.dayNumber}_${habitName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final outputPath = '${vlogsDir.path}/$outputFileName';
      final thumbnailPath =
          '${thumbnailsDir.path}/${dailyLog.id}_thumb.jpg';
      final concatListPath = '${tempDir.path}/concat_${dailyLog.id}.txt';

      onProgress(0.2, 'Creating concat list...');

      // Create FFmpeg concat demuxer file
      final concatFile = File(concatListPath);
      final concatContent = clips.map((c) => "file '${c.localPath}'").join('\n');
      await concatFile.writeAsString(concatContent);

      debugPrint('📝 Concat list created: $concatListPath');
      debugPrint('   Content:\n$concatContent');

      onProgress(0.25, 'Compiling video...');

      // Enable FFmpeg statistics for progress tracking
      FFmpegKitConfig.enableStatisticsCallback((Statistics statistics) {
        final timeMs = statistics.getTime();
        if (timeMs > 0 && estimatedDuration > 0) {
          // Calculate progress (25% to 85% of total progress)
          final compilationProgress = (timeMs / 1000) / estimatedDuration;
          final overallProgress = 0.25 + (compilationProgress * 0.6);
          onProgress(
            overallProgress.clamp(0.25, 0.85),
            'Compiling video... ${(compilationProgress * 100).toInt()}%',
          );
        }
      });

      // FFmpeg command to concatenate videos
      // Using concat demuxer for fast concatenation without re-encoding
      final ffmpegCommand =
          '-f concat -safe 0 -i "$concatListPath" -c copy -movflags +faststart "$outputPath"';

      debugPrint('🎬 Running FFmpeg: ffmpeg $ffmpegCommand');

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      // Clean up concat list file
      try {
        await concatFile.delete();
      } catch (e) {
        debugPrint('Could not delete concat file: $e');
      }

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getAllLogsAsString();
        debugPrint('❌ FFmpeg failed with code $returnCode');
        debugPrint('   Logs: $logs');

        // If concat demuxer fails (codec mismatch), try with re-encoding
        onProgress(0.3, 'Re-encoding video...');
        final reencodeCommand =
            '-f concat -safe 0 -i "$concatListPath" -c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -movflags +faststart "$outputPath"';

        // Recreate concat file
        await concatFile.writeAsString(concatContent);

        final reencodeSession = await FFmpegKit.execute(reencodeCommand);
        final reencodeReturnCode = await reencodeSession.getReturnCode();

        // Clean up again
        try {
          await concatFile.delete();
        } catch (e) {
          debugPrint('Could not delete concat file: $e');
        }

        if (!ReturnCode.isSuccess(reencodeReturnCode)) {
          final reencodeLogs = await reencodeSession.getAllLogsAsString();
          throw Exception('FFmpeg re-encoding failed: $reencodeLogs');
        }
      }

      // Verify output file exists
      final outputFile = File(outputPath);
      if (!await outputFile.exists()) {
        throw Exception('Compiled video file was not created');
      }

      final fileSize = await outputFile.length();
      debugPrint('✅ Video compiled: $outputPath (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB)');

      onProgress(0.85, 'Generating thumbnail...');

      // Generate thumbnail from the first second of the video
      String? finalThumbnailPath;
      try {
        final thumbCommand =
            '-i "$outputPath" -ss 00:00:01 -vframes 1 -q:v 2 "$thumbnailPath"';

        debugPrint('🖼️ Generating thumbnail: ffmpeg $thumbCommand');

        final thumbSession = await FFmpegKit.execute(thumbCommand);
        final thumbReturnCode = await thumbSession.getReturnCode();

        if (ReturnCode.isSuccess(thumbReturnCode)) {
          final thumbFile = File(thumbnailPath);
          if (await thumbFile.exists()) {
            finalThumbnailPath = thumbnailPath;
            debugPrint('✅ Thumbnail generated: $thumbnailPath');
          }
        } else {
          debugPrint('⚠️ Thumbnail generation failed, continuing without thumbnail');
        }
      } catch (e) {
        debugPrint('⚠️ Could not generate thumbnail: $e');
      }

      onProgress(0.9, 'Saving to camera roll...');

      // Save the compiled video to camera roll
      try {
        final result = await ImageGallerySaver.saveFile(
          outputPath,
          isReturnPathOfIOS: true,
          name: 'Day${dailyLog.dayNumber}_${habitName.replaceAll(' ', '_')}',
        );
        debugPrint('✅ Saved to camera roll: $result');
      } catch (e) {
        debugPrint('⚠️ Could not save to camera roll: $e');
        // Don't throw - camera roll save is optional
      }

      // Get actual duration from the compiled video file using FFprobe
      final actualDuration = await _getActualVideoDuration(outputPath);

      onProgress(1.0, 'Complete!');

      debugPrint('🎉 Day ${dailyLog.dayNumber} compiled successfully');
      debugPrint('   Output: $outputPath');
      debugPrint('   Duration (estimated): ${estimatedDuration}s');
      debugPrint('   Duration (actual): ${actualDuration}s');
      debugPrint('   Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB');

      // Create vlog model with actual duration
      return Vlog.create(
        habitId: dailyLog.habitId,
        habitName: habitName,
        dayNumber: dailyLog.dayNumber,
        date: dailyLog.date,
        videoPath: outputPath,
        thumbnailPath: finalThumbnailPath,
        durationSeconds: actualDuration,
        fileSizeBytes: fileSize,
      );
    } catch (e) {
      debugPrint('❌ Compilation error: $e');
      rethrow;
    }
  }

  /// Get actual duration from compiled video file using FFprobe
  Future<int> _getActualVideoDuration(String videoPath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(videoPath);
      final mediaInfo = session.getMediaInformation();

      if (mediaInfo != null) {
        final durationStr = mediaInfo.getDuration();
        if (durationStr != null) {
          final duration = double.tryParse(durationStr);
          if (duration != null) {
            debugPrint('📹 Compiled video duration: ${duration.toInt()}s for $videoPath');
            return duration.toInt();
          }
        }
      }

      // Fallback to file size estimation if FFprobe fails
      debugPrint('⚠️ Could not probe compiled video, estimating from file size...');
      final file = File(videoPath);
      final size = await file.length();
      return (size / (1024 * 1024) * 5).round().clamp(1, 300);
    } catch (e) {
      debugPrint('❌ Error getting compiled video duration: $e');
      return 30; // Default 30 seconds for compiled video
    }
  }

  /// Delete a vlog and its associated files
  Future<void> deleteVlog(Vlog vlog) async {
    try {
      // Delete the compiled video file
      final videoFile = File(vlog.videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
        debugPrint('✅ Deleted video: ${vlog.videoPath}');
      }

      // Delete the thumbnail if it exists
      if (vlog.thumbnailPath != null) {
        final thumbFile = File(vlog.thumbnailPath!);
        if (await thumbFile.exists()) {
          await thumbFile.delete();
          debugPrint('✅ Deleted thumbnail: ${vlog.thumbnailPath}');
        }
      }

      debugPrint('✅ Vlog deleted: ${vlog.id}');
    } catch (e) {
      debugPrint('❌ Error deleting vlog: $e');
      rethrow;
    }
  }

  /// Get video duration using FFprobe (for future use)
  Future<int> getVideoDuration(String videoPath) async {
    try {
      // For now, estimate based on file size
      // In a future version, use FFprobeKit.getMediaInformation
      final file = File(videoPath);
      if (!await file.exists()) return 0;

      final size = await file.length();
      // Rough estimate: ~1MB per 5 seconds of video at typical mobile quality
      return (size / (1024 * 1024) * 5).round().clamp(1, 3600);
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      return 0;
    }
  }
}
