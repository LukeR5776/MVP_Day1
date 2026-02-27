import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../recording/data/models/vlog.dart';

/// Calendar widget showing habit completion with colored dots
class JourneyCalendar extends StatefulWidget {
  final List<Vlog> vlogs;
  final DateTime? startDate;
  final Function(Vlog) onVlogTap;
  final Color categoryColor;

  const JourneyCalendar({
    super.key,
    required this.vlogs,
    this.startDate,
    required this.onVlogTap,
    this.categoryColor = AppColors.primary,
  });

  @override
  State<JourneyCalendar> createState() => _JourneyCalendarState();
}

class _JourneyCalendarState extends State<JourneyCalendar> {
  late DateTime _currentMonth;
  late Map<String, Vlog> _vlogsByDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _buildVlogMap();
  }

  @override
  void didUpdateWidget(JourneyCalendar oldWidget) {
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

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month header with navigation
        _CalendarHeader(
          currentMonth: _currentMonth,
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
        const SizedBox(height: AppSpacing.md),

        // Weekday labels
        _WeekdayLabels(),
        const SizedBox(height: AppSpacing.sm),

        // Calendar grid
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get the weekday of the first day (0 = Sunday, 6 = Saturday)
    int startWeekday = firstDayOfMonth.weekday % 7;

    // Calculate total cells needed (including padding)
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        // Check if this cell is before the first day
        if (index < startWeekday) {
          return const SizedBox();
        }

        final dayNumber = index - startWeekday + 1;

        // Check if this cell is after the last day
        if (dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final dateKey = _dateKey(date);
        final vlog = _vlogsByDate[dateKey];
        final isToday = _isToday(date);
        final isFuture = date.isAfter(DateTime.now());

        return _CalendarDay(
          dayNumber: dayNumber,
          hasVlog: vlog != null,
          isToday: isToday,
          isFuture: isFuture,
          categoryColor: widget.categoryColor,
          onTap: vlog != null ? () => widget.onVlogTap(vlog) : null,
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  String get _monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[currentMonth.month - 1]} ${currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          _monthName,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int dayNumber;
  final bool hasVlog;
  final bool isToday;
  final bool isFuture;
  final Color categoryColor;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.dayNumber,
    required this.hasVlog,
    required this.isToday,
    required this.isFuture,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasVlog
              ? categoryColor.withValues(alpha: 0.15)
              : isToday
                  ? AppColors.backgroundSurface
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.borderDefault, width: 1)
              : null,
        ),
        child: Stack(
          children: [
            // Day number
            Center(
              child: Text(
                dayNumber.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: isFuture
                      ? AppColors.textTertiary
                      : hasVlog
                          ? categoryColor
                          : AppColors.textSecondary,
                  fontWeight: hasVlog ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),

            // Completion dot
            if (hasVlog)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact calendar legend showing stats
class CalendarLegend extends StatelessWidget {
  final int completedDays;
  final Color categoryColor;

  const CalendarLegend({
    super.key,
    required this.completedDays,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completedDays ${completedDays == 1 ? 'day' : 'days'} completed',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
