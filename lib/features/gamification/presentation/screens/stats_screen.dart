import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/achievement.dart';
import '../../providers/gamification_provider.dart';
import '../widgets/achievement_card.dart';
import '../../../habits/providers/habits_provider.dart';
import '../../../recording/providers/recording_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(gamificationProvider);
    final habits = ref.watch(habitsProvider);
    final recordingState = ref.watch(recordingRepositoryProvider);

    // ── Weekly completion data ─────────────────────────────────────────────
    final now = DateTime.now();
    // Start of current week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekBars = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final dayVlogs = recordingState.vlogs.values.where((v) =>
          v.date.year == day.year &&
          v.date.month == day.month &&
          v.date.day == day.day);
      return dayVlogs.isNotEmpty ? 1.0 : 0.0;
    });
    final today = now.weekday - 1; // 0=Mon

    // ── Activity heatmap (7 weeks x 7 days) ───────────────────────────────
    final heatmap = List.generate(49, (i) {
      final daysAgo = (48 - i);
      final date = now.subtract(Duration(days: daysAgo));
      final hasVlog = recordingState.vlogs.values.any((v) =>
          v.date.year == date.year &&
          v.date.month == date.month &&
          v.date.day == date.day);
      return hasVlog ? 1.0 : 0.0;
    });

    // ── Achievements unlocked / total ──────────────────────────────────────
    final unlocked = progress.unlockedAchievementIds;
    const all = AchievementDefinitions.all;
    final unlockedList = all.where((a) => unlocked.contains(a.id)).toList();
    final lockedList = all.where((a) => !unlocked.contains(a.id)).toList();
    final sorted = [...unlockedList, ...lockedList];

    // ── Best streak ────────────────────────────────────────────────────────
    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce(max);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stats', style: AppTypography.h1.copyWith(color: AppColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.xpGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.25)),
                    ),
                    child: Row(children: [
                      const Text('⚡', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text('${progress.totalXP} XP', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.xpGold)),
                    ]),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // ── This Week bar chart ─────────────────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('THIS WEEK', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 0.07, fontWeight: FontWeight.w600)),
                      Text(_weekRangeLabel(weekStart), style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 72,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          final val = weekBars[i];
                          final isToday = i == today;
                          final isFuture = i > today;
                          Color barColor;
                          if (isToday) { barColor = AppColors.primary; }
                          else if (val >= 1.0) { barColor = AppColors.success; }
                          else if (val >= 0.5) { barColor = AppColors.xpGold; }
                          else { barColor = AppColors.backgroundSurface; }
                          final h = max(4.0, val * 56 + (isToday ? 8 : 0));
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Opacity(
                                  opacity: isFuture ? 0.3 : 1.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOut,
                                    width: double.infinity,
                                    height: h,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: isToday ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2))] : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(weekDayLabels[i], style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: isToday ? AppColors.primary : AppColors.textTertiary)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(children: [
                      _MiniStat(value: '${weekBars.where((v) => v > 0).length}/7', label: 'Days'),
                      _MiniStat(value: weekBars.isEmpty ? '0%' : '${((weekBars.where((v) => v > 0).length / 7) * 100).round()}%', label: 'Rate'),
                      _MiniStat(value: '${weekBars.where((v) => v >= 1.0).length}', label: 'Perfect'),
                    ]),
                  ],
                ),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 14),

              // ── XP Progress (level visualization) ──────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('XP PROGRESS', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 0.07, fontWeight: FontWeight.w600)),
                      Text('Level ${progress.level}', style: AppTypography.caption.copyWith(color: AppColors.xpGold, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 12),
                    _XpLineChart(progress: progress),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${progress.xpForCurrentLevel} XP', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                      Text('${progress.xpForNextLevel} XP', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                    ]),
                  ],
                ),
              )
                  .animate(delay: 180.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 14),

              // ── Habit breakdown ─────────────────────────────────────────
              if (habits.isNotEmpty) ...[
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HABIT BREAKDOWN', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 0.07, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      ...habits.map((h) {
                        final completion = h.totalDaysCompleted > 0
                            ? min(1.0, h.totalDaysCompleted / max(h.currentDayNumber, 1).toDouble())
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            _RadialProgress(pct: completion, color: h.category.color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(h.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  Text('${(completion * 100).round()}%', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: h.category.color)),
                                ]),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: completion,
                                    minHeight: 4,
                                    backgroundColor: AppColors.backgroundSurface,
                                    valueColor: AlwaysStoppedAnimation<Color>(h.category.color),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text('🔥 ${h.currentStreak} streak', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                                  const SizedBox(width: 10),
                                  Text('${h.totalDaysCompleted} total days', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                                ]),
                              ]),
                            ),
                          ]),
                        );
                      }),
                    ],
                  ),
                )
                    .animate(delay: 260.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 14),
              ],

              // ── Activity heatmap ────────────────────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTIVITY', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 0.07, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
                        Expanded(child: Center(child: Text(d, style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.textTertiary))))
                      ).toList(),
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                      itemCount: 49,
                      itemBuilder: (_, i) {
                        final v = heatmap[i];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: v == 0 ? AppColors.backgroundSurface : AppColors.primary.withValues(alpha: 0.15 + v * 0.85),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('Less', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(width: 6),
                      ...([0.15, 0.35, 0.55, 0.75, 1.0].map((v) => Container(
                        width: 10, height: 10, margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.primary.withValues(alpha: v)),
                      ))),
                      Text('More', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                    ]),
                  ],
                ),
              )
                  .animate(delay: 340.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 14),

              // ── Totals grid ─────────────────────────────────────────────
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _TotalChip(emoji: '🎬', value: '${progress.totalVlogsCreated}', label: 'Total Vlogs', color: AppColors.primary),
                  _TotalChip(emoji: '🔥', value: '${bestStreak}d', label: 'Best Streak', color: AppColors.streakFire),
                  _TotalChip(emoji: '⚡', value: '${progress.totalXP}', label: 'Total XP', color: AppColors.xpGold),
                  _TotalChip(emoji: '💪', value: '${habits.length}', label: 'Habits Active', color: AppColors.success),
                ],
              )
                  .animate(delay: 420.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ── Achievements ────────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('ACHIEVEMENTS', style: AppTypography.h4.copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
                Text('${unlocked.length}/${all.length}', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
              ])
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.md),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: AppSpacing.sm, mainAxisSpacing: AppSpacing.sm, childAspectRatio: 1.3),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final achievement = sorted[index];
                  final isUnlocked = unlocked.contains(achievement.id);
                  return AchievementCard(achievement: achievement, isUnlocked: isUnlocked)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 200 + (index * 30)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekRangeLabel(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[weekStart.month - 1]} ${weekStart.day}–${end.day}';
  }
}

