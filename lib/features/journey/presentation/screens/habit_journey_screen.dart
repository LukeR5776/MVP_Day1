import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/journey_provider.dart';
import '../../../recording/data/models/vlog.dart';
import '../widgets/vlog_thumbnail.dart';
import '../widgets/journey_calendar.dart';

/// Screen showing journey for a specific habit
class HabitJourneyScreen extends ConsumerWidget {
  final String habitId;

  const HabitJourneyScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(habitJourneyProvider(habitId));
    final viewMode = ref.watch(journeyViewModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Hero header with habit info
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            leading: _BackButton(onTap: () => context.pop()),
            actions: [
              // View mode toggle
              IconButton(
                onPressed: () => _cycleViewMode(ref),
                icon: Icon(
                  _getViewModeIcon(viewMode),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(
                habitName: journeyState.habitName,
                completedDays: journeyState.completedDays,
                category: journeyState.category,
                currentStreak: journeyState.currentStreak,
              ),
            ),
          ),

          // View toggle buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.md,
              ),
              child: _ViewModeToggle(
                currentMode: viewMode,
                onModeChanged: (mode) {
                  ref.read(journeyViewModeProvider.notifier).state = mode;
                },
              ),
            ),
          ),

          // Content based on view mode
          if (!journeyState.hasVlogs)
            const SliverFillRemaining(
              child: _EmptyJourneyState(),
            )
          else
            _buildContent(context, journeyState, viewMode),
        ],
      ),
    );
  }

  IconData _getViewModeIcon(JourneyViewMode mode) {
    switch (mode) {
      case JourneyViewMode.grid:
        return Icons.grid_view_rounded;
      case JourneyViewMode.calendar:
        return Icons.calendar_month_rounded;
      case JourneyViewMode.timeline:
        return Icons.view_agenda_rounded;
    }
  }

  void _cycleViewMode(WidgetRef ref) {
    final current = ref.read(journeyViewModeProvider);
    final modes = JourneyViewMode.values;
    final nextIndex = (modes.indexOf(current) + 1) % modes.length;
    ref.read(journeyViewModeProvider.notifier).state = modes[nextIndex];
  }

  Widget _buildContent(
    BuildContext context,
    HabitJourneyState journeyState,
    JourneyViewMode viewMode,
  ) {
    switch (viewMode) {
      case JourneyViewMode.grid:
        return _buildGridView(context, journeyState);
      case JourneyViewMode.calendar:
        return _buildCalendarView(context, journeyState);
      case JourneyViewMode.timeline:
        return _buildTimelineView(context, journeyState);
    }
  }

  Widget _buildGridView(BuildContext context, HabitJourneyState journeyState) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final vlog = journeyState.vlogs[index];
            return VlogThumbnail(
              vlog: vlog,
              onTap: () => _navigateToPlayer(context, vlog),
            );
          },
          childCount: journeyState.vlogs.length,
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, HabitJourneyState journeyState) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: JourneyCalendar(
                vlogs: journeyState.vlogs,
                categoryColor: journeyState.category.color,
                onVlogTap: (vlog) => _navigateToPlayer(context, vlog),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CalendarLegend(
              completedDays: journeyState.completedDays,
              categoryColor: journeyState.category.color,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView(BuildContext context, HabitJourneyState journeyState) {
    // Sort vlogs by date (newest first)
    final sortedVlogs = List<Vlog>.from(journeyState.vlogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final vlog = sortedVlogs[index];
            final showDateHeader = index == 0 ||
                !_isSameDay(sortedVlogs[index - 1].date, vlog.date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.lg),
                  Text(
                    _formatDateHeader(vlog.date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                VlogThumbnailLarge(
                  vlog: vlog,
                  onTap: () => _navigateToPlayer(context, vlog),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
          childCount: sortedVlogs.length,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _navigateToPlayer(BuildContext context, Vlog vlog) {
    context.push('/vlog/${vlog.id}');
  }
}

/// Back button widget
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

/// Hero header with gradient background
class _HeroHeader extends StatelessWidget {
  final String habitName;
  final int completedDays;
  final dynamic category; // HabitCategory
  final int currentStreak;

  const _HeroHeader({
    required this.habitName,
    required this.completedDays,
    required this.category,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            category.color.withValues(alpha: 0.3),
            AppColors.backgroundPrimary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                '$habitName Journey',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Subheader with stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentStreak > 0) ...[
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.streakFire,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak day${currentStreak != 1 ? 's' : ''} streak',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category.displayName,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// View mode toggle buttons
class _ViewModeToggle extends StatelessWidget {
  final JourneyViewMode currentMode;
  final Function(JourneyViewMode) onModeChanged;

  const _ViewModeToggle({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _ToggleButton(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            isSelected: currentMode == JourneyViewMode.calendar,
            onTap: () => onModeChanged(JourneyViewMode.calendar),
          ),
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            label: 'Grid',
            isSelected: currentMode == JourneyViewMode.grid,
            onTap: () => onModeChanged(JourneyViewMode.grid),
          ),
          _ToggleButton(
            icon: Icons.view_agenda_rounded,
            label: 'Timeline',
            isSelected: currentMode == JourneyViewMode.timeline,
            onTap: () => onModeChanged(JourneyViewMode.timeline),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.textOnColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.textOnColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state for habit journey
class _EmptyJourneyState extends StatelessWidget {
  const _EmptyJourneyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎬',
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No vlogs yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Record your first day to\nstart your journey!',
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
