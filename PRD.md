# Product Requirements Document — Day1

**Version:** 1.0
**Last Updated:** April 2026
**Platform:** iOS (Flutter)

---

## 1. Overview

### 1.1 Product Summary

Day1 is a habit accountability app that uses short-form video as its core mechanism. Users record 3 brief video clips each day — an Intention, Evidence, and Reflection — which the app automatically compiles into a "Day X" vlog. The app pairs this video-driven loop with gamification mechanics (XP, levels, streaks, achievements) to sustain long-term engagement.

### 1.2 Problem Statement

Most habit tracking apps rely on checkbox accountability, which is easy to fake and provides little intrinsic motivation. Users can check a box without doing the habit. Day1 solves this by requiring video evidence — you cannot lie on camera. Additionally, the resulting archive of vlogs creates a visual record of personal growth over time, which serves as both proof and motivation.

### 1.3 Target User

Young adults (16-30) who:
- Are building or maintaining habits (fitness, mindfulness, creativity, learning)
- Are familiar with social video formats like TikTok and YouTube Shorts
- Respond to gamification and progress tracking (Duolingo, fitness apps)
- Want a record of their self-improvement journey

### 1.4 Core Value Propositions

1. **Accountability through evidence** — video clips require actually doing the habit
2. **Visual transformation** — an archive of progress vlogs is uniquely motivating
3. **Shareable content** — "Day X of Y" format is native to social media culture
4. **Gamified consistency** — XP, streaks, and achievements make showing up feel rewarding

---

## 2. Core User Flow

```
Open App
    ↓
Select Habit → Tap Record
    ↓
Record Intention clip  (5–15s)  "Day 14 of cold showers"
    ↓
Record Evidence clip   (5–30s)  Actually doing the habit
    ↓
Record Reflection clip (10–30s) How it went
    ↓
Auto-Compile → Vlog created
    ↓
Reward: +XP, streak update, achievement checks
    ↓
Vlog saved to Journey Gallery
    ↓
Optional: Share to social / save to camera roll
```

---

## 3. Features

### 3.1 Habit Management

**Purpose:** Allow users to define and track up to 6 concurrent habits.

| Requirement | Description |
|-------------|-------------|
| Create habit | Name, category, and frequency are required |
| Categories | Physical, Mental, Creative, Growth (the "4 Wins" framework) |
| Frequency options | Daily, weekdays, weekends, 3x per week |
| Templates | 26 preset habit options across all 4 categories |
| Habit limit | Maximum 6 active habits (prevents overcommitment) |
| Habit card | Shows category color, day number, current streak |
| Habit detail | Displays stats: day number, current streak, best streak, total completions |
| Archive | Soft-delete that preserves history |
| Delete | Hard delete with confirmation dialog |

**Habit Categories:**

| Category | Color | Examples |
|----------|-------|---------|
| Physical | #3B82F6 (blue) | Cold showers, gym, running |
| Mental | #8B5CF6 (purple) | Meditation, journaling, reading |
| Creative | #F97316 (orange) | Drawing, music, writing |
| Growth | #22C55E (green) | Language learning, new skills |

---

### 3.2 Video Recording

**Purpose:** Guide users through the 3-clip I-E-R recording structure.

| Requirement | Description |
|-------------|-------------|
| Camera access | Request permission on first use; show friendly denied state if rejected |
| Full-screen preview | Camera preview fills the screen with overlaid controls |
| Day overlay | "Day X" label displayed on camera during recording |
| I-E-R indicator | 3-segment progress bar showing clip completion (Intention → Evidence → Reflection) |
| Clip type selector | User can select which clip type they are recording |
| Record button | Animated button; tap to start, tap to stop |
| Recording timer | Elapsed time shown during active recording |
| Camera flip | Toggle between front and rear camera |
| Clip preview | Watch clip before saving; option to re-record |
| Auto-advance | After saving a clip, the next clip type is automatically selected |
| Completion trigger | After all 3 clips saved, compilation begins automatically |

**Clip Type Definitions:**

| Type | Purpose | Suggested Length |
|------|---------|-----------------|
| Intention (I) | Announce what you're about to do | 5–15 seconds |
| Evidence (E) | Show yourself doing the habit | 5–30 seconds |
| Reflection (R) | Share how it went | 10–30 seconds |

---

### 3.3 Video Compilation

