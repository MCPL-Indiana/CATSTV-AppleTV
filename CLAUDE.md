# CLAUDE.md - CatsTV

## Project Overview

CatsTV is a tvOS app (Apple TV) for CATS (Community Access Television Services) in Bloomington, IN. It provides a live stream viewer for four public access TV channels via HLS streaming.

## Tech Stack

- **Language:** Swift 5.0
- **UI Framework:** SwiftUI (tvOS-specific: `@FocusState`, `fullScreenCover`)
- **Media Playback:** AVKit (`AVPlayer`, `VideoPlayer`)
- **Streaming:** HLS via Dacast/Akamai CDN (`.m3u8` manifests)
- **Platform:** tvOS 18.5+
- **Xcode:** 16.4+
- **Dependencies:** None (no SPM, CocoaPods, or Carthage)

## Project Structure

```
CatsTV/
├── CatsTVApp.swift              # @main app entry point
├── ContentView.swift            # Root view - header, channel grid, footer
├── Models/
│   └── Channel.swift            # Channel model with static allChannels data
├── Theme/
│   └── CATSTheme.swift          # Centralized colors, gradients, and styling
├── Views/
│   ├── CATSLogoView.swift       # CATS banner logo (image asset)
│   ├── ChannelCardView.swift    # Focusable channel card with LIVE badge
│   └── LiveStreamPlayerView.swift  # Full-screen AVPlayer view
└── Assets.xcassets/
    └── CATSLogo.imageset/       # Official CATS logo PNG
```

## Architecture

Lightweight Model-View pattern. No ViewModels — state is managed directly in views via `@State` and `@FocusState`. The theme is a caseless `enum` namespace with static properties.

## Build Commands

```bash
# Build for tvOS simulator
xcodebuild -project CatsTV.xcodeproj -scheme CatsTV -destination 'platform=tvOS Simulator,name=Apple TV' build

# Run tests
xcodebuild test -scheme CatsTV -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Testing

- **Unit tests:** `CatsTVTests/` — Swift Testing framework (`@Test`, `#expect`)
- **UI tests:** `CatsTVUITests/` — XCUITest with launch performance metrics

## Theme System

All colors and gradients are defined in `CATSTheme.swift`. Key tokens:
- `accentCoral` — primary accent (LIVE badges, selected states)
- `backgroundDark` / `backgroundMedium` — dark card and content backgrounds
- `appBackgroundGradient` — full-screen vertical gradient
- `cardGradient` — channel card thumbnail gradient

## Git Conventions

- **Remote:** Named `Github` (not `origin`)
- **Main branch:** `main`
- **Claude branches:** `claude/<adjective-name>` (e.g., `claude/happy-joliot`)
- **Workflow:** Feature branches merged to `main` via GitHub PRs
