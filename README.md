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

## Tech Stack

- **Swift** + **SwiftUI** (tvOS focus engine, `fullScreenCover`)
- **AVKit** for HLS live stream playback
- Zero third-party dependencies

## License

All rights reserved. CATS — 303 E. Kirkwood Ave., Bloomington, IN 47408