**Purpose:** Combine 3 clips into a single "Day X" vlog file.

| Requirement | Description |
|-------------|-------------|
| Auto-trigger | Compilation begins immediately after all 3 clips are saved |
| Validation | All 3 clips must be present before compilation starts |
| Progress UI | Animated progress dialog shown during compilation |
| Vlog record | Creates a Vlog object with duration, file size, and clip references |
| Daily log update | Marks the day's DailyLog status as `vlogCompiled` |
| Photo library | Saves individual clips to iOS photo library |
| MVP note | Full FFmpeg concatenation (with title cards and transitions) is planned; current MVP creates a vlog reference from clips |

---

### 3.4 Journey Gallery

**Purpose:** Provide a visual archive of all compiled vlogs per habit.

| Requirement | Description |
|-------------|-------------|
| Gallery grid | Thumbnail grid of all vlogs for each habit |
| Calendar view | Monthly calendar with color-coded day completion markers |
| Video playback | Full-screen player with progress controls |
| Share sheet | Bottom sheet with share-to-social and download options |
| Download | Save vlog to iOS camera roll |
| Delete | Delete from player screen or via long-press in gallery grid |
| Navigation | Accessible from Habit Detail screen ("View Journey" button) and Journey tab |

---

### 3.5 Gamification

**Purpose:** Sustain daily engagement through XP rewards, level progression, and achievement milestones.

#### XP System

| Action | Base XP |
|--------|---------|
| Complete daily vlog | 75 XP |
| Share a vlog | 10 XP |
| Unlock an achievement | Achievement-specific bonus |

**Streak Multipliers:**

| Streak Length | XP Multiplier |
|---------------|---------------|
| 1–2 days | 1.0x |
| 3–6 days | 1.1x |
| 7–13 days | 1.25x |
| 14–29 days | 1.5x |
| 30–99 days | 2.0x |
| 100+ days | 3.0x |

#### Level System

XP threshold formula: cumulative sum of `floor(100 × i^1.5)` for each level `i`.

| Level Range | Title |
|-------------|-------|
| 1–4 | Beginner |
| 5–9 | Apprentice |
| 10–14 | Rising Star |
| 15–19 | Dedicated |
| 20–29 | Warrior |
| 30–39 | Champion |
| 40–49 | Legend |
| 50+ | Main Character |

#### Achievement System

30 achievements across 6 categories:

**Streak Achievements:**

| ID | Name | Requirement | Rarity | XP |
|----|------|-------------|--------|----|
| streak_3 | First Flame | 3-day streak | Common | 50 |
| streak_7 | Week Warrior | 7-day streak | Common | 100 |
| streak_14 | Fortnight Fighter | 14-day streak | Uncommon | 200 |
| streak_30 | Monthly Master | 30-day streak | Rare | 500 |
| streak_90 | Quarter Crusher | 90-day streak | Epic | 1000 |
| streak_100 | Centurion | 100-day streak | Epic | 1500 |

**Vlog Count Achievements:**

| ID | Name | Requirement | Rarity | XP |
|----|------|-------------|--------|----|
| vlog_1 | Day 1 | 1 vlog | Common | 25 |
| vlog_10 | Getting Started | 10 vlogs | Common | 50 |
| vlog_30 | Consistent | 30 vlogs | Common | 75 |
| vlog_50 | Content Creator | 50 vlogs | Uncommon | 150 |
| vlog_100 | Prolific | 100 vlogs | Rare | 300 |

**Social Achievements:**

| ID | Name | Requirement | Rarity | XP |
|----|------|-------------|--------|----|
| social_1 | Social Butterfly | 1 vlog shared | Common | 50 |
| social_10 | Influencer | 10 vlogs shared | Uncommon | 150 |

**Category Starters (7-day streak in category):**

| ID | Name | Category | Rarity | XP |
|----|------|---------|--------|----|
| cat_physical_starter | Physical Starter | Physical | Common | 75 |
| cat_mental_starter | Mental Starter | Mental | Common | 75 |
| cat_creative_starter | Creative Starter | Creative | Common | 75 |
| cat_growth_starter | Growth Starter | Growth | Common | 75 |

**Category Champions (30-day streak in category):**

