# Day1 Design System

> **Read this file before building ANY UI component.**

---

## Brand Essence

**Tagline:** "Be the main character of your own journey"

**Personality:** Confident, energizing, empowering. Like a hype friend who believes in you.

**Visual Vibe:** Dark, bold, premium. The love child of Duolingo's gamification and a high-end fitness app. Never boring, never generic, never "default Flutter."

---

## The Three Rules

1. **Bold over subtle** — If you're unsure, make it bigger/bolder
2. **Celebrate everything** — Every completion is a win worth animating
3. **Dark with energy** — Dark backgrounds, vibrant accent colors

---

## Colors

### Core Palette

```
BACKGROUNDS
├── Background Primary .... #0F0F0F  (near-black, not pure #000)
├── Background Card ....... #1A1A1A  (elevated surfaces)
├── Background Surface .... #262626  (inputs, secondary cards)
└── Background Elevated ... #2D2D2D  (modals, dropdowns)

PRIMARY BRAND
├── Primary ............... #3B82F6  (actions, links, focus)
├── Primary Light ......... #60A5FA  (hover states, highlights)
└── Primary Dark .......... #1D4ED8  (pressed states)

CATEGORY COLORS (The 4 Wins)
├── Physical 💪 ........... #3B82F6  (Blue)
├── Mental 🧠 ............. #8B5CF6  (Purple)
├── Creative 🎨 ........... #F97316  (Orange)
└── Growth 🌱 ............. #22C55E  (Green)

GAMIFICATION
├── XP Gold ............... #F59E0B  (experience points)
├── Streak Fire ........... #EF4444  (streaks, urgency)
├── Success ............... #22C55E  (completions, positive)
├── Warning ............... #FBBF24  (alerts, caution)
└── Level Purple .......... #A855F7  (level-ups, premium)

TEXT
├── Text Primary .......... #FFFFFF  (headings, important)
├── Text Secondary ........ #A3A3A3  (body, descriptions)
├── Text Tertiary ......... #737373  (hints, disabled)
└── Text On Color ......... #FFFFFF  (text on colored backgrounds)

BORDERS & DIVIDERS
├── Border Default ........ #333333
├── Border Subtle ......... #262626
└── Divider ............... #1F1F1F
```

### Color Usage Rules

