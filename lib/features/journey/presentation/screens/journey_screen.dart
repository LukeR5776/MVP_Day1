import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../habits/data/models/habit.dart';
import '../../../habits/providers/habits_provider.dart';
import '../../../recording/data/models/vlog.dart';

import '../../providers/journey_provider.dart';
import '../widgets/vlog_thumbnail.dart';

// ── Path layout constants ──────────────────────────────────────────────────

const List<double> _xPattern = [195, 258, 288, 258, 195, 132, 102, 132, 195, 258, 288, 258, 195, 132, 102];
const double _nodeStep = 112.0;
const double _bannerHeight = 88.0;
const double _bannerPad = 24.0;
const double _canvasWidth = 390.0;
const int _daysPerSection = 5;

enum _NodeType { done, current, locked, milestone }

class _NodeColors {
  final Color top, mid, bot, shadow;
  const _NodeColors(this.top, this.mid, this.bot, this.shadow);
}

const _lockedColors = _NodeColors(
  Color(0xFF505050), Color(0xFF363636), Color(0xFF282828), Color(0xFF141414),
);
const _goldColors = _NodeColors(
  Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF78350F),
);
const _currentColors = _NodeColors(
  Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF2563EB), Color(0xFF1E3A8A),
);

_NodeColors _sectionColors(Color c) {
  return _NodeColors(
    Color.lerp(c, Colors.white, 0.55)!,
    c,
    Color.lerp(c, Colors.black, 0.35)!,
    Color.lerp(c, Colors.black, 0.65)!,
  );
}

class _PathSection {
  final int week;
  final String title;
  final String subtitle;
  final Color color;
  final List<_PathNode> nodes;
  const _PathSection({
    required this.week,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.nodes,
  });
}

class _PathNode {
  final int day;
  final _NodeType type;
  final String quest;
  final int xp;
  final bool isMilestone;
  const _PathNode({
    required this.day,
    required this.type,
    required this.quest,
    required this.xp,
    required this.isMilestone,
  });
}

List<_PathSection> _buildSections(Habit habit) {
  final totalDone = habit.totalDaysCompleted;
  final totalToShow = max(15, totalDone + 11);
  final sectionCount = (totalToShow / _daysPerSection).ceil();
  final sectionColors = [
    AppColors.physical, AppColors.mental, AppColors.creative,
    AppColors.growth, AppColors.xpGold,
  ];

  return List.generate(sectionCount, (s) {
    final startDay = s * _daysPerSection + 1;
    final endDay = startDay + _daysPerSection - 1;
    final color = sectionColors[s % sectionColors.length];

    final nodes = <_PathNode>[];
    for (int d = startDay; d <= endDay; d++) {
      final isMilestone = d % _daysPerSection == 0;
      _NodeType type;
      if (d <= totalDone) {
        type = isMilestone ? _NodeType.milestone : _NodeType.done;
      } else if (d == totalDone + 1) {
        type = _NodeType.current;
      } else {
        type = _NodeType.locked;
      }
      nodes.add(_PathNode(
        day: d,
        type: type,
        quest: _questForDay(d, habit.name),
        xp: _xpForDay(d),
        isMilestone: isMilestone,
      ));
    }
    return _PathSection(
      week: s + 1,
      title: _sectionTitle(s + 1),
      subtitle: _sectionSubtitle(s + 1),
      color: color,
      nodes: nodes,
    );
  });
}

String _questForDay(int day, String habitName) {
  if (day == 1) return 'Record your first $habitName clip — just show up!';
  if (day == 5) return 'Five days in! Share your progress.';
  if (day == 7) return 'One week! Reflect on how $habitName has changed you.';
  if (day == 10) return "Double digits! You're in the top 20% of users.";
  if (day == 14) return 'Two weeks straight. Building a real identity.';
  if (day % 10 == 0) return 'Day $day milestone! Keep filming your journey.';
  if (day <= 3) return 'Day $day — build the foundation. Show up today.';
  if (day <= 7) return 'The streak is your identity. Record today.';
  return 'Day $day. Show up again. Your future self is watching.';
}

int _xpForDay(int day) {
  if (day % _daysPerSection == 0) return 150 + (day ~/ 5) * 10;
  return 75 + (day ~/ 7) * 5;
}

String _sectionTitle(int week) {
  const titles = ['Foundation', 'Momentum', 'Identity', 'Mastery', 'Legend', 'Myth'];
  return 'Week $week — ${titles[(week - 1) % titles.length]}';
}

String _sectionSubtitle(int week) {
  const subs = [
    'Build the base. Show up every day.',
    'The streak is your identity now.',
    'You are the person who does this.',
    'Mastery is just showing up daily.',
    'You\'ve become legendary. Keep going.',
    'Few reach here. You are one of them.',
  ];
  return subs[(week - 1) % subs.length];
}