| ID | Name | Category | Rarity | XP |
|----|------|---------|--------|----|
| cat_physical_champ | Physical Champion | Physical | Uncommon | 200 |
| cat_mental_champ | Mental Champion | Mental | Uncommon | 200 |
| cat_creative_champ | Creative Champion | Creative | Uncommon | 200 |
| cat_growth_champ | Growth Champion | Growth | Uncommon | 200 |

**Special Achievements:**

| ID | Name | Requirement | Rarity | XP |
|----|------|-------------|--------|----|
| balanced | Balanced | Active habit in all 4 categories | Uncommon | 200 |
| collector | Collector | 6 habits created | Uncommon | 150 |
| level_5 | Level 5 | Reach Level 5 | Common | 100 |
| level_10 | Level 10 | Reach Level 10 | Rare | 300 |
| marathon | Marathon | 100+ minutes recorded | Rare | 300 |
| multi_flame | Multi-Flame | 7-day streak on 3+ habits | Rare | 300 |
| comeback | Comeback Kid | Record after 7+ day break | Uncommon | 150 |
| early_adopter | Early Adopter | 7 vlogs in first 10 days | Rare | 250 |
| perfect_week | Perfect Week | All habits completed every day for 7 days | Uncommon | 250 |

**Achievement Rarities:**

| Rarity | Color |
|--------|-------|
| Common | #A3A3A3 (gray) |
| Uncommon | #22C55E (green) |
| Rare | #3B82F6 (blue) |
| Epic | #A855F7 (purple) |
| Legendary | #F59E0B (gold) |

#### Celebration Flow

After a vlog is compiled, the following sequence plays:

1. Enhanced completion dialog with `+X XP` reward shown in gold
2. Streak multiplier displayed if applicable
3. Level-up overlay (full-screen, animated) if a new level was reached
4. Achievement toast notifications (bottom-anchored, auto-dismiss after 3s) for each newly unlocked achievement
5. Navigation returns to the habit list

---

### 3.6 Stats Screen

**Purpose:** Show the user's overall progress and achievement collection.

| Requirement | Description |
|-------------|-------------|
| Level card | Circular level badge, level title, XP bar with current/max label |
| Stats grid | 2×2 grid: Total XP, Best Streak, Total Vlogs, Minutes Recorded |
| Achievements header | "ACHIEVEMENTS" label with `X/30` count |
| Achievement grid | 2-column grid; unlocked achievements shown first, locked greyed out |

---

### 3.7 Profile Screen

**Purpose:** Show a personal summary of the user's journey.

| Requirement | Description |
|-------------|-------------|
| Level badge | Large circular badge (100px) with level number and purple gradient glow |
| Username | "Day1 Athlete" placeholder (editable in Phase 6) |
| Level title | Displayed below username in accent color |
| XP progress card | XP bar with current/next level label and "X XP to Level Y" helper text |
| Stats grid | 2×2: Level, Total XP, Best Streak, Vlogs Made |
| Recent achievements | Last 3 unlocked achievements shown as compact cards with "View All →" link |

---

## 4. Technical Architecture

### 4.1 Technology Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (SDK 3.2+) |
| Language | Dart |
| State Management | Riverpod (StateNotifierProvider) |
| Navigation | go_router (declarative routing) |
| Animation | flutter_animate (declarative chaining) |
| Typography | Google Fonts — Inter |
| Video Recording | camera package |
| Video Playback | video_player package |
| Video Compilation | ffmpeg_kit_flutter (full implementation planned) |
| File System | path_provider |
| Permissions | permission_handler |
| Photo Library | image_gallery_saver |
| Sharing | share_plus |
| Storage | JSON files in app documents directory (Isar migration planned) |

### 4.2 Architecture Pattern

Each feature follows Clean Architecture:

```
feature/
├── data/
│   ├── models/         # Immutable data classes (copyWith, toJson, fromJson)
│   └── repositories/   # All I/O: read, write, delete
├── providers/          # Riverpod notifiers; orchestrate repo + state
└── presentation/
    ├── screens/        # Full-page views (ConsumerWidget)
    └── widgets/        # Composable UI components
```

### 4.3 Data Persistence

All data is stored as JSON files in the app's documents directory:
- `habits.json` — All habits
- `recordings_index.json` — All clips, daily logs, and vlogs
- `user_progress.json` — XP, level, and achievement data

### 4.4 Navigation Structure

