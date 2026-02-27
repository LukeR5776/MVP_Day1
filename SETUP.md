# Day1 Flutter App - Setup Guide

Complete instructions to set up and run the Day1 Flutter app on an iOS Simulator.

## System Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 12.0+ (Monterey or later) |
| Xcode | 15.0+ |
| Flutter SDK | 3.2.0+ |
| Dart SDK | 3.2.0+ |
| CocoaPods | 1.11.0+ |

## Dependencies Installed

The following have been installed on this system:

- **Flutter SDK**: 3.38.8 (via Homebrew at `/opt/homebrew/bin/flutter`)
- **CocoaPods**: 1.16.2 (via Homebrew at `/opt/homebrew/bin/pod`)
- **Xcode**: Installed at `/Applications/Xcode.app`

## Quick Start (Manual Steps Required)

### Step 1: Configure Xcode (REQUIRED - Run Manually)

Open Terminal and run these commands (requires password):

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

### Step 2: Install iOS Simulator Platform

```bash
xcodebuild -downloadPlatform iOS
```

Or open Xcode > Settings > Platforms > Download iOS Simulator.

### Step 3: Install CocoaPods Dependencies

```bash
cd /Users/lryan.27/Downloads/MVP_Day1-main/ios
export LANG=en_US.UTF-8
pod install
```

### Step 4: Launch Simulator and Run App

```bash
# Open iOS Simulator
open -a Simulator

# Run the app (from project root)
cd /Users/lryan.27/Downloads/MVP_Day1-main
flutter run
```

## Full Installation Guide (From Scratch)

If setting up on a new Mac, follow these steps:

### 1. Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Xcode

Download from the Mac App Store or:
```bash
xcode-select --install
```

Then download full Xcode from App Store.

### 3. Configure Xcode Developer Tools

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

### 4. Install Flutter SDK

```bash
brew install --cask flutter
```

Verify installation:
```bash
flutter --version
```

### 5. Install CocoaPods

```bash
brew install cocoapods
```

### 6. Install Project Dependencies

```bash
cd /Users/lryan.27/Downloads/MVP_Day1-main

# Install Flutter/Dart packages
flutter pub get

# Install iOS native dependencies
cd ios
export LANG=en_US.UTF-8
pod install
cd ..
```

### 7. Verify Setup

```bash
flutter doctor -v
```

All checks should pass (Android toolchain is optional for iOS development).

### 8. Run the App

```bash
# List available devices
flutter devices

# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

## Project Dependencies

### Flutter Packages (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.0 | State management |
| go_router | ^13.0.0 | Navigation/routing |
| google_fonts | ^6.1.0 | Inter font family |
| flutter_animate | ^4.3.0 | Animation framework |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_test | SDK | Testing framework |
| flutter_lints | ^3.0.0 | Code quality linting |

## Useful Commands

### Development

```bash
# Run app
flutter run

# Run with hot reload (default)
flutter run

# Run on specific device
flutter run -d <device_id>

# List devices
flutter devices

# Clean build
flutter clean && flutter pub get
```

### iOS Specific

```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace

# Rebuild iOS pods
cd ios && pod install --repo-update && cd ..
```

### Testing & Analysis

```bash
# Run tests
flutter test

# Run linting
flutter analyze

# Check for outdated packages
flutter pub outdated
```

## Troubleshooting

### Xcode Issues

**"Xcode installation is incomplete"**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

**"Unable to find utility simctl"**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### CocoaPods Issues

**"UTF-8 encoding" error**
```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

Add to your `~/.zshrc` or `~/.bash_profile` for persistence.

**"pod install" fails**
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install --repo-update
```

### Flutter Issues

**"Flutter not found"**
```bash
# Add to ~/.zshrc
export PATH="$PATH:/opt/homebrew/bin"
```

**Dependency conflicts**
```bash
flutter clean
flutter pub get
```

### Simulator Issues

**No simulators available**
```bash
# Download iOS platform
xcodebuild -downloadPlatform iOS

# Or through Xcode
# Xcode > Settings > Platforms > Download iOS
```

**Simulator won't boot**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
```

## Current Status

| Component | Status |
|-----------|--------|
| Flutter SDK | Installed (3.38.8) |
| CocoaPods | Installed (1.16.2) |
| Xcode | Installed (needs configuration) |
| Flutter packages | Installed |
| iOS pods | Pending (run after Xcode config) |

## Next Steps After Setup

1. Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
2. Run `sudo xcodebuild -runFirstLaunch`
3. Run `cd ios && pod install && cd ..`
4. Run `open -a Simulator`
5. Run `flutter run`

The app should launch in the iOS Simulator.
