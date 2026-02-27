import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;

  const AppBottomNav({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    int getCurrentIndex() {
      switch (currentLocation) {
        case '/home':
          return 0;
        case '/journey':
          return 1;
        case '/record':
          return 2;
        case '/stats':
          return 3;
        case '/profile':
          return 4;
        default:
          return 0;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        backgroundColor: AppColors.backgroundPrimary,
        indicatorColor: Colors.transparent,
        selectedIndex: getCurrentIndex(),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/journey');
              break;
            case 2:
              context.go('/record');
              break;
            case 3:
              context.go('/stats');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: currentLocation == '/home'
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            selectedIcon: const Icon(
              Icons.home,
              color: AppColors.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.explore_outlined,
              color: currentLocation == '/journey'
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            selectedIcon: const Icon(
              Icons.explore,
              color: AppColors.primary,
            ),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: _RecordButton(isActive: currentLocation == '/record'),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
              color: currentLocation == '/stats'
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            selectedIcon: const Icon(
              Icons.bar_chart,
              color: AppColors.primary,
            ),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: currentLocation == '/profile'
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            selectedIcon: const Icon(
              Icons.person,
              color: AppColors.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isActive;

  const _RecordButton({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: const Icon(
        Icons.add_circle_outline,
        color: AppColors.textOnColor,
        size: 28,
      ),
    );
  }
}
