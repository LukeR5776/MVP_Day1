# Day1

**Be the main character of your own journey**

A habit tracking app where users document their journey through video clips that compile into "Day X" vlogs. Think Duolingo's gamification meets TikTok's "Day X of Y" format.

## Project Structure

```
lib/
├── main.dart               # App entry point
├── app.dart                # Root app widget
├── core/
│   ├── theme/              # Design system implementation
│   ├── router/             # Navigation setup
│   └── constants/          # App-wide constants
├── shared/
│   └── widgets/            # Reusable components
└── features/               # Feature modules
    ├── habits/
    ├── recording/
    ├── journey/
    ├── gamification/
    └── settings/
```

## Design System

All UI components follow the design system defined in `DESIGN_SYSTEM.md`:

- **Colors**: Exact hex values from the design system
- **Typography**: Inter font family via Google Fonts
- **Spacing**: 4px base unit system
- **Components**: Pre-built with animations

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Available Components

### Buttons
- `PrimaryButton` - Main action button with press animation
- `AppIconButton` - Icon-only button for compact spaces

### Cards
- `BaseCard` - Base card with optional accent border

### Indicators
- `XPBar` - Progress bar with gold gradient
- `StreakCounter` - Streak display with fire emoji

### Layout
- `ScreenScaffold` - Standard screen wrapper
- `AppBottomNav` - 5-tab bottom navigation

## Development

This project uses:
- **State Management**: Riverpod
- **Navigation**: go_router
- **Animations**: flutter_animate
- **Typography**: google_fonts (Inter)

## License

Copyright © 2026 Day1. All rights reserved.
