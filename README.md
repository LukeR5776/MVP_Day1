# Day1

**Be the main character of your own journey**

Day1 is an iOS habit accountability app built with Flutter. Users document their daily habit progress through a structured 3-clip video format — Intention, Evidence, Reflection — which automatically compiles into a "Day X" vlog. The app pairs this video-driven accountability loop with Duolingo-style gamification: XP rewards, streaks, level progression, and 30 unlockable achievements.

---

## What It Does

The core loop is simple:

1. **Set an intention** — Record a 5-15 second clip: "Day 14 of cold showers"
2. **Show the evidence** — Film yourself actually doing the habit
3. **Reflect** — A quick wrap-up clip on how it went
4. **Auto-compile** — The app creates a "Day X" vlog from your 3 clips
5. **Earn rewards** — XP, streak bonuses, and achievement unlocks

Over time, users build a visual journey gallery — a scrollable archive of every day they showed up.

---

## Key Features

### Habit Management
- Create up to 6 habits across 4 categories: Physical, Mental, Creative, and Growth
- Choose from 26 preset habit templates or write your own
- Set frequency: daily, weekdays, weekends, or 3x per week
- Track day number, current streak, best streak, and total completions

### Video Recording
- Full-screen camera with "Day X" overlay
- 3-clip structure with a visual I-E-R progress indicator
- Clip preview and re-record options before saving
- Auto-compilation into a daily vlog after all 3 clips are recorded
- Save clips and vlogs to the iOS photo library

### Journey Gallery
- Grid view of all compiled vlogs per habit
- Calendar view showing which days were completed
- Full-screen video playback
- Share vlogs to social platforms or download to camera roll
- Delete individual vlogs

### Gamification
- **XP System**: Earn 75 base XP per vlog, with streak multipliers up to 3x
- **Level System**: 50+ levels from "Beginner" to "Main Character"
- **Achievements**: 30 achievements across streaks, vlog counts, categories, and special milestones
- **Streak tracking**: Day-over-day streak calculation with multiplier bonuses
- **Celebration animations**: Level-up overlay, XP reward popup, achievement toast notifications

### Stats & Profile
- Level badge with XP progress bar
- Stats grid: Total XP, best streak, total vlogs, recording minutes
- Full achievements grid with locked/unlocked states and rarity indicators
- Recent achievements shown on the profile screen

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Flutter (SDK 3.2+) | Cross-platform UI framework |
| Dart | Primary programming language |
| Riverpod | Reactive state management |
| go_router | Declarative navigation |
| flutter_animate | Declarative animation system |
| Google Fonts (Inter) | Typography |
| camera | Video recording |
| video_player | Vlog playback |
| path_provider | File system access |
| permission_handler | Camera and photo library permissions |
| image_gallery_saver | Save to iOS photo library |
| share_plus | Social sharing |
| ffmpeg_kit_flutter | Video compilation (full implementation planned) |

---

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── app.dart                    # Root widget (Riverpod + go_router)
├── core/
│   ├── theme/                  # Colors, typography, spacing tokens
│   ├── router/                 # Navigation routes and guards
│   └── constants/              # App-wide constants
├── shared/
│   └── widgets/                # Reusable UI components
│       ├── buttons/            # PrimaryButton, AppIconButton
│       ├── cards/              # BaseCard
│       ├── indicators/         # XPBar, StreakCounter
│       └── layout/             # ScreenScaffold, AppBottomNav
└── features/
    ├── habits/                 # Phase 1 — Habit management
    ├── recording/              # Phase 2 & 3 — Camera + compilation
    ├── journey/                # Phase 4 — Gallery and playback
    ├── gamification/           # Phase 5 — XP, levels, achievements
    └── settings/               # Phase 6 — Profile and settings
```

Each feature follows a clean architecture pattern:
```
feature/
├── data/
│   ├── models/         # Data classes
│   └── repositories/   # Persistence and CRUD logic
├── providers/          # Riverpod state management
└── presentation/
    ├── screens/        # Full-screen views
    └── widgets/        # Feature-specific components
```

---

## Design System

All UI follows a strict dark-theme design system defined in `DESIGN_SYSTEM.md`.

**Core Colors**
- Background: `#0F0F0F`
- Card surface: `#1A1A1A`
- Primary action: `#3B82F6` (blue)
- XP gold: `#F59E0B`
- Streak fire: `#EF4444`

**Category Colors**
- Physical: `#3B82F6`
- Mental: `#8B5CF6`
- Creative: `#F97316`
- Growth: `#22C55E`

**Typography**: Inter via Google Fonts, ranging from 72px hero text to 12px captions.

**Spacing**: 4px base unit — `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `2xl: 48`.

---

## Getting Started

### Prerequisites
- Flutter SDK 3.2.0 or higher
- Xcode (for iOS development)
- A physical iOS device or simulator

### Installation

```bash
git clone https://github.com/LukeR5776/MVP_Day1.git
cd MVP_Day1
flutter pub get
flutter run
```

---

## Development Progress

| Phase | Feature | Status |
|-------|---------|--------|
| 0 | Foundation (theme, routing, shared components) | Complete |
| 1 | Core Habit Flow | Complete |
| 2 | Video Recording | Complete |
| 3 | Video Compilation (MVP) | Complete |
| 4 | Journey Gallery | Complete |
| 5 | Gamification | Complete |
| 6 | Polish (notifications, settings, onboarding, App Store prep) | In Progress |

---

## License

Copyright 2026 Day1. All rights reserved.
