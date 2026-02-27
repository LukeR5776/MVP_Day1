import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Dialog showing compilation progress
class CompilationProgressDialog extends StatelessWidget {
  final double progress;
  final String status;
  final String habitName;
  final int dayNumber;

  const CompilationProgressDialog({
    super.key,
    required this.progress,
    required this.status,
    required this.habitName,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.movie_creation,
                color: AppColors.primary,
                size: 40,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Creating Your Vlog',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Day info
            Text(
              '$habitName · Day $dayNumber',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.backgroundSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Progress percentage
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Status text
            Text(
              status,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Show compilation progress dialog
/// Note: Caller is responsible for dismissing the dialog when done
Future<void> showCompilationDialog({
  required BuildContext context,
  required String habitName,
  required int dayNumber,
  required Stream<CompilationProgress> progressStream,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StreamBuilder<CompilationProgress>(
      stream: progressStream,
      initialData: CompilationProgress(0.0, 'Starting...'),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? CompilationProgress(0.0, 'Starting...');

        // Caller handles dismissal explicitly via Navigator.pop()

        return CompilationProgressDialog(
          progress: progress.progress,
          status: progress.status,
          habitName: habitName,
          dayNumber: dayNumber,
        );
      },
    ),
  );
}

/// Progress data model
class CompilationProgress {
  final double progress;
  final String status;

  CompilationProgress(this.progress, this.status);
}