```
/ (Home — Habit List)
├── /create-habit
├── /habit/:id  (Habit Detail)
│   └── /camera/:habitId
/journey
├── /journey/:habitId
│   └── /vlog/:vlogId
/record
/stats
/profile
```

### 4.5 State Management

Providers:
- `habitsProvider` — Full habit list + CRUD operations
- `habitByIdProvider(id)` — Single habit selector
- `recordingRepositoryProvider` — All recording state (clips, logs, vlogs)
- `todaysLogProvider(habitId)` — Today's DailyLog for a habit
- `gamificationProvider` — User XP, level, and achievement state
- `journeyProvider` — Vlog queries and filtering

---

## 5. Design System

### 5.1 Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| backgroundPrimary | #0F0F0F | App background |
| backgroundCard | #1A1A1A | Card surfaces |
| backgroundSurface | #262626 | Elevated elements |
| primary | #3B82F6 | Primary actions, Physical category |
| xpGold | #F59E0B | XP, rewards, gold accents |
| streakFire | #EF4444 | Streak indicators |
| levelPurple | #A855F7 | Level badges and celebration |
| success | #22C55E | Growth category, uncommon achievements |
| mental | #8B5CF6 | Mental category |
| creative | #F97316 | Creative category |
| textPrimary | #FFFFFF | Primary text |
| textSecondary | #A3A3A3 | Secondary labels |
| textTertiary | #737373 | Hints and captions |
| borderSubtle | #262626 | Subtle card borders |

### 5.2 Typography Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| hero | 72px | 900 | Day counter |
| h1 | 32px | 700 | Screen titles |
| h2 | 24px | 700 | Section headers |
| h3 | 20px | 600 | Card titles |
| h4 | 14px | 600 | Labels, overlines |
| body | 16px | 400 | Body copy |
| bodySmall | 14px | 400 | Secondary body |
| caption | 12px | 500 | Hints, metadata |

### 5.3 Spacing Scale (4px base unit)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing within components |
| sm | 8px | Between closely related elements |
| md | 16px | Standard padding |
| lg | 24px | Between sections |
| xl | 32px | Large section gaps |
| 2xl | 48px | Screen-level padding |

---

## 6. Development Phases

| Phase | Feature Area | Status |
|-------|-------------|--------|
| Phase 0 | Foundation: theme system, routing, shared components | Complete |
| Phase 1 | Core Habit Flow: create, view, manage habits | Complete |
| Phase 2 | Recording Flow: camera, I-E-R clips, daily logs | Complete |
| Phase 3 | Video Compilation: auto-compile, vlog model, photo library | Complete |
| Phase 4 | Journey Gallery: grid, calendar, player, sharing | Complete |
| Phase 5 | Gamification: XP, levels, achievements, celebration UX | Complete |
| Phase 6 | Polish: notifications, settings, onboarding, App Store prep | In Progress |

---

## 7. Phase 6 Requirements (Upcoming)

### 7.1 Push Notifications
- Daily reminder at a user-configured time
- "Streak danger" notification if 10+ hours remain and today's vlog is not complete
- Achievement unlock notification (local, not push)

### 7.2 Settings Screen
- Edit username / display name
- Configure notification time
- Toggle notification types on/off
- App version display

### 7.3 Storage Management
- Show total storage used by video clips and vlogs
- Bulk delete old vlogs by date range
- Warning when device storage is low

### 7.4 Onboarding
- First-launch walkthrough: what Day1 is, how the I-E-R format works, how to create a habit
- Sample vlog preview to demonstrate the output format
- Single-habit onboarding path before showing the full UI

### 7.5 App Store Preparation
- App icon (all required sizes)
- Launch screen
- Privacy policy URL
- App Store screenshots (6.5" and 5.5")
- App description and keywords
- Age rating and content review

---

## 8. Success Metrics

| Metric | Target |
|--------|--------|
| Day 7 retention | 40% |
| Day 30 retention | 15% |
| Average vlogs per active user per week | 3+ |
| Vlogs shared to social | 10% of all vlogs created |
| Downloads (first 90 days) | 50,000 |

---

## 9. Out of Scope (Current Version)

- Social feed or community discovery (follow other users, public profiles)
- Server-side storage or cloud sync
- Android support (iOS first)
- Full FFmpeg video concatenation with title cards and transitions (planned)
- In-app purchases or monetization
- Apple Watch companion app
