# Day1 App: Project Documentation

**Author:** Luke Ryan
**Platform:** iOS (Flutter)
**Development Period:** February 2026 to May 2026

---

## What This Project Is

Day1 is a habit accountability app built for iOS. The central idea is that video evidence makes habit tracking honest. Most habit apps let you tap a checkbox without actually doing the habit. Day1 requires you to record yourself.

Each day, for each habit you are tracking, you record three short video clips: an Intention clip where you announce what you are about to do, an Evidence clip where you show yourself doing it, and a Reflection clip where you talk about how it went. The app automatically combines those three clips into a single "Day X" vlog, saved to a gallery. Over weeks and months, you accumulate a visual record of who you are becoming.

The app pairs this video loop with a gamification system. Completing a vlog earns XP. XP accumulates toward levels. Streaks multiply your XP. Hitting milestones unlocks achievements with animated celebration screens. The goal is to make showing up every day feel rewarding, not just obligatory.

---

## The Problem This Solves

Accountability apps fail for two reasons. First, it is trivially easy to lie to a checkbox. Second, nothing in a checkbox app reminds you why you started. Day1 solves both. You cannot fake a video of yourself doing something. And your archive of past vlogs gives you a tangible, emotional record of the work you have put in, which is motivating in a way that a streak number never is.

The format also connects to how young people already consume content. The "Day X of Y habit" format is native to TikTok and YouTube Shorts. The vlogs the app produces are designed to be share-ready for social media, which creates an additional social accountability layer.

---

## Planning Before Building

Before writing any application code, I wrote three planning documents:

**day1_development_plan.md** is 1,723 lines. It maps out the full technical architecture of the app, defines every data model, describes every screen, specifies every interaction, and breaks the project into six development phases with acceptance criteria for each. Writing this document forced me to think through data relationships, edge cases, and feature scope before I was committed to any implementation.

**DESIGN_SYSTEM.md** is 500 lines. It defines every color token, every typography style, every spacing value, and every animation guideline the app would use. Having this written before coding meant every screen used the same colors, fonts, and spacing, which is how a professional app achieves visual consistency.

**PRD.md** (Product Requirements Document) is 485 lines. I wrote this in April after the core app was built, to capture the full product vision, success metrics, feature requirements, and technical architecture in a format that could be shared or revisited. It documents the app as a product, not just as code.

---

## Technology Stack

**Flutter and Dart.** Flutter is a framework by Google for building mobile apps from a single codebase. Dart is its programming language. Flutter renders its own UI instead of relying on native platform components, which means the app looks exactly the same on every device. I chose Flutter because it handles complex UI well and because building for iOS was the primary target.

