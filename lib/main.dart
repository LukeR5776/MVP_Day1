import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/data/repositories/onboarding_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if onboarding has been completed before building the router
  AppRouter.onboardingComplete = await OnboardingRepository().isComplete();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: Day1App(),
    ),
  );
}
