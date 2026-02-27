import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Types of video clips in the I-E-R framework
/// Intention → Evidence → Reflection
enum ClipType {
  intention,   // Before - setting commitment (front camera default)
  evidence,    // During - proof of doing (back camera default)
  reflection;  // After - how it went (front camera default)

  String get displayName {
    switch (this) {
      case ClipType.intention:
        return 'Intention';
      case ClipType.evidence:
        return 'Evidence';
      case ClipType.reflection:
        return 'Reflection';
    }
  }

  String get shortLabel {
    switch (this) {
      case ClipType.intention:
        return 'I';
      case ClipType.evidence:
        return 'E';
      case ClipType.reflection:
        return 'R';
    }
  }

  String get description {
    switch (this) {
      case ClipType.intention:
        return 'Set your commitment for today';
      case ClipType.evidence:
        return 'Show yourself doing it';
      case ClipType.reflection:
        return 'Share how it went';
    }
  }

  String get prompt {
    switch (this) {
      case ClipType.intention:
        return 'What are you about to do and why?';
      case ClipType.evidence:
        return 'Show yourself in action!';
      case ClipType.reflection:
        return 'How did it go? How do you feel?';
    }
  }

  IconData get icon {
    switch (this) {
      case ClipType.intention:
        return Icons.lightbulb_outline;
      case ClipType.evidence:
        return Icons.videocam;
      case ClipType.reflection:
        return Icons.auto_awesome;
    }
  }

  /// Default camera for this clip type
  bool get preferFrontCamera {
    switch (this) {
      case ClipType.intention:
        return true;  // Front camera for setting intention
      case ClipType.evidence:
        return false; // Back camera for proof
      case ClipType.reflection:
        return true;  // Front camera for reflection
    }
  }

  /// Get color for this clip type (uses primary blue)
  Color get color => AppColors.primary;

  /// Get the next clip type in sequence
  ClipType? get next {
    switch (this) {
      case ClipType.intention:
        return ClipType.evidence;
      case ClipType.evidence:
        return ClipType.reflection;
      case ClipType.reflection:
        return null; // Last in sequence
    }
  }

  /// Get the previous clip type in sequence
  ClipType? get previous {
    switch (this) {
      case ClipType.intention:
        return null; // First in sequence
      case ClipType.evidence:
        return ClipType.intention;
      case ClipType.reflection:
        return ClipType.evidence;
    }
  }

  /// Index in the I-E-R sequence (0, 1, 2)
  int get sequenceIndex {
    switch (this) {
      case ClipType.intention:
        return 0;
      case ClipType.evidence:
        return 1;
      case ClipType.reflection:
        return 2;
    }
  }
}
