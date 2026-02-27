# Day1 - MVP Development Plan
## "Be the main character of your own journey"

**Document Version:** 1.0  
**Created:** January 2026  
**Target Launch:** May-June 2026

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Vision & Core Loop](#2-product-vision--core-loop)
3. [Feature Specification](#3-feature-specification)
4. [Technical Architecture](#4-technical-architecture)
5. [Database Schema](#5-database-schema)
6. [Gamification System](#6-gamification-system)
7. [UI/UX Guidelines](#7-uiux-guidelines)
8. [Development Timeline](#8-development-timeline)
9. [Risk Register](#9-risk-register)
10. [Launch & Growth Strategy](#10-launch--growth-strategy)
11. [Success Metrics](#11-success-metrics)

---

## 1. Executive Summary

### The Problem
Young people (17-22) want to build transformative habits but struggle with consistency because checking boxes doesn't create real accountability—and they have no tangible proof of their journey.

### The Solution
**Day1** is a habit accountability app that has users document their journey through short video clips, automatically compiled into "Day X" vlogs. It combines the trending "Day X of Y" social format with gamification mechanics proven by Duolingo and fitness apps.

### Core Value Proposition
- **Accountability through evidence:** You can't lie to yourself on camera
- **Visual transformation:** Watch yourself grow over days, weeks, months
- **Shareable content:** Your habit journey becomes content for social platforms
- **Gamified consistency:** XP, streaks, and badges make showing up addictive

### Key Differentiators
| Traditional Habit Apps | Day1 |
|------------------------|------|
| Check a box | Record proof |
| Data charts | Video journey |
| Private progress | Shareable vlogs |
| Guilt-driven | Main character energy |

### Target Metrics (7 months post-launch)
- 50,000+ downloads
- 15% D30 retention (industry avg: 6%)
- 3+ min average daily session
- 5,000+ vlogs shared to social platforms

---

## 2. Product Vision & Core Loop

### The Daily Core Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                        DAILY CORE LOOP                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1. INTENTION (Morning/Before)                                 │
│      └─ "Day 14 of cold showers. Today I'm going full 3 min"   │
│         📹 5-15 second clip                                     │
│                        ↓                                        │
│   2. EVIDENCE (During)                                          │
│      └─ Quick clip of you doing the thing                       │
│         📹 5-30 second clip (1+ clips)                          │
│                        ↓                                        │
│   3. REFLECTION (After)                                         │
│      └─ "That was brutal but I feel amazing"                    │
│         📹 10-30 second clip                                    │
│                        ↓                                        │
│   4. AUTO-COMPILE                                               │
│      └─ App stitches clips into "Day 14" vlog                   │
│         🎬 30-90 second final video                             │
│                        ↓                                        │
│   5. REWARD                                                     │
│      └─ +75 XP, streak continues, badge check                   │
│         🏆 Dopamine hit                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The 4 Wins Framework (Habit Categories)

Users organize their habits into four life pillars, each with its own journey tracker:

| Category | Icon | Example Habits | Color |
|----------|------|----------------|-------|
| **Physical** | 💪 | Cold showers, gym, running, stretching | Blue #2563EB |
| **Mental** | 🧠 | Reading, meditation, journaling, no phone AM | Purple #7C3AED |
| **Creative** | 🎨 | Art, music, writing, coding projects | Orange #EA580C |
| **Growth** | 🌱 | Language learning, skill practice, networking | Green #16A34A |

**Why 4 Categories:**
- Forces prioritization (max 1-2 active habits per category)
- Creates balanced self-improvement
- Enables category-specific achievements
- Prevents habit overload (max 4-6 active habits recommended)

### Minimum Viable Habit Completion

To mark a day complete, user MUST record:
- ✅ At least 1 clip (intention OR evidence OR reflection)
- ✅ Minimum 5 seconds of footage

**Friction reduction:** If user only has time for one clip, they can record a quick "did it" clip. The vlog will be shorter but the streak survives.

---

## 3. Feature Specification

### MVP Features (v1.0) - Must Have

#### 3.1 Onboarding
- [ ] Splash screen with brand animation
- [ ] 3-screen value prop carousel
- [ ] "Pick your first habit" selector with suggestions
- [ ] Notification permission request with clear value prop
- [ ] Optional account creation (email/Google/Apple) OR local-only mode

#### 3.2 Habit Management
- [ ] Create habit with: name, category, target frequency (daily/weekly)
- [ ] Edit/archive/delete habits
- [ ] View habits by category (4 Wins grid)
- [ ] Active habit limit: 6 maximum (enforced with upgrade prompt for later)
- [ ] Habit templates library (20+ pre-made habits)

#### 3.3 Video Recording
- [ ] In-app camera with "Day X" overlay
- [ ] Record intention clip (front camera default)
- [ ] Record evidence clip (back camera default)
- [ ] Record reflection clip (front camera default)
- [ ] Tap to record, tap to stop (no hold required)
- [ ] Preview and re-record option
- [ ] Minimum 5 sec, maximum 60 sec per clip
- [ ] Support for importing clips from camera roll

#### 3.4 Auto-Compilation Engine
- [ ] Stitch clips with 0.3s fade transitions
- [ ] Add "Day X" title card at start (2 seconds)
- [ ] Add subtle background music (optional, user toggleable)
- [ ] Export at 1080x1920 (9:16 vertical)
- [ ] Compression to <50MB per vlog
- [ ] Processing indicator with ETA

#### 3.5 Journey Gallery
- [ ] Calendar view showing completed days
- [ ] Grid view of all vlogs (thumbnails)
- [ ] Tap to play vlog
- [ ] Share to Instagram/TikTok/Messages
- [ ] Download to camera roll
- [ ] Delete vlog (with confirmation)

#### 3.6 Gamification (Core)
- [ ] XP system with level progression
- [ ] Current streak counter (prominent display)
- [ ] Best streak record
- [ ] Daily XP breakdown screen
- [ ] Level-up celebration animation

#### 3.7 Notifications
- [ ] Customizable reminder time per habit
- [ ] Streak danger alert (missed today, streak at risk!)
- [ ] Weekly summary push notification
- [ ] Smart timing based on past completion patterns (v1.5)

#### 3.8 Settings & Profile
- [ ] Edit profile (name, avatar)
- [ ] Notification preferences
- [ ] Video quality settings (high/medium/low)
- [ ] Storage management (clear old vlogs)
- [ ] Export all data
- [ ] Delete account

---

### Post-MVP Features (v2.0+) - Roadmap

#### Phase 2: Social & Sharing (Month 5-6)
- [ ] Public profile pages
- [ ] Follow friends
- [ ] Friend activity feed
- [ ] "Cheer" reactions on vlogs
- [ ] Accountability partner matching
- [ ] Group challenges

#### Phase 3: Advanced Gamification (Month 6-7)
- [ ] Achievement badges (50+ badges)
- [ ] Weekly/monthly journey compilations
- [ ] Leaderboards (opt-in)
- [ ] Seasonal challenges
- [ ] Custom themes/skins unlockable with XP

#### Phase 4: Monetization (Month 8+)
- [ ] Day1 Pro subscription
  - Cloud backup
  - Advanced editing tools
  - Custom music library
  - Priority processing
  - Exclusive badges
- [ ] One-time purchases (themes, music packs)

---

## 4. Technical Architecture

### Stack Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT (Flutter)                         │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer          │  State Management  │  Local Storage        │
│  ─────────         │  ─────────────────  │  ─────────────        │
│  • Flutter Widgets │  • Riverpod        │  • Isar (habits,      │
│  • Custom painter  │  • StateNotifier   │    progress, XP)      │
│  • Animations      │  • AsyncValue      │  • File system        │
│                    │                    │    (video clips)      │
├─────────────────────────────────────────────────────────────────┤
│                      VIDEO PROCESSING                            │
│  ────────────────────────────────────────────────────────────── │
│  • camera (recording)                                           │
│  • video_player (playback)                                      │
│  • ffmpeg_kit_flutter (compilation, encoding)                   │
│  • image (thumbnail generation)                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ (MVP: Optional)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND (Supabase)                          │
├─────────────────────────────────────────────────────────────────┤
│  Auth             │  Database           │  Storage              │
│  ────             │  ────────           │  ───────              │
│  • Email/Password │  • PostgreSQL       │  • Video backup       │
│  • Google OAuth   │  • User profiles    │  • Profile avatars    │
│  • Apple Sign In  │  • Sync metadata    │  • (User pays/ads)    │
│                   │  • Leaderboards     │                       │
├─────────────────────────────────────────────────────────────────┤
│                      EDGE FUNCTIONS                              │
│  ────────────────────────────────────────────────────────────── │
│  • Weekly digest email                                          │
│  • Push notification scheduling                                 │
│  • Analytics aggregation                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      THIRD-PARTY SERVICES                        │
├─────────────────────────────────────────────────────────────────┤
│  Analytics        │  Notifications      │  Crash Reporting      │
│  ─────────        │  ─────────────      │  ────────────────     │
│  • PostHog        │  • Firebase Cloud   │  • Sentry             │
│  • (Free tier)    │    Messaging        │  • (Free tier)        │
└─────────────────────────────────────────────────────────────────┘
```

### Key Package Dependencies

```yaml
# pubspec.yaml - Core Dependencies

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Local Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.0
  
  # Video/Camera
  camera: ^0.10.5
  video_player: ^2.8.0
  ffmpeg_kit_flutter_full_gpl: ^6.0.0
  image: ^4.1.0
  
  # Backend (Optional for MVP)
  supabase_flutter: ^2.0.0
  
  # Notifications
  flutter_local_notifications: ^16.0.0
  firebase_messaging: ^14.7.0
  
  # UI/UX
  flutter_animate: ^4.3.0
  lottie: ^2.7.0
  cached_network_image: ^3.3.0
  share_plus: ^7.2.0
  
  # Utilities
  uuid: ^4.2.0
  intl: ^0.18.0
  url_launcher: ^6.2.0
  
  # Analytics
  posthog_flutter: ^4.0.0
  sentry_flutter: ^7.14.0

dev_dependencies:
  # Code Generation
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  isar_generator: ^3.1.0
```

### Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── gamification_constants.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── analytics_service.dart
│   │   └── video_processing_service.dart
│   └── utils/
│       ├── date_utils.dart
│       ├── file_utils.dart
│       └── validators.dart
│
├── features/
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── habits/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── habit.dart
│   │   │   │   └── habit.g.dart (generated)
│   │   │   └── repositories/
│   │   │       └── habit_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── habits_home_screen.dart
│   │   │   │   ├── habit_detail_screen.dart
│   │   │   │   └── create_habit_screen.dart
│   │   │   └── widgets/
│   │   │       ├── habit_card.dart
│   │   │       ├── four_wins_grid.dart
│   │   │       └── streak_indicator.dart
│   │   └── providers/
│   │       └── habits_provider.dart
│   │
│   ├── recording/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── video_clip.dart
│   │   │   │   └── daily_vlog.dart
│   │   │   └── repositories/
│   │   │       └── vlog_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── record_screen.dart
│   │   │   │   ├── clip_preview_screen.dart
│   │   │   │   └── compile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── day_overlay.dart
│   │   │       ├── record_button.dart
│   │   │       └── clip_timeline.dart
│   │   └── providers/
│   │       ├── camera_provider.dart
│   │       └── compilation_provider.dart
│   │
│   ├── journey/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── journey_gallery_screen.dart
│   │   │   │   ├── vlog_player_screen.dart
│   │   │   │   └── calendar_view_screen.dart
│   │   │   └── widgets/
│   │   │       ├── vlog_thumbnail.dart
│   │   │       └── journey_calendar.dart
│   │   └── providers/
│   │       └── journey_provider.dart
│   │
│   ├── gamification/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_progress.dart
│   │   │   │   ├── achievement.dart
│   │   │   │   └── badge.dart
│   │   │   └── repositories/
│   │   │       └── gamification_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── achievements_screen.dart
│   │   │   └── widgets/
│   │   │       ├── xp_bar.dart
│   │   │       ├── level_badge.dart
│   │   │       ├── streak_flame.dart
│   │   │       └── celebration_overlay.dart
│   │   └── providers/
│   │       └── gamification_provider.dart
│   │
│   └── settings/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── settings_screen.dart
│       │   └── widgets/
│       └── providers/
│           └── settings_provider.dart
│
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── app_bottom_nav.dart
        └── loading_indicator.dart
```

### Video Processing Pipeline

```
┌────────────────────────────────────────────────────────────────┐
│                   VIDEO COMPILATION PIPELINE                    │
└────────────────────────────────────────────────────────────────┘

INPUT: Raw clips from user
├── intention_clip.mp4 (5-15 sec)
├── evidence_clip_1.mp4 (5-30 sec)
├── evidence_clip_2.mp4 (optional)
└── reflection_clip.mp4 (10-30 sec)

STEP 1: Normalize clips
├── Resize to 1080x1920 (9:16)
├── Normalize audio levels
└── Convert to consistent codec (H.264)

STEP 2: Generate title card
├── Create "DAY 14" image
├── Habit name subtitle
└── Duration: 2 seconds

STEP 3: Concatenate with transitions
├── Title card (2s)
├── Fade transition (0.3s)
├── Intention clip
├── Fade transition (0.3s)
├── Evidence clip(s)
├── Fade transition (0.3s)
├── Reflection clip
└── End card with streak count (1.5s)

STEP 4: Add background music (optional)
├── Ducking: -12dB under speech
├── Fade in/out
└── User-selected track OR app default

STEP 5: Export
├── Output: day_14_cold_showers.mp4
├── Codec: H.264
├── Bitrate: 8 Mbps
└── Target size: <50 MB

FFmpeg command (simplified):
ffmpeg -i title.mp4 -i intention.mp4 -i evidence.mp4 -i reflection.mp4 \
  -filter_complex "[0][1]xfade=transition=fade:duration=0.3:offset=1.7[v1]; \
  [v1][2]xfade=transition=fade:duration=0.3:offset=X[v2]; \
  [v2][3]xfade=transition=fade:duration=0.3:offset=Y[v]" \
  -map "[v]" -c:v libx264 -preset fast -crf 23 output.mp4
```

---

## 5. Database Schema

### Isar Collections (Local Database)

```dart
// lib/features/habits/data/models/habit.dart

import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uuid;
  
  late String name;
  late String description;
  
  @Enumerated(EnumType.name)
  late HabitCategory category;
  
  @Enumerated(EnumType.name)
  late HabitFrequency frequency;
  
  late DateTime createdAt;
  late DateTime? archivedAt;
  
  // Notification settings
  late bool notificationsEnabled;
  late int? reminderHour;    // 0-23
  late int? reminderMinute;  // 0-59
  
  // Stats (denormalized for quick access)
  late int currentStreak;
  late int bestStreak;
  late int totalDaysCompleted;
  
  // Links
  final dailyLogs = IsarLinks<DailyLog>();
}

enum HabitCategory {
  physical,   // 💪
  mental,     // 🧠
  creative,   // 🎨
  growth,     // 🌱
}

enum HabitFrequency {
  daily,
  weekdays,     // Mon-Fri
  weekends,     // Sat-Sun
  threePerWeek, // Any 3 days
  custom,
}
```

```dart
// lib/features/recording/data/models/daily_log.dart

@collection
class DailyLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uuid;
  
  @Index(composite: [CompositeIndex('habitUuid')])
  late DateTime date;  // Date only, no time
  
  late String habitUuid;
  
  @Enumerated(EnumType.name)
  late LogStatus status;
  
  late int dayNumber;  // "Day X" of this habit
  
  // Video data
  late List<String> clipPaths;  // Local file paths
  late String? compiledVlogPath;
  late int? vlogDurationSeconds;
  late String? thumbnailPath;
  
  // Timestamps
  late DateTime createdAt;
  late DateTime? completedAt;
  late DateTime? compiledAt;
  
  // XP awarded for this log
  late int xpEarned;
  
  // Notes (optional text reflection)
  late String? notes;
}

enum LogStatus {
  pending,     // Started but not complete
  recording,   // Actively recording clips
  compiling,   // Video being processed
  completed,   // Done for the day
  missed,      // Day passed without completion
}
```

```dart
// lib/features/recording/data/models/video_clip.dart

@collection
class VideoClip {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uuid;
  
  late String dailyLogUuid;
  
  @Enumerated(EnumType.name)
  late ClipType type;
  
  late String localPath;
  late int durationSeconds;
  late int fileSizeBytes;
  
  late DateTime recordedAt;
  
  // Processing metadata
  late bool isProcessed;
  late String? processedPath;
}

enum ClipType {
  intention,   // Before - setting commitment
  evidence,    // During - proof of doing
  reflection,  // After - how it went
}
```

```dart
// lib/features/gamification/data/models/user_progress.dart

@collection
class UserProgress {
  Id id = Isar.autoIncrement;
  
  // Only one UserProgress record per user
  @Index(unique: true)
  late String userUuid;
  
  // XP & Leveling
  late int totalXp;
  late int currentLevel;
  
  // Global stats
  late int totalDaysLogged;
  late int totalVlogsCreated;
  late int totalMinutesRecorded;
  
  // Streaks (across all habits)
  late int longestEverStreak;
  late int currentActiveHabits;
  
  // Timestamps
  late DateTime createdAt;
  late DateTime lastActiveAt;
  
  // Achievements
  final unlockedAchievements = IsarLinks<Achievement>();
}
```

```dart
// lib/features/gamification/data/models/achievement.dart

@collection
class Achievement {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String achievementId;  // e.g., "first_vlog", "7_day_streak"
  
  late String name;
  late String description;
  late String iconPath;
  
  @Enumerated(EnumType.name)
  late AchievementCategory category;
  
  @Enumerated(EnumType.name)
  late AchievementRarity rarity;
  
  late int xpReward;
  
  // Unlock tracking
  late bool isUnlocked;
  late DateTime? unlockedAt;
  
  // Progress (for progressive achievements)
  late int? currentProgress;
  late int? targetProgress;
}

enum AchievementCategory {
  streaks,
  milestones,
  categories,
  social,
  special,
}

enum AchievementRarity {
  common,     // Bronze
  uncommon,   // Silver  
  rare,       // Gold
  epic,       // Diamond
  legendary,  // Prismatic
}
```

### Supabase Schema (Cloud Sync - Optional for MVP)

```sql
-- Only needed if implementing cloud sync

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync metadata (not actual video data for MVP)
CREATE TABLE public.habit_sync (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  habit_uuid TEXT NOT NULL,
  habit_data JSONB NOT NULL,  -- Serialized habit
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, habit_uuid)
);

CREATE TABLE public.progress_sync (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) UNIQUE,
  progress_data JSONB NOT NULL,
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leaderboard (opt-in)
CREATE TABLE public.leaderboard (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  week_start DATE NOT NULL,
  total_xp INT DEFAULT 0,
  habits_completed INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  UNIQUE(user_id, week_start)
);

-- Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_sync ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress_sync ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
  
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
```

---

## 6. Gamification System

### XP System

```
┌────────────────────────────────────────────────────────────────┐
│                        XP REWARDS                               │
└────────────────────────────────────────────────────────────────┘

BASE ACTIONS
├── Record intention clip ............... +10 XP
├── Record evidence clip ................ +15 XP (each)
├── Record reflection clip .............. +10 XP
├── Complete daily log (all 3 types) .... +25 XP bonus
└── Compile vlog ........................ +15 XP

STREAK MULTIPLIERS
├── 3-day streak ....................... 1.1x multiplier
├── 7-day streak ....................... 1.25x multiplier
├── 14-day streak ...................... 1.5x multiplier
├── 30-day streak ...................... 2.0x multiplier
└── 100-day streak ..................... 3.0x multiplier

DAILY BONUSES
├── First habit of day ................. +20 XP
├── Early bird (before 8 AM) ........... +15 XP
├── Night owl (after 10 PM) ............ +10 XP
└── Complete all active habits ......... +50 XP

MAXIMUM DAILY XP (example with 3 habits)
├── 3 complete logs: 3 × 75 = 225 XP
├── All habits bonus: +50 XP
├── First habit bonus: +20 XP
├── Time bonus: +15 XP
├── 7-day multiplier: × 1.25
└── TOTAL: ~387 XP possible
```

### Level Progression

```
LEVEL FORMULA: XP required = 100 × (level ^ 1.5)

Level 1:  0 XP        Level 11: 3,649 XP
Level 2:  100 XP      Level 12: 4,157 XP
Level 3:  283 XP      Level 13: 4,689 XP
Level 4:  520 XP      Level 14: 5,244 XP
Level 5:  800 XP      Level 15: 5,822 XP
Level 6:  1,122 XP    Level 20: 8,944 XP
Level 7:  1,481 XP    Level 25: 12,500 XP
Level 8:  1,876 XP    Level 30: 16,432 XP
Level 9:  2,304 XP    Level 50: 35,355 XP
Level 10: 2,764 XP    Level 100: 100,000 XP

LEVEL TITLES (earned at milestones)
├── Levels 1-4:   Beginner
├── Levels 5-9:   Apprentice  
├── Levels 10-14: Rising Star
├── Levels 15-19: Dedicated
├── Levels 20-29: Warrior
├── Levels 30-39: Champion
├── Levels 40-49: Legend
└── Levels 50+:   Main Character 👑
```

### Achievement System

```
┌────────────────────────────────────────────────────────────────┐
│                    ACHIEVEMENTS (50 total)                      │
└────────────────────────────────────────────────────────────────┘

STREAK ACHIEVEMENTS (12)
├── 🔥 First Flame ............. 3-day streak (Common, 50 XP)
├── 🔥 Week Warrior ............ 7-day streak (Common, 100 XP)
├── 🔥 Fortnight Fighter ....... 14-day streak (Uncommon, 200 XP)
├── 🔥 Monthly Master .......... 30-day streak (Rare, 500 XP)
├── 🔥 Quarter Crusher ......... 90-day streak (Epic, 1000 XP)
├── 🔥 Centurion ............... 100-day streak (Epic, 1500 XP)
├── 🔥 Half Year Hero .......... 180-day streak (Legendary, 3000 XP)
├── 🔥 Year of You ............. 365-day streak (Legendary, 10000 XP)
├── 🔥 Unbreakable ............. Never break a streak after 30 days
├── 🔥 Comeback Kid ............ Restart after 50+ day streak break
├── 🔥 Multi-Flame ............. 7-day streak on 3+ habits same time
└── 🔥 Perfect Week ............ Complete all habits every day for 7 days

MILESTONE ACHIEVEMENTS (10)
├── 🎬 Day 1 ................... Create first vlog (Common, 25 XP)
├── 🎬 Getting Started ......... 10 total vlogs (Common, 50 XP)
├── 🎬 Content Creator ......... 50 total vlogs (Uncommon, 150 XP)
├── 🎬 Prolific ................ 100 total vlogs (Rare, 300 XP)
├── 🎬 Documentarian ........... 250 total vlogs (Epic, 750 XP)
├── 🎬 Director ................ 500 total vlogs (Legendary, 2000 XP)
├── 📱 Social Butterfly ........ Share first vlog (Common, 50 XP)
├── 📱 Influencer .............. Share 10 vlogs (Uncommon, 150 XP)
├── 📱 Viral Potential ......... Share 50 vlogs (Rare, 400 XP)
└── 🕐 Marathon ................ 100+ minutes recorded total

CATEGORY ACHIEVEMENTS (12)
├── 💪 Physical Starter ........ First physical habit vlog
├── 💪 Body Builder ............ 30 days physical habit
├── 💪 Fitness Legend .......... 100 days physical habit
├── 🧠 Mind Opener ............. First mental habit vlog
├── 🧠 Zen Master .............. 30 days mental habit
├── 🧠 Enlightened ............. 100 days mental habit
├── 🎨 Creative Spark .......... First creative habit vlog
├── 🎨 Artist .................. 30 days creative habit
├── 🎨 Visionary ............... 100 days creative habit
├── 🌱 Growth Seeker ........... First growth habit vlog
├── 🌱 Improver ................ 30 days growth habit
└── 🌱 Evolved ................. 100 days growth habit

SPECIAL ACHIEVEMENTS (8)
├── 🌅 Early Bird .............. Complete 10 habits before 7 AM
├── 🌙 Night Owl ............... Complete 10 habits after 10 PM
├── 🎯 Focused ................. Single habit for 60+ days
├── 🔄 Balanced ................ Active habit in all 4 categories
├── 📅 Weekend Warrior ......... Never miss a weekend for 4 weeks
├── 🗓️ Weekday Wonder .......... Never miss a weekday for 4 weeks
├── 🆕 New Year New You ........ Create habit on Jan 1st
└── 🎂 Anniversary ............. Use app for 1 year

COMMUNITY ACHIEVEMENTS (8) [Post-MVP]
├── 👋 First Friend ............ Add first friend
├── 👥 Squad ................... Have 5 friends
├── 📣 Cheerleader ............. Cheer 50 times
├── 🤝 Accountability Partner .. Complete 30 days with partner
├── 🏆 Challenger .............. Complete first group challenge
├── 🥇 Champion ................ Win a group challenge
├── 💪 Inspirer ................ Get 100 cheers on your vlogs
└── 🌟 Influencer .............. 10 people started habit after you
```

### Streak Mechanics

```
STREAK RULES
├── Daily habits: Must complete every calendar day
├── Weekday habits: Must complete Mon-Fri (weekends don't break)
├── Weekend habits: Must complete Sat-Sun (weekdays don't break)
├── 3x/week habits: Must complete 3 days within Mon-Sun
└── Freeze: 1 free streak freeze every 7 days (like Duolingo)

STREAK RECOVERY (Pro feature for v2)
├── Within 24 hours: -50% XP penalty, streak continues
├── Within 48 hours: -75% XP penalty, streak continues
└── After 48 hours: Streak resets

VISUAL STREAK INDICATORS
├── 🔥 Standard flame: Active streak
├── 🔥🔥 Double flame: 7+ day streak
├── 🔥🔥🔥 Triple flame: 30+ day streak
├── 💎🔥 Diamond flame: 100+ day streak
└── ❄️ Frozen: Streak freeze active
```

---

## 7. UI/UX Guidelines

### Design Principles

1. **Main Character Energy**: Bold, confident, empowering design
2. **Frictionless Recording**: Max 2 taps to start recording
3. **Celebration Overload**: Every completion feels like a win
4. **Dark Mode First**: Most Gen-Z users prefer dark mode
5. **Thumb-Zone Friendly**: Core actions reachable with one hand

### Color Palette

```
PRIMARY COLORS
├── Background Dark ........ #0F0F0F
├── Background Card ........ #1A1A1A
├── Surface ................ #262626
├── Primary Blue ........... #3B82F6
├── Primary Blue Light ..... #60A5FA
└── Primary Blue Dark ...... #1D4ED8

CATEGORY COLORS
├── Physical ............... #2563EB (Blue)
├── Mental ................. #7C3AED (Purple)
├── Creative ............... #EA580C (Orange)
└── Growth ................. #16A34A (Green)

GAMIFICATION COLORS
├── XP Gold ................ #F59E0B
├── Streak Fire ............ #EF4444
├── Level Up ............... #8B5CF6
├── Success Green .......... #22C55E
└── Warning Orange ......... #F97316

NEUTRAL COLORS
├── Text Primary ........... #FFFFFF
├── Text Secondary ......... #A3A3A3
├── Text Tertiary .......... #737373
├── Border ................. #404040
└── Disabled ............... #525252
```

### Typography

```
FONT FAMILY: Inter (Google Fonts - free, modern, highly legible)
FALLBACK: SF Pro Display (iOS), Roboto (Android)

HEADING STYLES
├── H1 (Main titles) ....... 32px, Bold (700), -0.5 tracking
├── H2 (Section titles) .... 24px, SemiBold (600), -0.25 tracking
├── H3 (Card titles) ....... 20px, SemiBold (600), 0 tracking
└── H4 (Labels) ............ 16px, Medium (500), 0 tracking

BODY STYLES
├── Body Large ............. 18px, Regular (400), 0.15 tracking
├── Body Regular ........... 16px, Regular (400), 0.15 tracking
├── Body Small ............. 14px, Regular (400), 0.1 tracking
└── Caption ................ 12px, Medium (500), 0.2 tracking

SPECIAL STYLES
├── Day Counter ............ 64px, Black (900), -2 tracking
├── XP Display ............. 28px, Bold (700), 0 tracking
├── Streak Number .......... 48px, Bold (700), -1 tracking
└── Button Text ............ 16px, SemiBold (600), 0.5 tracking
```

### Key Screen Wireframes

```
┌─────────────────────────────────────┐
│           HOME SCREEN               │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │  🔥 14 Day Streak          │   │
│  │  ████████████░░ Level 12    │   │
│  └─────────────────────────────┘   │
│                                     │
│  TODAY'S HABITS                     │
│  ┌─────────────────────────────┐   │
│  │ 💪 Cold Showers      Day 14 │   │
│  │ [████████░░] 2/3 clips      │   │
│  │         [ RECORD ]          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 🧠 Meditation        Day 7  │   │
│  │ [ ] Not started             │   │
│  │         [ START ]           │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 🎨 Guitar Practice   Day 21 │   │
│  │ [██████████] Complete ✓     │   │
│  │         [ VIEW ]            │   │
│  └─────────────────────────────┘   │
│                                     │
│  ───────────────────────────────   │
│  [Home] [Journey] [+] [Stats] [Me] │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         RECORDING SCREEN            │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │                             │   │
│  │      CAMERA PREVIEW         │   │
│  │                             │   │
│  │   ┌───────────────────┐     │   │
│  │   │     DAY 14        │     │   │
│  │   │   Cold Showers    │     │   │
│  │   └───────────────────┘     │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  CLIPS: [✓ Intent] [● Evidence] [ ]│
│                                     │
│         ┌─────────────┐            │
│         │             │            │
│         │   ◉ REC     │            │
│         │             │            │
│         └─────────────┘            │
│                                     │
│  [🔄 Flip]              [✓ Done]   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         JOURNEY GALLERY             │
├─────────────────────────────────────┤
│  Cold Showers Journey               │
│  🔥 14 days | 💪 Physical           │
│                                     │
│  [Calendar] [Grid] [Timeline]       │
│  ─────────────────────────────────  │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │Day 1│ │Day 2│ │Day 3│ │Day 4│  │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │ │ ▶️  │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │Day 5│ │Day 6│ │Day 7│ │Day 8│  │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │ │ ▶️  │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │Day 9│ │D.10 │ │D.11 │ │D.12 │  │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │ │ ▶️  │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│                                     │
│  [ Create Weekly Recap Vlog ]       │
│                                     │
│  ───────────────────────────────   │
│  [Home] [Journey] [+] [Stats] [Me] │
└─────────────────────────────────────┘
```

### Animation Guidelines

```
MICRO-INTERACTIONS
├── Button press: Scale 0.95, duration 100ms
├── Card tap: Subtle glow + haptic
├── Toggle switch: Spring animation
└── List items: Stagger fade-in 50ms delay

CELEBRATIONS
├── Level up: Full screen confetti + number animation
├── Achievement: Badge flies in from bottom + glow pulse
├── Streak milestone: Fire animation grows + shake
├── Day complete: Check mark draws + burst particles
└── Vlog compiled: Cinematic reveal with sound

TRANSITIONS
├── Screen push: Slide from right, 300ms
├── Modal present: Slide from bottom, 350ms
├── Tab switch: Fade crossfade, 200ms
└── Recording start: Zoom in, 250ms

TOOLS
├── flutter_animate: Declarative animations
├── lottie: Complex celebratory animations
└── rive: Interactive animations (optional)
```

---

## 8. Development Timeline

### Phase 0: Setup & Foundation (Week 1-2)

```
WEEK 1: Project Setup
├── Day 1-2: Repository setup, Flutter project init
│   ├── Create GitHub repo with proper .gitignore
│   ├── Configure Flutter project structure
│   ├── Set up linting rules (very_good_analysis)
│   └── Configure VS Code/Android Studio
│
├── Day 3-4: Core dependencies & architecture
│   ├── Add all pubspec.yaml dependencies
│   ├── Set up Riverpod providers structure
│   ├── Configure Isar database
│   └── Create base theme (colors, typography)
│
└── Day 5-7: Navigation & shell
    ├── Set up go_router navigation
    ├── Create bottom navigation shell
    ├── Build placeholder screens for all tabs
    └── Test on both iOS and Android emulators

WEEK 2: Design System & Components
├── Day 1-2: Core UI components
│   ├── Primary/secondary buttons
│   ├── Input fields
│   ├── Cards and containers
│   └── Loading indicators
│
├── Day 3-4: Habit-specific components
│   ├── Habit card widget
│   ├── Four Wins grid layout
│   ├── Streak indicator widget
│   └── XP bar component
│
└── Day 5-7: Onboarding flow (basic)
    ├── Splash screen
    ├── Value prop carousel (3 screens)
    ├── Habit selection screen
    └── Notification permission request
```

### Phase 1: Core Habit Flow (Week 3-5)

```
WEEK 3: Habit CRUD
├── Day 1-2: Habit data layer
│   ├── Habit Isar model + generation
│   ├── HabitRepository implementation
│   └── Unit tests for repository
│
├── Day 3-4: Create habit feature
│   ├── Create habit screen UI
│   ├── Category selection
│   ├── Frequency picker
│   └── Save to Isar
│
└── Day 5-7: Habits home screen
    ├── Display habits by category
    ├── Habit card with today's status
    ├── Edit/archive habit
    └── Habit detail screen

WEEK 4: Camera & Recording
├── Day 1-2: Camera setup
│   ├── Camera permission flow
│   ├── Camera preview screen
│   ├── Front/back camera toggle
│   └── Basic recording functionality
│
├── Day 3-4: Recording UI
│   ├── "Day X" overlay on camera
│   ├── Clip type indicator (intention/evidence/reflection)
│   ├── Recording timer
│   └── Stop/restart recording
│
└── Day 5-7: Clip management
    ├── VideoClip Isar model
    ├── Save clips to local storage
    ├── Clip preview screen
    ├── Re-record option
    └── Import from camera roll

WEEK 5: Daily Log System
├── Day 1-2: DailyLog data layer
│   ├── DailyLog Isar model
│   ├── Relationship with Habit and VideoClip
│   └── Repository methods
│
├── Day 3-4: Recording flow integration
│   ├── Track clip progress per day
│   ├── Update habit card status
│   ├── Handle multiple clips
│   └── Mark day as complete
│
└── Day 5-7: Polish & edge cases
    ├── Handle app backgrounding during recording
    ├── Storage space checks
    ├── Error handling
    └── Cross-day recordings (started before midnight)
```

### Phase 2: Video Compilation (Week 6-7) — CRITICAL PATH

```
WEEK 6: FFmpeg Integration
├── Day 1-2: FFmpeg setup
│   ├── Add ffmpeg_kit_flutter dependency
│   ├── Test basic video operations
│   ├── Create VideoProcessingService
│   └── Handle iOS/Android differences
│
├── Day 3-4: Clip normalization
│   ├── Resize clips to 1080x1920
│   ├── Normalize audio levels
│   ├── Convert to consistent codec
│   └── Generate thumbnails
│
└── Day 5-7: Title card generation
    ├── Create title card image programmatically
    ├── "Day X" with habit name
    ├── Convert image to video segment
    └── Test title card + clip concatenation

WEEK 7: Compilation Pipeline
├── Day 1-2: Full compilation
│   ├── Concatenate: title + clips + end card
│   ├── Add fade transitions between clips
│   ├── Handle variable clip counts
│   └── Compression to target size
│
├── Day 3-4: Background processing
│   ├── Show compilation progress UI
│   ├── Process in isolate (no UI blocking)
│   ├── Handle compilation errors
│   └── Retry logic
│
└── Day 5-7: Output & storage
    ├── Save compiled vlog to DailyLog
    ├── Generate vlog thumbnail
    ├── Update completion status
    └── Clean up temporary files
```

### Phase 3: Journey Gallery & Sharing (Week 8-9)

```
WEEK 8: Journey Gallery
├── Day 1-2: Gallery screen
│   ├── Grid view of vlog thumbnails
│   ├── Filter by habit
│   ├── Sort options (newest/oldest)
│   └── Pagination for large libraries
│
├── Day 3-4: Calendar view
│   ├── Monthly calendar component
│   ├── Mark completed days
│   ├── Tap day to see vlog
│   └── Navigate between months
│
└── Day 5-7: Vlog player
    ├── Full-screen video player
    ├── Playback controls
    ├── Swipe to next/previous vlog
    └── Day info overlay

WEEK 9: Sharing & Export
├── Day 1-2: Share functionality
│   ├── Share to Instagram Stories
│   ├── Share to TikTok
│   ├── Share via Messages/WhatsApp
│   └── Copy link (for future web support)
│
├── Day 3-4: Export options
│   ├── Download to camera roll
│   ├── Batch export selection
│   ├── Export quality settings
│   └── Share analytics tracking
│
└── Day 5-7: Storage management
    ├── Storage usage display
    ├── Delete individual vlogs
    ├── Bulk delete old vlogs
    └── Auto-cleanup settings
```

### Phase 4: Gamification (Week 10-11)

```
WEEK 10: XP & Levels
├── Day 1-2: UserProgress system
│   ├── UserProgress Isar model
│   ├── XP calculation logic
│   ├── Level formula implementation
│   └── Progress repository
│
├── Day 3-4: XP integration
│   ├── Award XP on clip recording
│   ├── Award XP on vlog completion
│   ├── Apply streak multipliers
│   ├── Daily bonus calculations
│   └── XP breakdown screen
│
└── Day 5-7: Level-up experience
    ├── Level progress bar (home screen)
    ├── Level-up detection
    ├── Celebration animation
    └── Level title unlocks

WEEK 11: Streaks & Achievements
├── Day 1-2: Streak system
│   ├── Calculate current streak per habit
│   ├── Best streak tracking
│   ├── Streak break detection
│   └── Streak freeze logic (1 per 7 days)
│
├── Day 3-4: Achievement system
│   ├── Achievement Isar model
│   ├── Achievement definitions (30 for MVP)
│   ├── Unlock detection logic
│   ├── Achievement notification
│   └── Achievements screen
│
└── Day 5-7: Visual rewards
    ├── Streak flame animations
    ├── Achievement badge designs
    ├── Profile stats screen
    └── Polish celebrations
```

### Phase 5: Polish & Launch Prep (Week 12-14)

```
WEEK 12: Notifications & Reminders
├── Day 1-3: Local notifications
│   ├── Habit reminder notifications
│   ├── Streak danger alerts
│   ├── Weekly summary notification
│   └── Customizable notification times
│
└── Day 4-7: Edge cases & stability
    ├── Handle no internet gracefully
    ├── Handle low storage
    ├── Handle permission denials
    └── Crash reporting setup (Sentry)

WEEK 13: Testing & Bug Fixes
├── Day 1-3: Device testing
│   ├── Test on 5+ iOS devices
│   ├── Test on 5+ Android devices
│   ├── Test on tablets
│   └── Performance profiling
│
└── Day 4-7: Bug bash
    ├── Fix critical bugs
    ├── Polish UI inconsistencies
    ├── Optimize video processing speed
    └── Memory leak fixes

WEEK 14: Launch Preparation
├── Day 1-3: Store preparation
│   ├── App Store screenshots (6.5" and 5.5")
│   ├── Play Store screenshots
│   ├── App description copy
│   ├── Privacy policy
│   └── App icons (all sizes)
│
└── Day 4-7: Submission
    ├── TestFlight beta upload
    ├── Google Play internal testing
    ├── Beta tester recruitment (20-50 people)
    └── Collect beta feedback
```

### Post-MVP Timeline

```
MONTH 4: Beta Testing & Iteration
├── Week 1-2: Beta feedback collection
├── Week 3: Critical bug fixes
└── Week 4: Public launch on App Store + Play Store

MONTH 5-6: Growth & Social Features
├── User feedback incorporation
├── Public profiles
├── Friend system
├── Activity feed
└── Cheer reactions

MONTH 7: Scale & Optimize
├── Performance improvements
├── Cloud sync option
├── Weekly/monthly recap vlogs
└── Evaluate monetization options
```

---

## 9. Risk Register

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Video processing too slow** | High | High | Pre-process clips immediately after recording; use background isolates; show progress with ETA; optimize FFmpeg commands |
| **Storage fills up quickly** | High | Medium | Aggressive compression; prompt users to delete old vlogs; implement storage warnings; offer cloud storage in v2 |
| **Camera permission denied** | Medium | Critical | Clear permission rationale; fallback to camera roll import; handle gracefully with helpful UI |
| **App rejected from stores** | Medium | High | Follow all guidelines; thorough testing; clear privacy policy; no copyrighted music in default options |
| **FFmpeg compatibility issues** | Medium | High | Extensive device testing; fallback to simpler processing; use well-supported codecs only |
| **Users don't return after Day 1** | High | Critical | Strong onboarding; first-day achievements; streak starting immediately; push notifications |
| **Video quality complaints** | Medium | Medium | Offer quality settings; document phone compatibility; optimize processing pipeline |
| **App crashes during recording** | Low | Critical | Auto-save chunks every 10 seconds; implement recovery flow; extensive crash testing |
| **Scope creep** | High | Medium | Strict MVP definition; "later" list for features; weekly scope reviews |
| **Solo developer burnout** | Medium | High | Realistic timeline; regular breaks; celebrate milestones; build in public for motivation |
| **Cloud costs explode** | Low (MVP) | High | Keep MVP local-only; if cloud needed, implement usage limits; require payment for heavy use |

### Contingency Plans

**If video compilation is too complex:**
- Phase 1: Launch without auto-compilation (manual export clips)
- Phase 2: Add simple concatenation without transitions
- Phase 3: Full compilation features

**If timeline slips:**
- Cut achievements system (keep streaks + XP only)
- Cut calendar view (keep grid view only)
- Cut background music option
- Cut import from camera roll

**If storage is a bigger problem than expected:**
- Reduce default video quality
- Implement aggressive clip expiration (30 days)
- Add "storage saver" mode (shorter max clip length)

---

## 10. Launch & Growth Strategy

### Pre-Launch (2 weeks before)

```
BUILD HYPE
├── Create TikTok/Instagram accounts for Day1
├── Post "building in public" content
├── Share development journey clips (dogfooding your own app!)
├── Reach out to micro-influencers in self-improvement space
├── Post on Reddit: r/getdisciplined, r/selfimprovement, r/habits
└── Product Hunt "coming soon" page

BETA RECRUITMENT
├── Goal: 50-100 beta testers
├── Share in high school/college groups
├── Discord servers (self-improvement, productivity)
├── Twitter/X indie hacker community
└── Friends and family (honest feedback)
```

### Launch Day Strategy

```
PRODUCT HUNT LAUNCH
├── Prepare assets 1 week early
├── Launch on Tuesday (best engagement)
├── Engage with all comments
├── Share in relevant communities
└── Goal: Top 10 of the day

APP STORE OPTIMIZATION
├── Keywords: habit tracker, vlog, accountability, streak, daily habits
├── Title: "Day1 - Habit Vlog Tracker"
├── Subtitle: "Document your transformation journey"
├── Screenshots showing main character energy
└── Short video preview

DAY 1 PUSH
├── Post on all social platforms
├── Email beta testers asking for reviews
├── Share personal journey using the app
├── Reach out to habit/productivity YouTubers
└── Reddit posts with genuine value (not spammy)
```

### Growth Loops

```
ORGANIC LOOPS
├── Vlog sharing → Friends see → Download app
├── "Day X of Y" content → TikTok algorithm → Viral potential  
├── Transformation results → Inspiration → New users
└── Achievement sharing → Social proof → FOMO downloads

RETENTION LOOPS
├── Daily notifications → Open app → Record → Streak continues
├── Streak at risk → Fear of loss → Come back
├── Level milestones → "Just one more day" → Engagement
└── Journey gallery → Pride in progress → Continue habit

REFERRAL LOOP (v2)
├── Invite friend → Both get XP boost
├── Complete challenge together → Bonus rewards
└── Friend activity feed → Social accountability
```

### Target Acquisition Channels

| Channel | Effort | Cost | Expected Users (Month 1) |
|---------|--------|------|--------------------------|
| TikTok organic | High | $0 | 2,000-10,000 |
| Instagram Reels | High | $0 | 1,000-5,000 |
| Product Hunt | Medium | $0 | 500-2,000 |
| Reddit | Medium | $0 | 500-1,500 |
| App Store Search | Low (ongoing) | $0 | 200-500 |
| Word of mouth | N/A | $0 | 300-1,000 |
| **Total** | | **$0** | **4,500-20,000** |

### Content Strategy

```
TIKTOK/REELS CONTENT PILLARS
├── "Day X of building Day1" - Your development journey
├── User transformation compilations (with permission)
├── Tips for building habits
├── Behind-the-scenes of app development
├── "Main character energy" aesthetic content
└── Trending sound integrations

POST FREQUENCY
├── TikTok: 1-2 posts/day
├── Instagram: 1 post/day + stories
├── Twitter: 3-5 tweets/day
└── Reddit: 2-3 valuable posts/week (not promotional)
```

---

## 11. Success Metrics

### North Star Metric
**Daily Active Vloggers (DAV)**: Users who complete at least one vlog per day

### Primary Metrics

| Metric | Week 1 | Month 1 | Month 3 | Month 7 |
|--------|--------|---------|---------|---------|
| Downloads | 500 | 5,000 | 20,000 | 50,000 |
| DAU | 200 | 1,500 | 5,000 | 12,000 |
| D1 Retention | 50% | 45% | 45% | 45% |
| D7 Retention | 25% | 22% | 25% | 28% |
| D30 Retention | - | 12% | 15% | 18% |
| Vlogs Created | 300 | 15,000 | 100,000 | 500,000 |
| Vlogs Shared | 30 | 1,000 | 8,000 | 40,000 |
| Avg Session Length | 3 min | 3.5 min | 4 min | 4.5 min |
| App Store Rating | - | 4.2 | 4.4 | 4.6 |

### Secondary Metrics

```
ENGAGEMENT METRICS
├── Clips recorded per day per user
├── Completion rate (started habit → completed vlog)
├── Feature adoption (which features are used)
├── Notification open rate
└── Share rate per vlog

HABIT SUCCESS METRICS
├── Average streak length
├── % users with 7+ day streak
├── % users with 30+ day streak
├── Habits created per user
└── Category distribution

TECHNICAL METRICS
├── Crash-free rate (target: 99.5%)
├── Video compilation success rate
├── Average compilation time
├── App size
└── Battery usage
```

### Analytics Implementation

```dart
// Example PostHog events to track

// Core funnel
analytics.capture('onboarding_started');
analytics.capture('onboarding_completed');
analytics.capture('habit_created', properties: {
  'category': 'physical',
  'frequency': 'daily',
  'is_first_habit': true,
});

// Recording flow
analytics.capture('recording_started', properties: {
  'habit_id': habitId,
  'clip_type': 'intention',
  'day_number': 14,
});
analytics.capture('recording_completed', properties: {
  'duration_seconds': 12,
  'retakes': 0,
});
analytics.capture('vlog_compiled', properties: {
  'total_clips': 3,
  'total_duration': 45,
  'processing_time_seconds': 8,
});

// Engagement
analytics.capture('vlog_played', properties: {
  'day_number': 14,
  'completion_rate': 0.85,
});
analytics.capture('vlog_shared', properties: {
  'platform': 'instagram_stories',
  'day_number': 14,
});

// Gamification
analytics.capture('xp_earned', properties: {
  'amount': 75,
  'source': 'vlog_completed',
  'streak_multiplier': 1.25,
});
analytics.capture('level_up', properties: {
  'new_level': 12,
  'total_xp': 4200,
});
analytics.capture('achievement_unlocked', properties: {
  'achievement_id': 'week_warrior',
  'rarity': 'common',
});
analytics.capture('streak_milestone', properties: {
  'habit_id': habitId,
  'streak_days': 7,
});
```

---

## Appendix A: Habit Templates

```
PHYSICAL (💪)
├── Cold Showers - "Start every day with a cold shower"
├── Morning Workout - "Exercise first thing in the morning"
├── 10K Steps - "Walk 10,000 steps every day"
├── Stretching - "5-minute stretch routine"
├── No Junk Food - "Avoid processed/fast food"
├── Drink Water - "8 glasses of water daily"
├── Sleep by 11 - "In bed by 11 PM"
└── Wake at 6 - "Rise at 6 AM consistently"

MENTAL (🧠)
├── Meditation - "10 minutes of mindfulness"
├── Reading - "Read for 20 minutes"
├── Journaling - "Write in journal daily"
├── No Phone AM - "No phone for first hour"
├── Gratitude - "Write 3 things you're grateful for"
├── Deep Work - "2 hours of focused work"
├── Learn Something - "Learn one new thing daily"
└── Digital Detox - "1 hour screen-free time"

CREATIVE (🎨)
├── Draw/Sketch - "Create one drawing"
├── Write - "Write 500 words"
├── Music Practice - "30 minutes instrument practice"
├── Photography - "Take one intentional photo"
├── Content Creation - "Create one piece of content"
├── Coding - "Work on coding project"
├── Crafting - "Work on craft project"
└── Design - "Create one design"

GROWTH (🌱)
├── Language Learning - "15 min language practice"
├── Networking - "Reach out to one person"
├── Skill Practice - "Practice a specific skill"
├── Course Work - "Complete course lesson"
├── Public Speaking - "Practice speaking"
├── Financial Review - "Review finances/budget"
├── Career Development - "Work on career goals"
└── Side Project - "Work on side business"
```

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Vlog** | The compiled video from a day's habit completion clips |
| **Clip** | A single video recording (intention, evidence, or reflection) |
| **Streak** | Consecutive days of completing a habit |
| **4 Wins** | The four habit categories: Physical, Mental, Creative, Growth |
| **Day Number** | The current day count for a specific habit (Day 1, Day 2, etc.) |
| **XP** | Experience points earned for actions in the app |
| **Level** | User's overall progress tier based on total XP |
| **Compilation** | The process of stitching clips into a single vlog video |
| **Journey** | The complete history of a habit's vlogs |
| **Main Character Energy** | The feeling of being the protagonist of your own story |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2026 | Initial MVP plan created |

---

*"Every day is Day 1 of something."*

**Ready to build? Let's make it happen.** 🚀
