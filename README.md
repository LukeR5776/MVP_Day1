# Day1

**Be the main character of your own journey**

Day1 is an iOS habit accountability app built with Flutter. Users document their daily habit progress through a structured 3-clip video format — Intention, Evidence, Reflection — which automatically compiles into a "Day X" vlog. The app pairs this video-driven accountability loop with a full gamification system: XP rewards, streaks, level progression, and 30 unlockable achievements. User accounts and data are backed by Supabase with per-user isolation.

---

## The Core Idea

Most habit apps let you tap a checkbox without actually doing the habit. Day1 requires video evidence — you cannot lie on camera. Each day you record three short clips per habit, the app compiles them into a vlog, and over time you accumulate a visual gallery of every day you showed up.

The I-E-R format keeps the videos focused:

| Clip | Purpose | Length |
|------|---------|--------|
| Intention | Announce what you are about to do ("Day 14 of cold showers") | 5-15 seconds |
| Evidence | Film yourself doing the habit | 5-30 seconds |
| Reflection | A quick wrap-up on how it went | 10-30 seconds |

After all three clips are saved, compilation runs automatically. The resulting vlog is added to your Journey Gallery and XP rewards are applied.

---

## Features

### Habit Management

- Create up to 6 concurrent habits (enforced to prevent overcommitment)
- 4 habit categories: Physical, Mental, Creative, and Growth
- 26 built-in habit templates across all 4 categories for quick setup
- Custom habit creation with name, category, and frequency
- Frequency options: daily, weekdays, weekends, or 3x per week
- Per-habit stats: day number, current streak, best streak, total completions
- Archive habits to preserve history without cluttering the active list
- Hard delete with confirmation

### Video Recording

- Full-screen camera preview with "Day X" overlay
- I-E-R 3-segment progress indicator showing clip completion state
- Record, preview, and re-record each clip before saving
- Auto-advance to the next clip type after saving
- Front and rear camera toggle
- Auto-compilation triggers after all 3 clips are confirmed
- Clips saved to the iOS photo library
- Camera screen auto-resumes to the correct step on backgrounding

### Video Compilation

- FFmpeg-powered concatenation of the 3 clips into a single vlog file
- Animated progress dialog during compilation
- Vlog record created with day number, habit name, duration, file size, and date
- Daily log status updated to reflect compilation complete
- XP reward, streak update, and achievement check all fire on compile completion

### Journey Gallery

- Per-habit gallery with three view modes: grid (4-column), calendar (monthly), and timeline (chronological)
- Color-coded monthly calendar with tap-to-play on any day
- Full-screen vlog player with playback controls
- Share sheet with share-to-social and save-to-camera-roll options
- Long-press to delete a vlog from the grid or timeline
- Delete confirmation bottom sheet before any destructive action

### Gamification

**XP System**

| Action | Base XP |
|--------|---------|
| Complete daily vlog | 75 XP |
| Share a vlog | 10 XP |
| Unlock an achievement | Achievement-specific bonus |

**Streak Multipliers**

| Streak Length | Multiplier |
|---------------|------------|
| 1-2 days | 1.0x |
| 3-6 days | 1.1x |
| 7-13 days | 1.25x |
| 14-29 days | 1.5x |
| 30-99 days | 2.0x |
| 100+ days | 3.0x |

**Level System**: 50+ levels with custom titles from Beginner through Main Character. XP thresholds use a curve formula so early levels come quickly and later levels require sustained effort.

**30 Achievements** across 6 categories:
- Streak milestones (First Flame at 3 days through Centurion at 100 days)
- Vlog count milestones (Day 1 through Prolific at 100 vlogs)
- Social sharing milestones
- Category starters (7-day streak in a single category)
- Category champions (30-day streak in a single category)
- Special achievements: Balanced, Collector, Marathon, Multi-Flame, Perfect Week, Comeback Kid, Early Adopter

**Achievement Rarities**: Common (gray), Uncommon (green), Rare (blue), Epic (purple), Legendary (gold).

