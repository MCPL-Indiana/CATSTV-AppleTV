# CLAUDE.md - CatsTV

## Project Overview

CatsTV is a tvOS app (Apple TV) for CATS (Community Access Television Services) in Bloomington, IN. It provides a live stream viewer for four public access TV channels via HLS streaming, plus a "Most Recent Videos" section with on-demand government meeting, community, and CATSWeek recordings.

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
├── ContentView.swift            # Root view - header, channel grid, recent videos sections
├── Models/
│   ├── Channel.swift            # Channel model with static allChannels data
│   └── CityMeetingVideo.swift   # Shared model for on-demand video entries (title, m4v, vtt, thumbnail)
├── Services/
│   ├── CityMeetingsService.swift   # Fetches city.json feed (Government Meetings)
│   ├── CommunityVideosService.swift # Fetches community.json feed (Community Videos)
│   └── CATSWeekService.swift       # Fetches catsweek.json feed (CATSWeek)
├── Theme/
│   └── CATSTheme.swift          # Centralized colors, gradients, and styling
├── Views/
│   ├── CATSLogoView.swift       # CATS banner logo (image asset)
│   ├── ChannelCardView.swift    # Focusable channel card with LIVE badge
│   ├── LiveStreamPlayerView.swift  # Full-screen AVPlayer view for live HLS streams
│   ├── CityMeetingsSection.swift   # Horizontal scroll row — Government Meetings cards
│   ├── CommunityVideosSection.swift # Horizontal scroll row — Community Videos cards
│   ├── CATSWeekSection.swift       # Horizontal scroll row — CATSWeek cards
│   └── CityMeetingPlayerView.swift # Full-screen player for on-demand videos with VTT captions
└── Assets.xcassets/
    └── CATSLogo.imageset/       # Official CATS logo PNG
```

## Architecture

Lightweight Model-View pattern. No ViewModels — state is managed directly in views via `@State` and `@FocusState`. The theme is a caseless `enum` namespace with static properties.

## Most Recent Videos

Below the live channel grid, `ContentView` renders a "MOST RECENT VIDEOS" heading followed by three horizontal-scrolling sections. Each section is self-contained: it owns its own `@State` / `@FocusState`, fetches its feed on `.task`, and presents `CityMeetingPlayerView` via `fullScreenCover`.

| Section | View | Service | Feed URL |
|---|---|---|---|
| Government Meetings | `CityMeetingsSection` | `CityMeetingsService` | `mcpl.info/catsjson/city.json` |
| Community Videos | `CommunityVideosSection` | `CommunityVideosService` | `mcpl.info/catsjson/community.json` |
| CATSWeek | `CATSWeekSection` | `CATSWeekService` | `mcpl.info/catsjson/catsweek.json` |

All three use `CityMeetingVideo` as the shared model and `CityMeetingCardView` for rendering thumbnail cards. `CityMeetingPlayerView` plays the `.m4v` file and renders closed captions by parsing the companion `.vtt` file and syncing cues with a periodic `AVPlayer` time observer.

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