class _LayoutItem {
  final bool isBanner;
  final _PathSection section;
  final _PathNode? node;
  final double x;
  final double y;
  const _LayoutItem({
    required this.isBanner,
    required this.section,
    this.node,
    required this.x,
    required this.y,
  });
}

class _Layout {
  final List<_LayoutItem> items;
  final double totalHeight;
  final int currentItemIndex;
  const _Layout(this.items, this.totalHeight, this.currentItemIndex);
}

_Layout _buildLayout(List<_PathSection> sections) {
  final items = <_LayoutItem>[];
  double y = 24;
  int nodeIndex = 0;
  int currentItemIndex = -1;

  for (final section in sections) {
    items.add(_LayoutItem(isBanner: true, section: section, x: 0, y: y));
    y += _bannerHeight + _bannerPad;
    for (final node in section.nodes) {
      final x = _xPattern[nodeIndex % _xPattern.length];
      items.add(_LayoutItem(isBanner: false, section: section, node: node, x: x, y: y));
      if (node.type == _NodeType.current) currentItemIndex = items.length - 1;
      y += _nodeStep;
      nodeIndex++;
    }
    y += 16;
  }
  return _Layout(items, y + 120, currentItemIndex);
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Vlog vlog) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.screenHorizontal, AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppSpacing.lg),
            const Icon(Icons.delete_outline_rounded, color: AppColors.streakFire, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text('Delete Vlog?', style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Day ${vlog.dayNumber} — ${vlog.habitName}\nThis cannot be undone.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.streakFire, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text('Delete', style: AppTypography.buttonText.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTypography.buttonText.copyWith(color: AppColors.textTertiary))),
          ],
        ),
      ),
    ),
  );
  if (confirmed == true) {
    await ref.read(vlogOperationsProvider.notifier).deleteVlog(vlog.id);
  }
}