- **Never use pure black (#000000)** — Always #0F0F0F or darker grays
- **Category colors are accents only** — Use for icons, borders, badges—not full backgrounds
- **XP Gold and Streak Fire are sacred** — Only for XP displays and streak indicators
- **White text on dark backgrounds** — No gray text for important information

---

## Typography

### Font Family

**Primary:** Inter (Google Fonts)
- Modern, highly legible, excellent for UI
- Use variable font for performance

**Fallback:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`

### Type Scale

```
DISPLAY (Hero moments)
├── Day Counter ........... 72px / Black (900) / -2% tracking
└── Level Number .......... 48px / Bold (700) / -1% tracking

HEADINGS
├── H1 (Screen titles) .... 32px / Bold (700) / -1% tracking
├── H2 (Section titles) ... 24px / SemiBold (600) / -0.5% tracking
├── H3 (Card titles) ...... 20px / SemiBold (600) / 0 tracking
└── H4 (Labels) ........... 16px / Medium (500) / 0 tracking

BODY
├── Body Large ............ 18px / Regular (400) / 0 tracking
├── Body Default .......... 16px / Regular (400) / 0 tracking
├── Body Small ............ 14px / Regular (400) / 0 tracking
└── Caption ............... 12px / Medium (500) / 0.5% tracking

SPECIAL
├── Button Text ........... 16px / SemiBold (600) / 0.5% tracking
├── Tab Label ............. 14px / Medium (500) / 0 tracking
├── Badge Text ............ 12px / Bold (700) / 0.5% tracking
└── XP Display ............ 24px / Bold (700) / 0 tracking
```

### Typography Rules

- **Headings are always bold or semibold** — Never regular weight for titles
- **Tight tracking on large text** — Negative letter-spacing on 24px+
- **Generous line height for body** — 1.5 for readability
- **ALL CAPS only for small labels** — Badge text, category labels, "DAY 14"

---

## Spacing System

### Base Unit: 4px

```
SPACING SCALE
├── xs .... 4px   (tight internal spacing)
├── sm .... 8px   (between related elements)
├── md .... 16px  (standard padding, gaps)
├── lg .... 24px  (section spacing)
├── xl .... 32px  (major sections)
└── 2xl ... 48px  (screen-level spacing)
```

### Common Applications

```
SCREEN
├── Horizontal padding .... 20px
├── Top safe area ......... System + 16px
└── Bottom nav clearance .. 100px

CARDS
├── Internal padding ...... 16px
├── Gap between cards ..... 12px
└── Border radius ......... 16px

BUTTONS
├── Horizontal padding .... 24px
├── Vertical padding ...... 16px (56px total height)
└── Border radius ......... 12px

LISTS
├── Item padding .......... 16px vertical
├── Gap between items ..... 8px
└── Divider inset ......... 16px from edges
```

---

## Components

### Cards

```
HABIT CARD
├── Background: #1A1A1A
├── Border: 1px solid #262626
├── Border radius: 16px
├── Padding: 16px
├── Category accent: 4px left border in category color
└── Shadow: none (flat design)

STAT CARD
├── Background: #1A1A1A
├── Border radius: 12px
├── Padding: 12px 16px
└── Icon + number + label layout
```

### Buttons

```
PRIMARY BUTTON
├── Background: #3B82F6
├── Text: #FFFFFF, 16px SemiBold
├── Height: 56px
├── Border radius: 12px
├── Full width in forms
├── Pressed: #1D4ED8
└── Disabled: #333333 bg, #737373 text

SECONDARY BUTTON
├── Background: #262626
├── Border: 1px solid #333333
├── Text: #FFFFFF
└── Same dimensions as primary

GHOST BUTTON
├── Background: transparent
├── Text: #3B82F6
└── Used for tertiary actions

ICON BUTTON
├── Size: 48px × 48px
├── Background: #262626
├── Border radius: 12px
└── Icon: 24px
```

### Inputs

```
TEXT INPUT
├── Background: #1A1A1A
├── Border: 1px solid #333333
├── Border radius: 12px
├── Height: 56px
├── Padding: 16px
├── Focus border: #3B82F6
├── Placeholder: #737373
└── Text: #FFFFFF

SELECTOR/DROPDOWN
├── Same styling as text input
├── Chevron icon on right
└── Options in modal/bottom sheet
```

### Progress Indicators

```
XP BAR
├── Track: #262626
├── Fill: Linear gradient #F59E0B → #FBBF24
├── Height: 8px
├── Border radius: 4px (full round)
└── Animate on change

HABIT PROGRESS
├── Track: #262626
├── Fill: Category color
├── Show "2/3 clips" text
└── Segmented style (3 segments for 3 clip types)

STREAK COUNTER
├── Fire emoji: 🔥 (or custom icon)
├── Number: 48px Bold, #EF4444 or white
├── "day streak" label below
└── Animate flame on milestone
```

### Navigation

```
BOTTOM NAV BAR
├── Background: #0F0F0F
├── Border top: 1px solid #1F1F1F
├── Height: 80px + safe area
├── 5 items: Home, Journey, [Record], Stats, Profile
├── Center item: Prominent record button (56px, Primary color)
├── Active: Primary color icon + label
└── Inactive: #737373 icon, no label

TOP APP BAR
├── Background: transparent or #0F0F0F
├── No elevation/shadow
├── Title: H1 style, left-aligned
└── Actions: Icon buttons on right
```

---

## Iconography

### Style

- **Line icons** — 2px stroke weight
- **Rounded caps and joins**
- **24px default size** — 20px for compact, 32px for emphasis
- **Lucide icons** — Primary icon library (consistent with React ecosystem)

### Category Icons

```
💪 Physical .... Dumbbell or flexed bicep
🧠 Mental ...... Brain or meditation pose
🎨 Creative .... Palette or paintbrush
🌱 Growth ...... Seedling or trending up arrow
```

### Common Icons

```
Navigation: home, compass, plus-circle, bar-chart-2, user
Actions: play, pause, check, x, share, download, trash
Recording: video, camera, mic, flip-camera
Gamification: flame, trophy, star, zap, award
Utility: settings, bell, chevron-right, info
```

---

## Animations & Micro-interactions

### Principles

1. **Fast and snappy** — 200-300ms for most transitions
2. **Purposeful** — Animation should guide attention, not distract
3. **Celebratory for wins** — Go big on completions and achievements

### Standard Timings

```
QUICK (100-200ms)
├── Button press feedback
├── Toggle switches
└── Icon state changes

STANDARD (200-300ms)
├── Screen transitions
├── Card expansions
├── Modal appearances
└── List item stagger

SLOW (400-600ms)
├── Page route transitions
├── Complex reveals
└── Celebration animations (can be longer)
```

### Specific Animations

```
BUTTON PRESS
├── Scale to 0.96
├── Duration: 100ms
├── Ease: ease-out
└── Haptic: light impact

CARD TAP
├── Scale to 0.98
├── Subtle brightness increase
└── Haptic: light impact

COMPLETION CELEBRATION
├── Checkmark draws in (Lottie)
├── Confetti burst
├── XP number flies to header
└── Duration: 800-1200ms

LEVEL UP
├── Full-screen overlay
├── Number scales up dramatically
├── Particles/confetti
├── Sound effect (optional)
└── Duration: 2-3 seconds

STREAK MILESTONE
├── Flame grows and pulses
├── Number counts up
├── Screen shake (subtle)
└── Badge flies in from bottom

RECORDING START
├── Red dot pulses
├── Timer counts up
├── Subtle vignette on camera
└── Day overlay animates in

VLOG COMPILATION
├── Progress bar fills
├── Clips flash as processed
├── "Complete" with check animation
└── Preview thumbnail reveals
```

### Animation Tools

- **flutter_animate** — Declarative animation chains
- **Lottie** — Complex celebration animations (confetti, check marks, level-ups)
- **Rive** — Interactive animations (optional, for premium feel)

---

## Recording UI Specifics

### Camera Overlay

```
DAY COUNTER OVERLAY
├── Position: Center-bottom of camera preview
├── Background: Semi-transparent black (#000000 @ 60%)
├── Border radius: 12px
├── Padding: 12px 24px
├── "DAY 14" text: 32px Bold, white
├── Habit name below: 16px Medium, #A3A3A3
└── Always visible during recording
```

### Clip Type Indicator

```
CLIP PROGRESS BAR
├── 3 segments: Intention | Evidence | Reflection
├── Completed: Category color fill
├── Current: Pulsing/animated
├── Upcoming: #333333
├── Labels below each segment
└── Position: Top of screen, below safe area
```

### Record Button

```
RECORD BUTTON
├── Size: 80px diameter
├── Idle: White ring (4px stroke), transparent center
├── Recording: Solid red (#EF4444), pulsing
├── Inner icon: Circle (idle) → Square (recording)
├── Tap to start, tap to stop
└── Position: Center bottom, 32px from bottom safe area
```

---

## Empty States

### Principles

- **Never leave blank** — Always show illustration + message + action
- **Encouraging tone** — "Start your journey" not "No data"
- **Clear CTA** — One obvious button to fix the empty state

### Examples

```
NO HABITS YET
├── Illustration: Person starting a journey / sunrise
├── Headline: "Every journey starts with Day 1"
├── Body: "Create your first habit and start documenting your transformation"
└── CTA: [Create First Habit] button

NO VLOGS FOR THIS HABIT
├── Illustration: Empty film reel / camera
├── Headline: "Your journey awaits"
├── Body: "Record your first clip to start building your vlog"
└── CTA: [Record Now] button

STREAK LOST
├── Illustration: Extinguished flame / rain
├── Headline: "The flame went out"
├── Body: "But every setback is a setup for a comeback. Start again today."
└── CTA: [Reignite Streak] button
```

---

## Do's and Don'ts

### ✅ DO

- Use the exact hex colors specified
- Make streak/XP numbers BIG and proud
- Celebrate completions with animation
- Use Inter font consistently
- Keep dark backgrounds, vibrant accents
- Add micro-interactions to tappable elements
- Use category colors as accents
- Make buttons chunky (56px height)

### ❌ DON'T

- Use default Flutter Material widgets unstyled
- Use light/white backgrounds anywhere
- Use thin/light font weights for important text
- Make small, subtle buttons
- Skip animations on completions
- Use generic gray (#888) for accents
- Leave empty states blank
- Forget the left color accent on habit cards
- Use pure black (#000000)
- Crowd the UI—embrace whitespace (darkspace?)

---

## Quick Reference for Claude Code

When building a component, check:

1. **Background color** — Is it #0F0F0F, #1A1A1A, or #262626?
2. **Border radius** — 16px for cards, 12px for buttons, 4px for small elements
3. **Text style** — Correct size and weight from the scale?
4. **Spacing** — Using 4px grid? 16px standard padding?
5. **Colors** — Using exact palette colors, not approximations?
6. **Animation** — Does it need a micro-interaction or celebration?
7. **Empty state** — What shows when there's no data?

---

*"Make it feel like winning feels."*
