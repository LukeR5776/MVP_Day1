import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/screen_scaffold.dart';
import '../../providers/journey_provider.dart';
import '../../../recording/data/models/vlog.dart';
import '../widgets/vlog_thumbnail.dart';

/// Main gallery screen showing all vlogs
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vlogs = ref.watch(allVlogsProvider);
    final groupedVlogs = ref.watch(vlogsGroupedByHabitProvider);
    final viewMode = ref.watch(journeyViewModeProvider);

    return ScreenScaffold(
      title: 'Your Journey',
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
      body: vlogs.isEmpty
          ? const _EmptyJourneyState()
          : _buildContent(context, groupedVlogs, viewMode),
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
    Map<String, List<Vlog>> groupedVlogs,
    JourneyViewMode viewMode,
  ) {
    switch (viewMode) {
      case JourneyViewMode.grid:
        return _buildGridView(context, groupedVlogs);
      case JourneyViewMode.calendar:
        return _buildCalendarView(context, groupedVlogs);
      case JourneyViewMode.timeline:
        return _buildTimelineView(context, groupedVlogs);
    }
  }

  Widget _buildGridView(
    BuildContext context,
    Map<String, List<Vlog>> groupedVlogs,
  ) {
    final habitNames = groupedVlogs.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: habitNames.length,
      itemBuilder: (context, index) {
        final habitName = habitNames[index];
        final habitVlogs = groupedVlogs[habitName]!;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < habitNames.length - 1 ? AppSpacing.xl : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    habitName,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${habitVlogs.length} ${habitVlogs.length == 1 ? 'vlog' : 'vlogs'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 4-column grid of thumbnails
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: habitVlogs.length,
                itemBuilder: (context, i) {
                  final vlog = habitVlogs[i];
                  return VlogThumbnail(
                    vlog: vlog,
                    onTap: () => _navigateToPlayer(context, vlog),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    Map<String, List<Vlog>> groupedVlogs,
  ) {
    // For calendar view, show all vlogs in a single calendar
    // with dots colored by habit
    final allVlogs = groupedVlogs.values.expand((v) => v).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Calendar',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _SimpleCalendarView(
            vlogs: allVlogs,
            onVlogTap: (vlog) => _navigateToPlayer(context, vlog),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Stats summary
          _CalendarStats(vlogs: allVlogs),
        ],
      ),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    Map<String, List<Vlog>> groupedVlogs,
  ) {
    // Flatten and sort by date (newest first)
    final allVlogs = groupedVlogs.values
        .expand((v) => v)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: allVlogs.length,
      itemBuilder: (context, index) {
        final vlog = allVlogs[index];
        final showDateHeader = index == 0 ||
            !_isSameDay(allVlogs[index - 1].date, vlog.date);

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
              habitName: vlog.habitName,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
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

/// Empty state when no vlogs exist
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
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No vlogs yet',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete your first day of a habit\nto start your journey',
              style: AppTypography.bodyDefault.copyWith(
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

/// Simple calendar view showing all activity
class _SimpleCalendarView extends StatefulWidget {
  final List<Vlog> vlogs;
  final Function(Vlog) onVlogTap;

  const _SimpleCalendarView({
    required this.vlogs,
    required this.onVlogTap,
  });

  @override
  State<_SimpleCalendarView> createState() => _SimpleCalendarViewState();
}

class _SimpleCalendarViewState extends State<_SimpleCalendarView> {
  late DateTime _currentMonth;
  late Map<String, Vlog> _vlogsByDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _buildVlogMap();
  }

  @override
  void didUpdateWidget(_SimpleCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vlogs != widget.vlogs) {
      _buildVlogMap();
    }
  }

  void _buildVlogMap() {
    _vlogsByDate = {};
    for (final vlog in widget.vlogs) {
      final key = _dateKey(vlog.date);
      _vlogsByDate[key] = vlog;
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                }),
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              ),
              Text(
                _getMonthName(),
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                }),
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  String _getMonthName() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        if (index < startWeekday) return const SizedBox();
        final day = index - startWeekday + 1;
        if (day > lastDay.day) return const SizedBox();

        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final vlog = _vlogsByDate[_dateKey(date)];
        final isToday = _isToday(date);

        return GestureDetector(
          onTap: vlog != null ? () => widget.onVlogTap(vlog) : null,
          child: Container(
            decoration: BoxDecoration(
              color: vlog != null
                  ? AppColors.success.withValues(alpha: 0.2)
                  : isToday
                      ? AppColors.backgroundSurface
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isToday
                  ? Border.all(color: AppColors.borderDefault)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      color: vlog != null
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: vlog != null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (vlog != null)
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

/// Stats summary for calendar view
class _CalendarStats extends StatelessWidget {
  final List<Vlog> vlogs;

  const _CalendarStats({required this.vlogs});

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final totalDays = vlogs.length;
    final uniqueHabits = vlogs.map((v) => v.habitId).toSet().length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_rounded,
              value: totalDays.toString(),
              label: 'Days Recorded',
              color: AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderSubtle,
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.category_rounded,
              value: uniqueHabits.toString(),
              label: 'Active Habits',
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