**Celebration Flow**: After compilation, an XP reward popup shows the earned XP and multiplier. If a new level was reached, a full-screen level-up overlay plays. Achievement toast notifications animate in for each newly unlocked achievement.

### Authentication

- Email and password sign-up with Supabase Auth
- Persistent sessions across app restarts
- 7-step animated onboarding flow for new users: welcome, goal selection, category preference, frequency, time-of-day, format preview, and account creation
- Existing users skip onboarding and go straight to the habit list
- Auth state drives navigation via a GoRouterRefreshStream guard
- Sign-out clears all local state and returns to the login screen

### Stats Screen

- Level badge with XP bar showing progress to the next level
- Summary chips: total vlogs, total streak days, total XP, total recording time
- Full achievement grid: unlocked achievements in full rarity color, locked achievements in a muted state
- Achievement count displayed as X/30

### Profile Screen

- Level badge with purple gradient glow
- Display name pulled from Supabase profiles table
- Level title (e.g., "Rising Star")
- XP progress card with current and next level
- Stats grid: Level, Total XP, Best Streak, Vlogs Made
- Recent achievements (last 3 unlocked) with a link to view all

---

## Tech Stack

| Package | Version | Purpose |
|---------|---------|---------|
| Flutter SDK | 3.2+ | Cross-platform UI framework |
| Dart | — | Primary language |
| flutter_riverpod | latest | Reactive state management |
| go_router | latest | Declarative navigation with auth guards |
| flutter_animate | latest | Declarative animation chaining |
| supabase_flutter | latest | Auth and PostgreSQL database |
| google_fonts | latest | Inter typeface |
| camera | latest | Video recording |
| video_player | latest | Vlog playback |
| ffmpeg_kit_flutter_new | latest | Video compilation |
| path_provider | latest | File system access |
| permission_handler | latest | iOS permission requests |
| image_gallery_saver | latest | Save to iOS photo library |
| share_plus | latest | Social sharing |
| lucide_icons_flutter | 3.1.14 | Consistent vector icon system |

---

## Architecture

Each feature follows a strict Clean Architecture layering:

```
feature/
├── data/
│   ├── models/         # Immutable data classes (toJson, fromJson, copyWith)
│   └── repositories/   # All I/O: files, Supabase, photo library
├── providers/          # Riverpod notifiers; orchestrate repo + state
└── presentation/
    ├── screens/        # Full-screen views (ConsumerWidget)
    └── widgets/        # Composable UI components
```

This means every layer can change independently. When Supabase was added in Session 4, only the repository layer changed. All providers, models, and UI were untouched.

**Data persistence**: habits and progress are stored in PostgreSQL via Supabase. Video clips and vlog files are stored locally on-device. File paths are keyed to the Supabase userId to ensure complete per-user isolation.

**Navigation**: go_router with a GoRouterRefreshStream wired to the Supabase auth state stream. When auth state changes (sign-in, sign-out, session restore), the router immediately re-evaluates redirect guards.

---

## Project Structure

```
lib/
├── main.dart                      # App entry: Supabase init, ProviderScope
├── app.dart                       # Root widget (ProviderScope + MaterialApp.router)
├── core/
│   ├── theme/                     # AppColors, AppTypography, AppSpacing, AppTheme
│   ├── router/                    # go_router config, GoRouterRefreshStream
│   ├── config/                    # Supabase config (URL + anon key)
│   └── constants/                 # Gamification constants (XP curve, multipliers)
├── shared/
│   └── widgets/
│       ├── buttons/               # PrimaryButton, AppIconButton
│       ├── cards/                 # BaseCard
│       ├── indicators/            # XPBar, StreakCounter
│       └── layout/                # ScreenScaffold, AppBottomNav
└── features/
    ├── auth/                      # Login, Signup, AuthService, authProvider
    ├── onboarding/                # 7-step onboarding flow, OnboardingData model
    ├── habits/                    # Phase 1 — Habit management
    ├── recording/                 # Phase 2 & 3 — Camera, clips, compilation
    ├── journey/                   # Phase 4 — Gallery, player, sharing
    ├── gamification/              # Phase 5 — XP, levels, achievements
    └── settings/                  # Profile screen
```

