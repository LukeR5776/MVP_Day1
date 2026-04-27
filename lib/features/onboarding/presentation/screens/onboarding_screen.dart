import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/onboarding_repository.dart';

// Per-step background color palettes (list of colors used for blobs + waves)
const _stepPalettes = <List<Color>>[
  [Color(0xFF3B82F6), Color(0xFFA855F7)],                                       // 0 splash  blue-purple
  [Color(0xFF3B82F6), Color(0xFF1D4ED8)],                                       // 1 name    blue deep
  [Color(0xFF8B5CF6), Color(0xFFA855F7)],                                       // 2 goal    purple
  [Color(0xFF3B82F6), Color(0xFF22C55E), Color(0xFF8B5CF6), Color(0xFFF97316)], // 3 habits  all 4
  [Color(0xFF22C55E), Color(0xFFF59E0B)],                                       // 4 freq    green-gold
  [Color(0xFFF97316), Color(0xFFF59E0B)],                                       // 5 time    orange-gold
  [Color(0xFF3B82F6), Color(0xFFA855F7), Color(0xFF22C55E), Color(0xFFF97316)], // 6 done    celebration
];

const _stepProgressColors = [
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFF97316),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  int _dir = 1;
  bool _animating = false;

  // Answers
  String _name = '';
  String? _goal;
  final Set<String> _habits = {};
  String? _frequency;
  String? _timeOfDay;

  static const int _totalSteps = 7;

  void _goTo(int nextStep, {int dir = 1}) {
    if (_animating) return;
    setState(() {
      _dir = dir;
      _animating = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _step = nextStep;
          _animating = false;
        });
      }
    });
  }

  void _next() {
    if (_step < _totalSteps - 1) _goTo(_step + 1, dir: 1);
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1, dir: -1);
  }

  bool get _canProceed {
    switch (_step) {
      case 1:
        return _name.trim().isNotEmpty;
      case 3:
        return _habits.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _finish() async {
    await OnboardingRepository().setComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Animated wave background
          _AnimatedWaveBackground(step: _step),

          // Content with slide transition
          AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            offset: _animating ? Offset(_dir.toDouble(), 0) : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _animating ? 0.0 : 1.0,
              child: SafeArea(
                child: Column(
                  children: [
                    // Progress bar (steps 1–5)
                    if (_step > 0 && _step < _totalSteps - 1)
                      _buildProgressBar(),

                    // Step content
                    Expanded(child: _buildStep()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          // Step dots
          Expanded(
            child: Row(
              children: List.generate(_totalSteps - 2, (i) {
                final color = i < _step
                    ? _stepProgressColors[i % _stepProgressColors.length]
                    : Colors.white.withValues(alpha: 0.12);
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepSplash(onNext: _next);
      case 1:
        return _StepName(
          value: _name,
          onChange: (v) => setState(() => _name = v),
          onNext: _next,
          canProceed: _canProceed,
        );
      case 2:
        return _StepGoal(
          value: _goal,
          onChange: (v) {
            setState(() => _goal = v);
            Future.delayed(const Duration(milliseconds: 300), _next);
          },
        );
      case 3:
        return _StepHabits(
          selected: _habits,
          onToggle: (v) => setState(() {
            if (_habits.contains(v)) {
              _habits.remove(v);
            } else {
              _habits.add(v);
            }
          }),
          onNext: _next,
          canProceed: _canProceed,
        );
      case 4:
        return _StepFrequency(
          value: _frequency,
          onChange: (v) {
            setState(() => _frequency = v);
            Future.delayed(const Duration(milliseconds: 300), _next);
          },
        );
      case 5:
        return _StepTime(
          value: _timeOfDay,
          onChange: (v) {
            setState(() => _timeOfDay = v);
            Future.delayed(const Duration(milliseconds: 300), _next);
          },
        );
      case 6:
        return _StepCelebration(name: _name, onComplete: _finish);
      default:
        return const SizedBox();
    }
  }
}

// ── Animated Wave Background ────────────────────────────────────────────────

class _AnimatedWaveBackground extends StatefulWidget {
  final int step;
  const _AnimatedWaveBackground({required this.step});

  @override
  State<_AnimatedWaveBackground> createState() =>
      _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<_AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _stepPalettes[widget.step.clamp(0, _stepPalettes.length - 1)];
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        painter: _WavePainter(t: _ctrl.value, palette: palette),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  final List<Color> palette;

  _WavePainter({required this.t, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.backgroundPrimary,
    );

    // Animated blobs
    for (int i = 0; i < palette.length; i++) {
      final color = palette[i];
      final phase = i * pi * 0.7;
      final bx = size.width * (0.2 + 0.6 * (i / max(palette.length - 1, 1))) +
          sin(t * pi * 2 * 0.9 + phase) * 55;
      final by = size.height * (0.15 + 0.35 * (i % 2 == 0 ? 0 : 1)) +
          cos(t * pi * 2 * 0.7 + phase * 1.3) * 45;
      final r = 175.0 + i * 30;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: r));
      canvas.drawCircle(Offset(bx, by), r, paint);
    }

    // Wave lines near the bottom
    for (int w = 0; w < 3; w++) {
      final color = palette[w % palette.length];
      final waveY = size.height * 0.72 + w * 28;
      final path = Path();
      for (double x = 0; x <= size.width; x += 3) {
        final y = waveY +
            sin((x / size.width) * pi * 3 + t * pi * 2 * (1.2 + w * 0.4) + w) *
                (14 + w * 8) +
            sin((x / size.width) * pi * 5 + t * pi * 2 * 0.8 + w * 2) * 6;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.12 - w * 0.03)
          ..strokeWidth = 2.5 - w * 0.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t || old.palette != palette;
}

// ── Shared Widgets ──────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodyDefault.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final Color color;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.color,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Color.fromRGBO(r.toInt(), g.toInt(), b.toInt(), 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.09),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (multi)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? color : Colors.transparent,
                  border: Border.all(
                    color: selected ? color : AppColors.borderDefault,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              )
            else if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _CTAButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.buttonText.copyWith(
            color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.5),
            letterSpacing: 0.01,
          ),
        ),
      ),
    );
  }
}

// ── Step 0: Splash ──────────────────────────────────────────────────────────

class _StepSplash extends StatelessWidget {
  final VoidCallback onNext;
  const _StepSplash({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final pills = [
      ('💪', 'Build strength', AppColors.physical),
      ('🧠', 'Clear mind', AppColors.mental),
      ('🎨', 'Daily creativity', AppColors.creative),
      ('🌱', 'Keep growing', AppColors.growth),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Day',
                  style: const TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.04 * 68,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '1',
                  style: const TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.04 * 68,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            'Be the main character\nof your own journey',
            textAlign: TextAlign.center,
            style: AppTypography.bodyDefault.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 0.01,
            ),
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 40),

          // Habit pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: pills.map((p) {
              final (emoji, label, color) = p;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: AppTypography.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms),

          const SizedBox(height: 44),
          _CTAButton(
            label: 'Start your journey →',
            onTap: onNext,
            color: AppColors.primary,
          )
              .animate(delay: 450.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'Free forever · No credit card needed',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          )
              .animate(delay: 550.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Step 1: Name ────────────────────────────────────────────────────────────

class _StepName extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  final VoidCallback onNext;
  final bool canProceed;

  const _StepName({
    required this.value,
    required this.onChange,
    required this.onNext,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            emoji: '👋',
            title: "What should we\ncall you?",
            subtitle: "We'll personalize your journey.",
          ),
          const Spacer(),
          TextField(
            autofocus: true,
            onChanged: onChange,
            onSubmitted: canProceed ? (_) => onNext() : null,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Your name…',
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
          ),
          const SizedBox(height: 28),
          _CTAButton(
            label: 'Continue',
            onTap: canProceed ? onNext : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Goal ────────────────────────────────────────────────────────────

class _StepGoal extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChange;

  const _StepGoal({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('fitness', '💪', 'Get fit & strong', 'Build physical habits that last', AppColors.physical),
      ('mind', '🧠', 'Mental clarity', 'Reduce stress, sharpen focus', AppColors.mental),
      ('creative', '🎨', 'Express creatively', 'Make art, music, or writing daily', AppColors.creative),
      ('growth', '🌱', 'Personal growth', 'Learn, level up, become better', AppColors.growth),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            emoji: '🎯',
            title: "What's your\nmain goal?",
            subtitle: 'Pick one — you can add more later.',
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: options
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionCard(
                          emoji: o.$2,
                          label: o.$3,
                          desc: o.$4,
                          color: o.$5,
                          selected: value == o.$1,
                          onTap: () => onChange(o.$1),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Habits ──────────────────────────────────────────────────────────

class _StepHabits extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;
  final bool canProceed;

  const _StepHabits({
    required this.selected,
    required this.onToggle,
    required this.onNext,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      ('physical', '💪', 'Physical', 'Exercise, cold showers, running…', AppColors.physical),
      ('mental', '🧠', 'Mental', 'Meditation, journaling, reading…', AppColors.mental),
      ('creative', '🎨', 'Creative', 'Drawing, music, writing, art…', AppColors.creative),
      ('growth', '🌱', 'Growth', 'Language, skills, networking…', AppColors.growth),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            emoji: '✨',
            title: 'Which habits\nwill you build?',
            subtitle: 'Select all that apply.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: options
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionCard(
                          emoji: o.$2,
                          label: o.$3,
                          desc: o.$4,
                          color: o.$5,
                          selected: selected.contains(o.$1),
                          onTap: () => onToggle(o.$1),
                          multi: true,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _CTAButton(
            label: selected.isEmpty
                ? 'Select at least one'
                : 'Continue with ${selected.length} habit${selected.length == 1 ? '' : 's'}',
            onTap: canProceed ? onNext : null,
            color: AppColors.creative,
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Frequency ───────────────────────────────────────────────────────

class _StepFrequency extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChange;

  const _StepFrequency({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('3', '📅', '3× / week', 'Light start', AppColors.growth),
      ('5', '📆', '5× / week', 'Steady pace', AppColors.primary),
      ('7', '🗓️', 'Every day', 'Full commitment', AppColors.mental),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            emoji: '📅',
            title: 'How often do you\nwant to show up?',
            subtitle: 'Consistency beats intensity.',
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: options
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OptionCard(
                          emoji: o.$2,
                          label: o.$3,
                          desc: o.$4,
                          color: o.$5,
                          selected: value == o.$1,
                          onTap: () => onChange(o.$1),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 5: Time of Day ─────────────────────────────────────────────────────

class _StepTime extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChange;

  const _StepTime({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('morning', '🌅', 'Morning', 'Rise and grind, 5–9 AM', AppColors.xpGold),
      ('afternoon', '☀️', 'Afternoon', 'Midday momentum, 12–5 PM', AppColors.creative),
      ('evening', '🌙', 'Evening', 'Wind-down ritual, 6–10 PM', AppColors.mental),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            emoji: '⏰',
            title: 'When do you\ndo your best work?',
            subtitle: "We'll remind you at the right time.",
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: options
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OptionCard(
                          emoji: o.$2,
                          label: o.$3,
                          desc: o.$4,
                          color: o.$5,
                          selected: value == o.$1,
                          onTap: () => onChange(o.$1),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 6: Celebration ─────────────────────────────────────────────────────

class _StepCelebration extends StatelessWidget {
  final String name;
  final VoidCallback onComplete;

  const _StepCelebration({required this.name, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Champion' : name.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 72))
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 24),
          Text(
            "You're ready,\n$displayName!",
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.01,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 14),
          Text(
            'Your journey starts today.\nEvery day is Day 1 of something.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyDefault.copyWith(
              color: AppColors.textSecondary,
            ),
          )
              .animate(delay: 350.ms)
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 20),

          // Confetti emojis
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['⭐', '🎉', '✨', '🔥', '⭐']
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 22),
                      )
                          .animate(delay: Duration(milliseconds: 500 + e.key * 80))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.4, end: 0),
                    ))
                .toList(),
          ),
          const SizedBox(height: 48),
          _CTAButton(
            label: "Let's go 🚀",
            onTap: onComplete,
            color: AppColors.primary,
          )
              .animate(delay: 900.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