**Riverpod.** This is the state management library the app uses. In Flutter, "state management" means deciding where data lives and how the UI knows when to update. Riverpod uses a system of providers: each piece of state (the list of habits, the current user's XP, the recording progress) lives in its own provider. UI widgets watch the providers they need and automatically rebuild when that data changes.

**go_router.** This handles navigation between screens. It uses a declarative approach: instead of imperatively pushing and popping routes, you define a map of paths and the app figures out how to get there. It also handles redirect guards, so unauthenticated users are automatically sent to the login screen regardless of what route they try to reach.

**flutter_animate.** This package provides a clean way to chain animations. Instead of writing verbose animation controller code, you can write things like "fade in over 400 milliseconds, then slide up by 10 percent." It is used on nearly every screen to make the app feel polished rather than static.

**Supabase.** Supabase is a backend service that provides a PostgreSQL database, authentication, and file storage. I added it in Session 4 to replace the earlier local-only file storage. It handles user sign-up, sign-in, and session persistence, and stores habits and progress in a real database so data survives reinstalling the app.

**FFmpeg.** The video compilation feature uses FFmpeg, a widely-used open-source video processing library. In the app it is integrated via the ffmpeg_kit_flutter package and handles combining the three recorded clips into a single compiled vlog file.

**Google Fonts (Inter).** The entire app uses the Inter typeface from Google Fonts. Inter is designed for screens and reads cleanly at small sizes, which is important for the data-dense screens like Stats and Habit Detail.

**Lucide Icons.** In Session 5 I replaced every emoji used in the UI with icons from the Lucide icon library (lucide_icons_flutter package). Lucide provides a consistent set of clean, minimal line icons that match the app's dark, modern aesthetic. The app had been using emoji as icon stand-ins, which looked unprofessional and inconsistent across different iOS versions.

---

## Architecture

The app follows a pattern called Clean Architecture, applied to each feature individually. Every feature folder contains four layers:

The **data/models** layer holds immutable data classes. Every model knows how to serialize itself to JSON and deserialize itself from JSON. All fields are final, and models provide a copyWith method for creating modified copies without mutation.

The **data/repositories** layer handles all input and output: reading files, writing files, querying Supabase, and saving to the device photo library. Nothing outside this layer knows where data comes from.

The **providers** layer sits between the data layer and the UI. Providers hold application state and expose actions. The UI reads from providers and calls actions on them, but never touches repositories directly.

The **presentation** layer contains screens (full-page views) and widgets (reusable UI components). Screens are composed of widgets. Neither screens nor widgets know anything about where data comes from.

This structure means that when I later replaced local file storage with Supabase, I only had to change the repository layer. All the UI, all the providers, and all the models stayed exactly the same.

---

## Development Sessions

### Session 1: February 26, 2026

This was the largest single session, producing 101 files and 14,903 lines of code in a single commit.

I built the entire Flutter project from scratch and completed Phases 0 through 3.

Phase 0 was the foundation. I built the theme system (all color tokens, typography scale, spacing constants), the app router, the bottom navigation bar, and a library of shared widgets used across the whole app: PrimaryButton, BaseCard, XPBar, StreakCounter, and ScreenScaffold.

Phase 1 was habit management. I built the Habit data model with fields for name, category, frequency, creation date, current streak, best streak, and completion history. I defined the HabitCategory enum (Physical, Mental, Creative, Growth) with associated colors and icons. I built the HabitRepository to read and write habits as JSON, the habitsProvider for state management, and three screens: the home screen showing all active habits, the create habit screen with a template picker and custom form, and the habit detail screen showing full statistics. I also built 26 pre-written habit templates across all four categories.

Phase 2 was the recording flow. This is the most technically complex part of the app. I built the camera screen (798 lines), which handles camera permission requests, live camera preview, recording controls, the I-E-R clip type indicator, a recording timer, front/rear camera switching, and a clip review screen after each recording. I designed the DailyLog data model, which tracks the status of each habit on each calendar day through four stages: not started, in progress, all clips recorded, and vlog compiled. I built the ClipProgressBar widget, which shows three segments filling in as clips are recorded.

Phase 3 was video compilation. After all three clips are saved, the CompilationService runs FFmpeg to concatenate them into a single video file. It creates a Vlog object with metadata (day number, habit name, duration, file size, date) and saves the vlog to the recordings index. It also triggers the photo library save.

### Session 2: April 15, 2026

This session added 3,147 lines across 24 files and completed Phases 4 and 5.

Phase 4 was the Journey Gallery. I built VlogThumbnail and VlogThumbnailLarge widgets that generate previews from video files. I built HabitJourneyScreen, which shows all vlogs for a single habit in three view modes: a 4-column grid, a monthly calendar with color-coded completion markers, and a chronological timeline. I built the full-screen VlogPlayerScreen with playback controls, a share sheet, and a download-to-camera-roll button. I built VlogShareCard, which generates a formatted share card with the day number and habit name overlaid on the thumbnail.

Phase 5 was gamification. I built the Achievement model and defined all 30 achievements across six categories: streak milestones, vlog count milestones, social sharing, category starters (7-day streak in a category), category champions (30-day streak), and special achievements like Perfect Week and Comeback Kid. Each achievement has a rarity (Common, Uncommon, Rare, Epic, Legendary) that determines its display color. I built the UserProgress model tracking total XP, current level, and all unlocked achievement IDs. I built GamificationProvider, which evaluates whether any achievements were just unlocked after each vlog completion, awards XP with streak multipliers, and checks for level-ups. I built four celebration UI components: AchievementCard (used in the stats grid), AchievementToast (a bottom-anchored notification that animates in and auto-dismisses), LevelUpOverlay (a full-screen animated celebration that plays when you reach a new level), and XPRewardPopup (shown on the compilation completion dialog). The streak XP multiplier ranges from 1.0x at 1-2 days to 3.0x at 100+ days. The level system uses a curve formula so early levels are fast to reach and later levels require sustained effort.

### Session 3: April 26 and 27, 2026

This session focused on documentation and a major UI redesign.

I wrote PRD.md and completely rewrote README.md with setup instructions, architecture explanation, and feature overview.

I redesigned the onboarding experience from scratch. The new onboarding is a 7-step animated flow: a welcome splash, a goal-setting screen, a habit category picker, a frequency selector, a time-of-day preference screen, a preview of what the vlog format looks like, and an account creation screen. Each step animates in and out. The final step connects to Supabase account creation. The entire flow is 998 lines.

I redesigned the Journey screen. Instead of a simple list, it now shows a visual vertical path with connected nodes. Each node represents a milestone or a quest. Milestone nodes show a trophy icon and a popup with details. The path connector animates as you scroll. Habit selector pills at the top let you switch between habits. Reward chips on milestone nodes show the XP and streak bonuses unlocked at each stage.

I redesigned the Stats screen with a chart-style layout for the XP progress visualization and a full achievement grid that shows unlocked achievements in full color and locked achievements in a muted state.

### Session 4: May 25, 2026

This session added 2,007 lines across 31 files and introduced Supabase as the backend.

I built the AuthService class, which wraps the Supabase authentication client and provides sign-up, sign-in, sign-out, and session restore methods. I built Login and Signup screens with proper form validation, error handling, and loading states.

I wired the authentication state into the router using GoRouterRefreshStream. This is a pattern where the Supabase session stream drives the router's redirect logic. When the auth state changes (user signs in or out), the router immediately re-evaluates which screen to show. Unauthenticated users are sent to the login screen. Authenticated users who have completed onboarding skip straight to the home screen.

I built Supabase-backed repositories for habits, vlogs, and user progress. These mirror the local JSON repositories but write to PostgreSQL tables instead of files.

I fixed a significant data isolation bug. The original file storage used fixed filenames like habits.json, which meant that if you signed out and signed in as a different user, you would see the previous user's data. I fixed this by keying all file paths to the userId: habits_{userId}.json, vlogs_index_{userId}.json, user_progress_{userId}.json, and clips/{userId}/{habitId}/.

I investigated and fixed a streak calculation bug. The streak was being evaluated before the vlog was fully written to disk, so it sometimes showed as zero after a successful compile. I moved streak recalculation to the completion callback of the save operation. I also found that the Habit model was missing a dedicated lastCompletedAt field, causing the streak counter to fall back to calculating from the habit creation date. I added the field and updated all serialization.

I updated the Profile screen to fetch and display the real display name from the Supabase profiles table.

### Session 5: May 27, 2026

This session replaced every UI-visible emoji in the app with Lucide icons across 17 files.

The original codebase used emoji characters as icon stand-ins throughout the UI. While convenient during development, emoji rendering is inconsistent across iOS versions, looks low-quality compared to proper vector icons, and breaks the visual language of a polished app.

I added the lucide_icons_flutter package and built an icon mapping for every emoji in use. The Achievement model's field type changed from String (holding an emoji character) to IconData (holding an icon reference). Every widget that rendered an emoji via a Text widget was updated to render an Icon widget instead.

Notable changes included: converting the achievement locked state from a ColorFiltered greyscale matrix to a simple muted-color icon (simpler and more readable code achieving the same visual result), converting streak warning labels in the habit card from a single Text widget with an emoji prefix to a Row containing an Icon and a Text (better layout control), and updating the milestone display in the journey path to use a proper ternary expression returning different widget types rather than a single conditional text string.

The session also resolved a lint warning introduced by converting a list of emoji strings to a list of LucideIcons constants, by changing the list declaration from final to const.

---

## Bugs Found and Fixed

**Streak showing as zero after successful compile.** The streak calculation was running before the vlog write operation completed. Moved the recalculation to the save callback so it only runs on confirmed writes.

**Streak falling back to habit creation date.** The Habit model had no dedicated lastCompletedAt field. Without it, the streak logic was guessing. Added an explicit DateTime field updated every time a vlog is compiled for that habit.

**Switching accounts showed another user's habits.** All JSON files used fixed names. Fixed by appending the Supabase userId to every filename.

**Camera screen did not auto-resume after backgrounding.** If you had all three clips recorded but had not compiled yet, returning to the camera screen would start you over instead of going straight to compilation. Fixed by checking DailyLogStatus.clipsComplete on screen mount and skipping directly to the compilation flow.

**Onboarding shown to already-authenticated users on cold start.** The router was not checking session state before the Supabase client finished initializing. Fixed with the GoRouterRefreshStream approach so the redirect guard fires after the session is confirmed.

**Daily logs not surviving app restart.** The DailyLog model's toJson method was not serializing the inner dailyLogs map correctly. Fixed by updating the serialization to properly write and read the nested structure.

**Lint warning on const list in onboarding screen.** After converting a list of emoji strings to LucideIcons values, the analyzer flagged the list as a candidate for const because all values are compile-time constants. Changed the declaration to const.

---

## Design Philosophy

**Dark-first.** The entire app was designed in dark mode from the first day. The background is near-black (#0F0F0F), cards are slightly lighter (#1A1A1A), and elevated elements are lighter still (#262626). This three-layer system creates visual depth without bright colors.

**4-pixel spacing grid.** Every spacing value in the app is a multiple of 4 pixels: 4, 8, 16, 24, 32, 48. Using a consistent grid means the eye perceives the layout as orderly even without consciously noticing why.

**Category colors as a language.** Every Physical habit is blue. Every Mental habit is purple. Every Creative habit is orange. Every Growth habit is green. These colors appear on cards, in the journey path, on the camera screen, and in the stats. The user learns the color grammar unconsciously, and it helps them navigate the app quickly.

**Rarity colors borrowed from games.** The achievement system uses a color hierarchy that will be immediately familiar to anyone who has played games: gray for common, green for uncommon, blue for rare, purple for epic, gold for legendary. This system communicates value instantly.

**Video as the primary object.** The camera screen is full-screen. Vlog thumbnails are prominent. The Journey Gallery is the centerpiece of each habit's screen. Everything in the app points toward creating and reviewing vlogs, because vlogs are the artifact that makes the app worth using.

**Empty states must have a direction.** Every empty state in the app tells you what to do next. The empty habits list says to create your first habit. The empty journey screen says to record your first day. An empty state that just shows a sad icon and says "nothing here" is a dead end. Every empty state in Day1 is a starting line.

**Celebrate at the right moment.** The XP popup, level-up overlay, and achievement toasts only appear after a vlog is compiled. They do not interrupt the recording flow or appear randomly. The celebration is earned, which makes it feel good rather than annoying.

---

## Skills and Concepts Demonstrated

**Flutter fundamentals.** The difference between StatelessWidget, StatefulWidget, ConsumerWidget, and ConsumerStatefulWidget. Building widget trees, using BuildContext, managing the widget lifecycle, and using Keys for performance.

**Reactive state management.** Riverpod providers: StateNotifierProvider for mutable state, Provider for derived values, FutureProvider for async data, and family modifiers for parameterized providers. Understanding when UI rebuilds and how to minimize unnecessary rebuilds.

**Declarative navigation.** go_router for defining route hierarchies, passing path and query parameters, using redirect guards for authentication, and integrating navigation with async state using refresh streams.

**Async programming.** Future and async/await for file operations and network calls. Stream and StreamSubscription for reactive authentication state. Error handling with try/catch and graceful fallback states in the UI.

**Data modeling.** Immutable data classes with final fields. Serialization and deserialization with toJson and fromJson. The copyWith pattern for updating a single field without mutating the original.

**File system operations.** Using path_provider to locate the correct storage directory. Reading and writing JSON files. Managing per-user file paths to prevent data leakage between accounts.

**Camera and video on iOS.** The camera package for live preview, recording controls, front/rear switching, and clip file management. The video_player package for playback. Handling iOS permissions for camera, microphone, and photo library access.

**Video processing.** Integrating FFmpeg via a Flutter plugin. Constructing FFmpeg command strings for video concatenation. Running FFmpeg asynchronously with progress callbacks.

**Authentication.** Supabase auth flow: sign-up with email and password, sign-in, session persistence across app restarts, and sign-out. Connecting auth state changes to UI navigation via streams.

**Database integration.** Supabase PostgreSQL: inserting, updating, querying, and deleting rows. Understanding how Row Level Security policies enforce per-user data isolation at the database level.

**Animation.** flutter_animate for chaining animations (fadeIn, slideY, scale) with delays and durations. Understanding the difference between implicit animations (AnimatedContainer, AnimatedScale) and explicit animations (AnimationController).

**Design systems.** Building a token-based design system with named constants for every color, typography style, and spacing value. Understanding why this approach produces more maintainable and consistent UI than hardcoded values.

**Icon systems.** The difference between emoji and vector icons. How icon libraries (Lucide) provide consistent, scalable, theme-responsive icons across all device sizes and OS versions.

**Git version control.** Committing meaningful units of work with descriptive messages. Reading git log and git diff to understand change history. Managing a multi-session project across four months with clean commits.

**Code quality.** Running flutter analyze to catch errors and warnings. Understanding the difference between errors (code will not compile), warnings (code may behave unexpectedly), and info messages (style suggestions). Resolving lint warnings rather than suppressing them.

---

## Project by the Numbers

| Stat | Value |
|------|-------|
| Development period | February 26, 2026 to May 27, 2026 |
| Number of sessions | 5 |
| Git commits | 5 |
| Files in the Flutter lib directory | 80+ Dart files |
| Lines added in initial commit | 14,903 |
| Total lines added across all commits | approximately 23,000 |
| Flutter packages used | 15+ |
| Screens built | 12 distinct screens |
| Habit templates defined | 26 |
| Achievements defined | 30 |
| Planning documents written before coding | 3 |
| Lines in the development plan | 1,723 |
| Lines in the PRD | 485 |
| Lines in the camera screen | 798 |
| Files updated in the emoji-to-icons refactor | 17 |

---

## What Is Still In Progress

The app is feature-complete for the core recording, gamification, and journey gallery flows. Work remaining before an App Store submission includes:

Push notifications for daily reminders and streak danger alerts. These require registering for push notification entitlements on iOS and handling the notification permission prompt.

A settings screen where the user can edit their display name and configure notification preferences.

Storage management tools showing how much disk space the clips and vlogs are using, with the option to delete old content.

App Store assets: icon at all required sizes, launch screen, privacy policy, app description and keywords, and screenshots at the required dimensions.

Full FFmpeg concatenation with title cards and crossfade transitions between clips. The current compilation creates a valid vlog reference from three clips, but a production version would add a visual identity to the compiled video.

---

## Summary

Day1 is a production-scale iOS application built in Flutter over approximately four months. It covers the full range of mobile development challenges: complex UI with custom animations, device hardware integration (camera and microphone), video processing, local file storage, cloud authentication and database, and a complete gamification system. Every architectural decision was documented before coding began. Bugs were investigated, understood, and fixed at the root rather than worked around. The codebase is organized so that each layer of the system can change independently without breaking the others.