---

## Design System

All UI follows a strict token-based dark theme defined in `DESIGN_SYSTEM.md`.

**Colors**

| Token | Hex | Usage |
|-------|-----|-------|
| backgroundPrimary | #0F0F0F | App background |
| backgroundCard | #1A1A1A | Card surfaces |
| backgroundSurface | #262626 | Elevated elements |
| primary | #3B82F6 | Primary actions, Physical category |
| xpGold | #F59E0B | XP rewards and level indicators |
| streakFire | #EF4444 | Streak counter and warnings |
| levelPurple | #A855F7 | Level badges and celebration |
| success | #22C55E | Growth category, uncommon achievements |
| mental | #8B5CF6 | Mental category |
| creative | #F97316 | Creative category |
| textPrimary | #FFFFFF | Primary text |
| textSecondary | #A3A3A3 | Labels and secondary copy |
| textTertiary | #737373 | Captions and hints |

**Typography**: Inter via Google Fonts. Scale from 72px hero (day counter) down to 12px captions.

**Spacing**: 4px base unit. Tokens: xs (4px), sm (8px), md (16px), lg (24px), xl (32px), 2xl (48px).

**Icons**: Lucide icon library via `lucide_icons_flutter`. All UI-visible icons are Lucide vector icons for consistency across iOS versions and device sizes.

---

## Data Models

| Model | Key Fields |
|-------|-----------|
| Habit | id, name, category, frequency, currentStreak, bestStreak, lastCompletedAt, dailyLogs |
| VideoClip | id, habitId, clipType (I/E/R), filePath, duration, date |
| DailyLog | habitId, date, status (notStarted/inProgress/clipsComplete/vlogCompiled), clipIds |
| Vlog | id, habitId, habitName, dayNumber, filePath, duration, date |
| UserProgress | userId, totalXP, level, xpProgressInCurrentLevel, unlockedAchievementIds, totalVlogsCreated |
| Achievement | id, name, description, rarity, icon (IconData), xpReward |

---

## Navigation Routes

```
/login               — Login screen (unauthenticated landing)
/signup              — Sign-up screen
/onboarding          — 7-step onboarding (new users only)
/ (home)             — Habit list
  /create-habit      — Create new habit sheet
  /habit/:id         — Habit detail
    /camera/:habitId — Recording flow
/journey             — Journey path screen (all habits)
  /journey/:habitId  — Per-habit gallery
    /vlog/:vlogId    — Full-screen vlog player
/stats               — Stats and achievements
/profile             — Profile screen
```

---

## Development Progress

| Phase | Feature | Status |
|-------|---------|--------|
| 0 | Foundation: theme, routing, shared components | Complete |
| 1 | Habit management | Complete |
| 2 | Video recording | Complete |
| 3 | Video compilation | Complete |
| 4 | Journey gallery | Complete |
| 5 | Gamification | Complete |
| 5.5 | Supabase auth and per-user sync | Complete |
| 5.6 | Lucide icon system (emoji replacement) | Complete |
| 6 | Push notifications, settings, App Store prep | In Progress |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Xcode 15+ for iOS builds
- A physical iOS device or simulator (iOS 16+)
- A Supabase project with the tables described in `BACKEND_SETUP.md`

### Installation

```bash
git clone https://github.com/LukeR5776/MVP_Day1.git
cd MVP_Day1
flutter pub get
flutter run
```

Set your Supabase project URL and anon key in `lib/core/config/supabase_config.dart` before running.

---

## Documentation

| File | Contents |
|------|---------|
| `PRD.md` | Full Product Requirements Document — features, specs, success metrics |
| `DESIGN_SYSTEM.md` | Complete design token reference |
| `BACKEND_SETUP.md` | Supabase table schemas, RLS policies, setup instructions |
| `PROJECT_DOCUMENTATION.md` | Human-readable project history: every session, every bug, every decision |
| `day1_development_plan.md` | Original 1,723-line technical development plan written before coding began |

---

## License

Copyright 2026 Day1. All rights reserved.
