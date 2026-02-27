import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/screen_scaffold.dart';
import '../../../../core/theme/app_spacing.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Stats',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📊',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Gamification stats coming soon',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
