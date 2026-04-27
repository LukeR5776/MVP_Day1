import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Tracks whether the user has completed onboarding.
/// Uses a simple marker file in the app documents directory.
class OnboardingRepository {
  static const _fileName = 'onboarding_complete.flag';

  Future<bool> isComplete() async {
    try {
      final file = await _file();
      return file.existsSync();
    } catch (e) {
      debugPrint('Onboarding check error: $e');
      return false;
    }
  }

  Future<void> setComplete() async {
    try {
      final file = await _file();
      await file.writeAsString('1');
      debugPrint('✅ Onboarding marked complete');
    } catch (e) {
      debugPrint('Onboarding save error: $e');
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}