// ── Shared card wrapper ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}

// ── Mini stat cell ──────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
        ]),
      ),
    );
  }
}

// ── XP Line Chart ───────────────────────────────────────────────────────────

class _XpLineChart extends StatelessWidget {
  final dynamic progress; // UserProgress
  const _XpLineChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _XpChartPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _XpChartPainter extends CustomPainter {
  final dynamic progress;
  _XpChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final currentXP = progress.totalXP as int;
    final xpFrom = progress.xpForCurrentLevel as int;
    final xpTo = progress.xpForNextLevel as int;

    // Show a smooth filled area chart from 0 to current progress in this level
    final levelXP = xpTo - xpFrom;
    final progressXP = currentXP - xpFrom;
    final pct = levelXP > 0 ? (progressXP / levelXP).clamp(0.0, 1.0) : 0.0;

    // Generate ~12 data points for a smooth curve
    final pts = <Offset>[];
    for (int i = 0; i <= 11; i++) {
      final x = (i / 11.0) * size.width;
      // Make the curve realistic: gradual growth with slight acceleration
      final t = i / 11.0;
      final y = size.height - (size.height * pct * (t * t * 0.3 + t * 0.7));
      pts.add(Offset(x, y));
    }

    // Build path
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }

    // Fill area
    final fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [AppColors.xpGold.withValues(alpha: 0.4), AppColors.xpGold.withValues(alpha: 0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.xpGold
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Endpoint dot
    final last = pts.last;
    canvas.drawCircle(last, 4, Paint()..color = AppColors.xpGold);
    canvas.drawCircle(last, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_XpChartPainter old) => old.progress != progress;
}

// ── Radial progress ring ─────────────────────────────────────────────────────

class _RadialProgress extends StatelessWidget {
  final double pct;
  final Color color;

  const _RadialProgress({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    const sz = 52.0;
    return SizedBox(
      width: sz, height: sz,
      child: CustomPaint(
        painter: _RadialPainter(pct: pct, color: color, size: sz),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double pct;
  final Color color;
  final double size;
  const _RadialPainter({required this.pct, required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size sz) {
    const strokeW = 5.0;
    final r = (size - strokeW * 2) / 2;
    final center = Offset(sz.width / 2, sz.height / 2);
    // Background track
    canvas.drawCircle(center, r, Paint()..color = AppColors.backgroundSurface..strokeWidth = strokeW..style = PaintingStyle.stroke);
    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -pi / 2,
      pct * 2 * pi,
      false,
      Paint()..color = color..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RadialPainter old) => old.pct != pct || old.color != color;
}

// ── Total chip ──────────────────────────────────────────────────────────────

class _TotalChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _TotalChip({required this.emoji, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: AppTypography.h3.copyWith(color: color, fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}
