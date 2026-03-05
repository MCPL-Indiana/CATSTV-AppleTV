# CatsTV

A tvOS app for [CATS (Community Access Television Services)](https://catstv.net) in Bloomington, IN. Watch four public access TV channels live on your Apple TV.

## Channels

- **City Channel** — Bloomington City Government
- **County Channel** — Monroe County Government
- **Library Channel** — Monroe County Public Library
- **Special 2** — Special Programming

## Requirements

- tvOS 18.5+
- Xcode 16.4+

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Codymullis/CATSTV-AppleTV.git
   ```
2. Open `CatsTV.xcodeproj` in Xcode.
3. Select the **CatsTV** scheme and an Apple TV simulator.
4. Build and run (⌘R).

## Build from Command Line

```bash
# Build
xcodebuild -project CatsTV.xcodeproj -scheme CatsTV \
  -destination 'platform=tvOS Simulator,name=Apple TV' build

# Run tests
xcodebuild test -scheme CatsTV \
  -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Most Recent Videos

Below the live channel grid, the app surfaces three on-demand video sections pulled from the CATS/MCPL JSON feeds:

- **Government Meetings** — City and county government meeting recordings
- **Community Videos** — Community-produced programming
- **CATSWeek** — Weekly CATS highlight videos

Each section is a horizontally scrollable row of thumbnail cards. Selecting a card opens a full-screen player (`CityMeetingPlayerView`) with synced closed captions rendered from the companion VTT file.

## Tech Stack

- **Swift** + **SwiftUI** (tvOS focus engine, `fullScreenCover`)
- **AVKit** for HLS live stream playback and on-demand `.m4v` video
- Zero third-party dependencies

## License

All rights reserved. CATS — 303 E. Kirkwood Ave., Bloomington, IN 47408
