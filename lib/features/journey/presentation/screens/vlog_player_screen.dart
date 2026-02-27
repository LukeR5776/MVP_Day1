import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/journey_provider.dart';
import '../../../recording/data/models/vlog.dart';

/// Full-screen video player for compiled vlogs
/// Plays the single concatenated video (I+E+R combined)
class VlogPlayerScreen extends ConsumerStatefulWidget {
  final String vlogId;

  const VlogPlayerScreen({
    super.key,
    required this.vlogId,
  });

  @override
  ConsumerState<VlogPlayerScreen> createState() => _VlogPlayerScreenState();
}

class _VlogPlayerScreenState extends ConsumerState<VlogPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final vlog = ref.read(vlogByIdProvider(widget.vlogId));
    if (vlog == null) {
      debugPrint('❌ Vlog not found: ${widget.vlogId}');
      return;
    }

    final videoFile = File(vlog.videoPath);
    if (!await videoFile.exists()) {
      debugPrint('❌ Video file not found: ${vlog.videoPath}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video file not found'),
            backgroundColor: AppColors.streakFire,
          ),
        );
        context.pop();
      }
      return;
    }

    _controller = VideoPlayerController.file(videoFile);

    try {
      await _controller!.initialize();
      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Auto-play
        _controller!.play();
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: $e'),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _shareVlog(Vlog vlog) async {
    try {
      await Share.shareXFiles(
        [XFile(vlog.videoPath)],
        text: 'Day ${vlog.dayNumber} - ${vlog.habitName}',
      );
      ref.read(vlogOperationsProvider.notifier).markAsShared(vlog.id);
    } catch (e) {
      debugPrint('❌ Error sharing vlog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    }
  }

  Future<void> _downloadVlog(Vlog vlog) async {
    try {
      final result = await ImageGallerySaver.saveFile(
        vlog.videoPath,
        isReturnPathOfIOS: true,
        name: 'Day${vlog.dayNumber}_${vlog.habitName.replaceAll(' ', '_')}',
      );

      debugPrint('✅ Saved to camera roll: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to camera roll'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    }
  }

  Future<void> _deleteVlog(Vlog vlog) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Vlog?',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete Day ${vlog.dayNumber} vlog. This action cannot be undone.',
          style: AppTypography.bodyDefault.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.streakFire,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(vlogOperationsProvider.notifier).deleteVlog(vlog.id);

      if (success && mounted) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vlog = ref.watch(vlogByIdProvider(widget.vlogId));

    if (vlog == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Vlog not found',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Go Back',
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Stack(
                  children: [
                    // Top bar
                    _TopBar(
                      vlog: vlog,
                      onClose: () => context.pop(),
                    ),

                    // Center play/pause button
                    if (_isInitialized)
                      Center(
                        child: _PlayPauseButton(
                          isPlaying: _isPlaying,
                          onTap: _togglePlayPause,
                        ),
                      ),

                    // Bottom controls
                    if (_isInitialized)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _BottomControls(
                          controller: _controller!,
                          vlog: vlog,
                          onShare: () => _shareVlog(vlog),
                          onDownload: () => _downloadVlog(vlog),
                          onDelete: () => _deleteVlog(vlog),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar with close button and vlog info
class _TopBar extends StatelessWidget {
  final Vlog vlog;
  final VoidCallback onClose;

  const _TopBar({
    required this.vlog,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Vlog info
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vlog.habitName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Day ${vlog.dayNumber}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Placeholder for symmetry
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

/// Play/pause button in center
class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

/// Bottom controls with progress and actions
class _BottomControls extends StatefulWidget {
  final VideoPlayerController controller;
  final Vlog vlog;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _BottomControls({
    required this.controller,
    required this.vlog,
    required this.onShare,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  State<_BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<_BottomControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.controller.value.position;
    final duration = widget.controller.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.backgroundSurface,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds:
                              (value * duration.inMilliseconds).round(),
                        );
                        widget.controller.seekTo(newPosition);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDuration(duration),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: widget.onShare,
                ),
                _ActionButton(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  onTap: widget.onDownload,
                ),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: widget.onDelete,
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button for bottom controls
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.streakFire : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