// ── Journey Screen ─────────────────────────────────────────────────────────

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});
  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  bool _showPath = true;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final vlogs = ref.watch(allVlogsProvider);
    final bestStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce(max);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Journey', style: AppTypography.h1.copyWith(color: AppColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.streakFire.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.streakFire.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text('$bestStreak', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.streakFire)),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  _SubTab(label: 'Path', icon: Icons.map_outlined, selected: _showPath, onTap: () => setState(() => _showPath = true)),
                  const SizedBox(width: 8),
                  _SubTab(label: 'Gallery', icon: Icons.movie_filter_outlined, selected: !_showPath, onTap: () => setState(() => _showPath = false)),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _showPath ? _PathTab(habits: habits) : _GalleryTab(vlogs: vlogs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SubTab({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 38,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Path Tab ────────────────────────────────────────────────────────────────

class _PathTab extends ConsumerStatefulWidget {
  final List<Habit> habits;
  const _PathTab({required this.habits});
  @override
  ConsumerState<_PathTab> createState() => _PathTabState();
}

class _PathTabState extends ConsumerState<_PathTab> {
  int _selectedIdx = 0;
  _LayoutItem? _popup;
  final ScrollController _scrollCtrl = ScrollController();
  _Layout? _lastLayout;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCurrent(_Layout layout) {
    if (layout.currentItemIndex >= 0) {
      final item = layout.items[layout.currentItemIndex];
      final target = (item.y - 280).clamp(0.0, double.infinity);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(target, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) return const _EmptyPathState();

    final habit = widget.habits[_selectedIdx.clamp(0, widget.habits.length - 1)];
    final sections = _buildSections(habit);
    final layout = _buildLayout(sections);

    if (_lastLayout == null) {
      _lastLayout = layout;
      _scrollToCurrent(layout);
    }

    return Stack(
      children: [
        Column(
          children: [
            // Habit pills
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                scrollDirection: Axis.horizontal,
                itemCount: widget.habits.length,
                itemBuilder: (_, i) {
                  final h = widget.habits[i];
                  final sel = i == _selectedIdx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() { _selectedIdx = i; _popup = null; _lastLayout = null; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? h.category.color.withValues(alpha: 0.15) : AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: sel ? h.category.color.withValues(alpha: 0.4) : AppColors.borderSubtle),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(h.category.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(h.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: sel ? h.category.color : AppColors.textSecondary)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Path canvas
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                child: SizedBox(
                  width: double.infinity,
                  height: layout.totalHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PathPainter(layout: layout, habitColor: habit.category.color),
                        ),
                      ),
                      ...layout.items.map((item) {
                        if (item.isBanner) {
                          return Positioned(
                            left: 20, top: item.y, width: _canvasWidth - 40, height: _bannerHeight,
                            child: _SectionBanner(item: item),
                          );
                        }
                        final node = item.node!;
                        final size = (node.isMilestone || node.type == _NodeType.current) ? 76.0 : 64.0;
                        return Positioned(
                          left: item.x - size / 2, top: item.y - size / 2,
                          child: _PathNodeWidget(item: item, onTap: () => setState(() => _popup = item)),
                        );
                      }),
                      if (layout.currentItemIndex >= 0) _buildMascot(layout),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_popup != null)
          _NodePopup(
            item: _popup!,
            onClose: () => setState(() => _popup = null),
            onRecord: () { setState(() => _popup = null); context.push('/record'); },
          ),
      ],
    );
  }

  Widget _buildMascot(_Layout layout) {
    final item = layout.items[layout.currentItemIndex];
    final isLeft = item.x < _canvasWidth / 2;
    final left = isLeft ? null : item.x + 46;
    final right = isLeft ? (_canvasWidth - item.x + 16) : null;
    return Positioned(
      top: item.y - 44,
      left: left,
      right: right,
      child: const Text('🔥', style: TextStyle(fontSize: 36))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.12, duration: 1200.ms, curve: Curves.easeInOut),
    );
  }
}

// ── Path Painter ────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  final _Layout layout;
  final Color habitColor;
  _PathPainter({required this.layout, required this.habitColor});

  Path _smoothPath(List<Offset> pts) {
    final p = Path();
    if (pts.isEmpty) return p;
    p.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i]; final b = pts[i + 1]; final dy = b.dy - a.dy;
      p.cubicTo(a.dx, a.dy + dy * 0.5, b.dx, b.dy - dy * 0.5, b.dx, b.dy);
    }
    return p;
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, double dash, double gap) {
    for (final m in path.computeMetrics()) {
      double pos = 0;
      while (pos < m.length) {
        canvas.drawPath(m.extractPath(pos, min(pos + dash, m.length)), paint);
        pos += dash + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = layout.items.where((i) => !i.isBanner).toList();
    if (nodes.length < 2) return;
    final allPts = nodes.map((i) => Offset(i.x, i.y)).toList();
    final currentIdx = nodes.indexWhere((n) => n.node?.type == _NodeType.current);
    final full = _smoothPath(allPts);

    canvas.drawPath(full, Paint()..color = const Color(0xFF242424)..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(full, Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    if (currentIdx >= 0 && currentIdx + 1 <= allPts.length) {
      final donePts = allPts.sublist(0, currentIdx + 1);
      if (donePts.length >= 2) {
        final done = _smoothPath(donePts);
        canvas.drawPath(done, Paint()..color = habitColor.withValues(alpha: 0.25)..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        final rect = Rect.fromLTWH(0, donePts.first.dy, size.width, donePts.last.dy - donePts.first.dy + 1);
        canvas.drawPath(done, Paint()..shader = LinearGradient(colors: [habitColor, AppColors.mental], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(rect)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
        _drawDashed(canvas, done, Paint()..color = Colors.white.withValues(alpha: 0.12)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round, 6, 10);
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.layout != layout || old.habitColor != habitColor;
}

// ── Section Banner ──────────────────────────────────────────────────────────

class _SectionBanner extends StatelessWidget {
  final _LayoutItem item;
  const _SectionBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    final s = item.section;
    final totalXP = s.nodes.fold<int>(0, (sum, n) => sum + n.xp);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [s.color.withValues(alpha: 0.8), s.color.withValues(alpha: 0.533), s.color.withValues(alpha: 0.267)], stops: const [0.0, 0.6, 1.0], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.color.withValues(alpha: 0.33)),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(right: 20, top: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: s.color.withValues(alpha: 0.2)))),
          Positioned(right: 50, bottom: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: s.color.withValues(alpha: 0.13)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('WEEK ${s.week}', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(s.title.split('—').last.trim(), style: AppTypography.h3.copyWith(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(s.subtitle, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.65))),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('+$totalXP', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.xpGold)),
                    Text('XP', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.5))),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Path Node Widget ────────────────────────────────────────────────────────

class _PathNodeWidget extends StatelessWidget {
  final _LayoutItem item;
  final VoidCallback onTap;
  const _PathNodeWidget({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final node = item.node!;
    final isLocked = node.type == _NodeType.locked;
    final isCurrent = node.type == _NodeType.current;
    final isDone = node.type == _NodeType.done;
    final size = (node.isMilestone || isCurrent) ? 76.0 : 64.0;

    _NodeColors c;
    if (isLocked) { c = _lockedColors; }
    else if (node.isMilestone) { c = _goldColors; }
    else if (isCurrent) { c = _currentColors; }
    else { c = _sectionColors(item.section.color); }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 24,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isCurrent) ...[
                  _PulseRing(size: size, color: AppColors.primary),
                  _PulseRing(size: size, color: AppColors.primary, delay: 500),
                ],
                Container(
                  width: size, height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [c.top, c.mid, c.bot], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.42, 1.0]),
                    boxShadow: [
                      BoxShadow(color: c.shadow, offset: const Offset(0, 6), blurRadius: 0),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.45), offset: const Offset(0, 10), blurRadius: 24),
                    ],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned(top: size * 0.11, child: Container(width: size * 0.42, height: size * 0.15, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.32), borderRadius: BorderRadius.circular(99)))),
                    if (isDone) Icon(Icons.check_rounded, color: Colors.white, size: size * 0.4),
                    if (isCurrent) Icon(Icons.play_arrow_rounded, color: Colors.white, size: size * 0.42),
                    if (isLocked) Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.35), size: size * 0.34),
                    if (node.isMilestone) Text('🏆', style: TextStyle(fontSize: size * 0.4, color: isLocked ? null : null)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              node.isMilestone ? 'Wk ${item.section.week}!' : 'Day ${node.day}',
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: isLocked ? AppColors.textTertiary : AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatefulWidget {
  final double size;
  final Color color;
  final int delay;
  const _PulseRing({required this.size, required this.color, this.delay = 0});
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _scale = Tween<double>(begin: 1.0, end: 1.55).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.75, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _ctrl.repeat(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.size * _scale.value, height: widget.size * _scale.value,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color.withValues(alpha: _opacity.value * 0.45), width: 3)),
      ),
    );
  }
}

// ── Node Popup ──────────────────────────────────────────────────────────────

class _NodePopup extends StatelessWidget {
  final _LayoutItem item;
  final VoidCallback onClose;
  final VoidCallback onRecord;
  const _NodePopup({required this.item, required this.onClose, required this.onRecord});

  @override
  Widget build(BuildContext context) {
    final node = item.node!;
    final isLocked = node.type == _NodeType.locked;
    final isDone = node.type == _NodeType.done || (node.isMilestone && node.type == _NodeType.done);
    final isCurrent = node.type == _NodeType.current;
    final ctaLabel = isLocked ? '🔒  Not yet unlocked' : isDone ? '▶  Watch Vlog' : '🎬  Record Now';

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.borderDefault), left: BorderSide(color: AppColors.borderDefault), right: BorderSide(color: AppColors.borderDefault)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(99)))),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(node.isMilestone ? '🏆' : 'DAY ${node.day}',
                                style: node.isMilestone ? const TextStyle(fontSize: 52) : const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -0.96, color: AppColors.textPrimary, height: 1)),
                            const SizedBox(height: 4),
                            Text(item.section.title.split('—').last.trim(), style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ]),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(node.isMilestone ? '🏅 MILESTONE' : '📋 QUEST', style: AppTypography.caption.copyWith(color: item.section.color, letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(node.quest, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.55)),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        _RewardChip(emoji: '⚡', label: '+${node.xp} XP', color: AppColors.xpGold),
                        const SizedBox(width: 8),
                        _RewardChip(emoji: '🔥', label: 'Streak +1', color: AppColors.streakFire),
                        if (node.isMilestone) ...[const SizedBox(width: 8), _RewardChip(emoji: '🏅', label: 'Badge', color: AppColors.levelPurple)],
                      ]),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: FilledButton(
                          onPressed: isLocked ? null : () { onClose(); if (isCurrent) onRecord(); },
                          style: FilledButton.styleFrom(
                            backgroundColor: isLocked ? AppColors.backgroundSurface : item.section.color,
                            disabledBackgroundColor: AppColors.backgroundSurface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(ctaLabel, style: AppTypography.buttonText.copyWith(color: isLocked ? AppColors.textTertiary : Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .slideY(begin: 1.0, end: 0, duration: 300.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String emoji; final String label; final Color color;
  const _RewardChip({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.22))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _EmptyPathState extends StatelessWidget {
  const _EmptyPathState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.lg),
          Text('No habits yet', style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text('Create a habit to start your path', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Gallery Tab ─────────────────────────────────────────────────────────────

class _GalleryTab extends ConsumerWidget {
  final List<Vlog> vlogs;
  const _GalleryTab({required this.vlogs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vlogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🎬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text('No vlogs yet', style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Complete your first habit day\nto start your gallery', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final groupedVlogs = ref.watch(vlogsGroupedByHabitProvider);
    final habitNames = groupedVlogs.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: habitNames.length,
      itemBuilder: (context, index) {
        final habitName = habitNames[index];
        final habitVlogs = groupedVlogs[habitName]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(habitName, style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
                Text('${habitVlogs.length} vlogs', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ]),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 9 / 14),
              itemCount: habitVlogs.length,
              itemBuilder: (context, i) {
                final vlog = habitVlogs[i];
                return VlogThumbnail(
                  vlog: vlog,
                  onTap: () => context.push('/vlog/${vlog.id}'),
                  onLongPress: () => _confirmDelete(context, ref, vlog),
                );
              },
            ),
          ]),
        );
      },
    );
  }
}
