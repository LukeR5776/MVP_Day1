import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../providers/recording_provider.dart';
import '../widgets/clip_progress_bar.dart';
import '../widgets/day_overlay.dart';
import '../widgets/record_button.dart';
import '../widgets/clip_type_selector.dart';
import '../widgets/compilation_progress_dialog.dart';
import '../../../habits/providers/habits_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../gamification/presentation/widgets/xp_reward_popup.dart';
import '../../../gamification/presentation/widgets/level_up_overlay.dart';
import '../../../gamification/presentation/widgets/achievement_toast.dart';

/// Main camera recording screen
class CameraScreen extends ConsumerStatefulWidget {
  final String habitId;
  final String habitName;
  final int dayNumber;
  final Color habitColor;

  const CameraScreen({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.dayNumber,
    this.habitColor = AppColors.primary,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  Timer? _recordingTimer;
  bool _showClipTypeSelector = false;
  bool _isInitializing = false; // Prevent duplicate camera initialization

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize directly - no need for addPostFrameCallback
    _initializeSession();
  }

  @override
  void dispose() {
    debugPrint('🎥 Disposing camera screen...');
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      // Only re-initialize if permission is still granted
      final status = ref.read(cameraPermissionProvider);
      if (mounted && status.isGranted) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeSession() async {
    // Initialize the recording session.
    // Wrapped in try-catch: if the session notifier fails for any reason,
    // we still want the camera to initialize so the screen doesn't get stuck.
    try {
      ref.read(recordingSessionProvider.notifier).initSession(
            habitId: widget.habitId,
            habitName: widget.habitName,
            dayNumber: widget.dayNumber,
          );
    } catch (e) {
      debugPrint('❌ Session init error: $e');
    }

    // Request permissions (shows native dialog if needed)
    final granted = await ref.read(cameraPermissionProvider.notifier).requestPermission();

    // If granted, initialize camera immediately
    if (mounted && granted) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Prevent duplicate initialization
    if (_isInitializing) {
      debugPrint('🎥 Already initializing camera, skipping...');
      return;
    }

    // If camera is already working, don't re-initialize
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      debugPrint('🎥 Camera already initialized, skipping...');
      return;
    }

    _isInitializing = true;
    debugPrint('🎥 Starting camera initialization...');

    try {
      // Dispose old controller if it exists but isn't initialized
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ref.read(recordingSessionProvider.notifier).setError(
            'No cameras available on this device',
          );
        }
        return;
      }

      final session = ref.read(recordingSessionProvider);
      final cameraIndex = session.isFrontCamera ? 1 : 0;
      final camera = cameras.length > cameraIndex ? cameras[cameraIndex] : cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      debugPrint('🎥 Camera initialized successfully!');

      if (mounted) {
        setState(() {}); // Trigger rebuild with initialized camera
      }
    } catch (e) {
      debugPrint('❌ Camera init error: $e');
      if (mounted) {
        ref.read(recordingSessionProvider.notifier).setError(
          'Failed to initialize camera: $e',
        );
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraController == null) {
      debugPrint('⚠️ Cannot toggle camera: controller is null');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.length < 2) return;

      ref.read(recordingSessionProvider.notifier).toggleCamera();
      final session = ref.read(recordingSessionProvider);

      final cameraIndex = session.isFrontCamera ? 1 : 0;
      final camera = cameras[cameraIndex];

      await _cameraController?.dispose();
      _cameraController = null;  // ✓ Important: set to null before re-creating

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error toggling camera: $e');
      if (mounted) {
        ref.read(recordingSessionProvider.notifier).setError(
          'Failed to switch camera: $e',
        );
      }
    }
  }

  Future<void> _startRecording() async {
    final session = ref.read(recordingSessionProvider);
    if (_cameraController == null || session.isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      ref.read(recordingSessionProvider.notifier).startRecording();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        ref.read(recordingSessionProvider.notifier).updateRecordingTime(
              timer.tick,
            );
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    final session = ref.read(recordingSessionProvider);
    if (_cameraController == null || !session.isRecording) return;

    try {
      _recordingTimer?.cancel();
      final videoFile = await _cameraController!.stopVideoRecording();
      ref.read(recordingSessionProvider.notifier).stopRecording(videoFile.path);

      // Show preview/save dialog
      _showSaveDialog();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void _showSaveDialog() {
    final session = ref.read(recordingSessionProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Preview icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.habitColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam,
                  color: widget.habitColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${session.currentClipType.displayName} Recorded!',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Duration: ${_formatDuration(session.recordingSeconds)}',
                style: AppTypography.bodyDefault.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Save button
              PrimaryButton(
                text: 'Save Clip',
                icon: Icons.check,
                onPressed: () async {
                  Navigator.pop(context);
                  await _saveClip();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Re-record button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _discardAndRerecord();
                },
                child: Text(
                  'Re-record',
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveClip() async {
    // Remember if camera was working before save
    final cameraWasInitialized = _cameraController?.value.isInitialized ?? false;
    debugPrint('🎥 Saving clip... Camera initialized: $cameraWasInitialized');

    // Save the clip (this triggers photo library save)
    await ref.read(recordingSessionProvider.notifier).saveClip();

    final session = ref.read(recordingSessionProvider);

    // Ensure camera is still initialized after saving
    if (mounted && cameraWasInitialized) {
      final stillInitialized = _cameraController?.value.isInitialized ?? false;
      if (!stillInitialized && !_isInitializing) {
        // Only re-init if no initialization is already in flight
        debugPrint('🎥 Camera broke after save, re-initializing...');
        await _initializeCamera();
      } else {
        debugPrint('🎥 Camera survived save (or re-init already running), ready for next clip!');
      }
    }

    // Check if all clips are recorded
    if (session.dailyLog?.hasAllClips ?? false) {
      await _compileVlog();
    }
  }

  /// Compile the vlog from all clips
  Future<void> _compileVlog() async {
    if (!mounted) return;

    final session = ref.read(recordingSessionProvider);
    if (session.dailyLog == null) return;

    // Track whether we showed the dialog (so we know to dismiss it)
    bool dialogShown = false;

    // Declare outside try so it's accessible in catch for cleanup
    final progressController = StreamController<CompilationProgress>();

    try {
      // Show compilation dialog
      showCompilationDialog(
        context: context,
        habitName: widget.habitName,
        dayNumber: widget.dayNumber,
        progressStream: progressController.stream,
      );
      dialogShown = true;

      // Start compilation
      final repository = ref.read(recordingRepositoryProvider.notifier);
      await repository.compileLog(
        logId: session.dailyLog!.id,
        habitName: widget.habitName,
        onProgress: (progress, status) {
          progressController.add(CompilationProgress(progress, status));
        },
      );

      // Close the progress stream
      await progressController.close();

      // Wait a moment to show 100% before dismissing
      await Future.delayed(const Duration(milliseconds: 500));

      // EXPLICITLY dismiss the compilation dialog
      if (mounted && dialogShown) {
        Navigator.of(context).pop();
      }

      // Allow a brief moment for state to propagate through providers
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear recording session state and force UI refresh
      if (mounted) {
        ref.read(recordingSessionProvider.notifier).clearSession();

        // Force refresh of providers to ensure UI updates immediately
        ref.invalidate(todayLogProvider(widget.habitId));
        ref.invalidate(habitLogsProvider(widget.habitId));
      }

      // Award XP and show gamification rewards
      if (mounted) {
        await _awardAndCelebrate();
      }
    } catch (e) {
      debugPrint('❌ Compilation error: $e');

      // Close the stream controller to prevent resource leak
      try { await progressController.close(); } catch (_) {}

      // Dismiss dialog on error too
      if (mounted && dialogShown) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to compile vlog: $e'),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    }
  }

  void _discardAndRerecord() {
    ref.read(recordingSessionProvider.notifier).discardRecording();
  }

  Future<void> _awardAndCelebrate() async {
    // Gather inputs for XP calculation
    final recordingState = ref.read(recordingRepositoryProvider);
    final habit = ref.read(habitByIdProvider(widget.habitId));
    if (habit == null || !mounted) return;

    final totalVlogs = recordingState.vlogs.length;
    final totalSeconds = recordingState.vlogs.values
        .fold<int>(0, (sum, v) => sum + v.durationSeconds);

    // Award XP (also updates streak + day number on the habit)
    final result = await ref
        .read(gamificationProvider.notifier)
        .awardXpForCompletion(
          habit: habit,
          totalVlogCount: totalVlogs,
          totalSeconds: totalSeconds,
          recordingState: recordingState,
        );

    if (!mounted) return;
    final updatedProgress = ref.read(gamificationProvider);

    // 1. Enhanced completion dialog (with XP popup)
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 64),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Day ${widget.dayNumber} complete!',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your vlog has been compiled.',
                style: AppTypography.bodyDefault.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              XpRewardPopup(
                result: result,
                updatedProgress: updatedProgress,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );

    // 2. Level-up overlay (if applicable)
    if (mounted && result.newLevel != null) {
      await LevelUpOverlay.show(context, level: result.newLevel!);
    }

    // 3. Achievement toasts (sequential)
    for (final achievement in result.unlockedAchievements) {
      if (!mounted) break;
      await AchievementToast.show(context, achievement);
    }

    // 4. Navigate back to previous screen
    if (mounted) context.pop();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = ref.watch(cameraPermissionProvider);
    final session = ref.watch(recordingSessionProvider);
    final isInitialized = _cameraController?.value.isInitialized ?? false;
    final isRecording = session.isRecording;

    // Self-healing: re-initialize camera when permission is granted but camera is null
    ref.listen<PermissionStatus>(cameraPermissionProvider, (prev, next) {
      if (next.isGranted && _cameraController == null && !_isInitializing) {
        debugPrint('🎥 Permission granted but no camera, auto-initializing...');
        _initializeCamera();
      }
    });

    // Show a SnackBar when a save or init error occurs
    ref.listen<RecordingSessionState>(recordingSessionProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or permission UI
          if (permissionStatus.isGranted && isInitialized)
            _buildCameraPreview()
          else if (permissionStatus.isPermanentlyDenied || permissionStatus.isDenied)
            _buildPermissionDeniedUI()
          else
            _buildLoadingUI(),

          // Top bar with progress and close
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      _IconButton(
                        icon: Icons.close,
                        onTap: () => context.pop(),
                      ),
                      // Progress bar
                      ClipProgressBar(
                        dailyLog: session.dailyLog,
                        currentClipType: session.currentClipType,
                        isRecording: isRecording,
                        habitColor: widget.habitColor,
                      ),
                      // Flip camera button
                      _IconButton(
                        icon: Icons.flip_camera_ios,
                        onTap: isRecording ? null : _toggleCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Day overlay (bottom center)
          if (isInitialized && permissionStatus.isGranted)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: DayOverlay(
                  dayNumber: widget.dayNumber,
                  habitName: widget.habitName,
                  isRecording: isRecording,
                ),
              ),
            ),

          // Bottom controls
          if (isInitialized && permissionStatus.isGranted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    // Clip type selector toggle
                    if (!isRecording)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showClipTypeSelector = !_showClipTypeSelector;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.currentClipType.icon,
                                color: widget.habitColor,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                session.currentClipType.displayName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showClipTypeSelector
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Clip type selector panel
                    if (_showClipTypeSelector && !isRecording)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: ClipTypeSelector(
                          selectedType: session.currentClipType,
                          dailyLog: session.dailyLog,
                          habitColor: widget.habitColor,
                          onTypeSelected: (type) {
                            ref.read(recordingSessionProvider.notifier).setClipType(type);
                            setState(() {
                              _showClipTypeSelector = false;
                            });
                          },
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: 0.2, end: 0),
                    // Recording timer
                    if (isRecording)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: RecordingTimer(
                          seconds: session.recordingSeconds,
                          isRecording: true,
                        ),
                      ),
                    // Record button
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: RecordButton(
                        isRecording: isRecording,
                        isEnabled: isInitialized,
                        onTap: isRecording ? _stopRecording : _startRecording,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 1,
          height: _cameraController!.value.previewSize?.width ?? 1,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Initializing camera...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    final permissionStatus = ref.watch(cameraPermissionProvider);
    final isPermanentlyDenied = permissionStatus.isPermanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.streakFire.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off,
                color: AppColors.streakFire,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Camera Access Required',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isPermanentlyDenied
                  ? 'Day1 needs camera and microphone access to record your vlogs. Please enable them in Settings.'
                  : 'Day1 needs camera and microphone access to record your daily habit vlogs.',
              style: AppTypography.bodyDefault.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
              onPressed: () async {
                if (isPermanentlyDenied) {
                  await ref.read(cameraPermissionProvider.notifier).openSettings();
                } else {
                  // Request permission (shows native dialog)
                  final granted = await ref.read(cameraPermissionProvider.notifier).requestPermission();
                  if (granted && mounted) {
                    await _initializeCamera();
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Go Back',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({
    required this.icon,
    this.onTap,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: isEnabled ? Colors.white : AppColors.textTertiary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
