//
//  CityMeetingPlayerView.swift
//  CatsTV
//
//  Full-screen player for City Meeting m4v videos.
//  Fetches the companion VTT file and renders closed captions as an overlay
//  using a periodic AVPlayer time observer.
//

import SwiftUI
import AVKit

// MARK: - VTT Subtitle Cue

private struct VTTCue {
    let start: TimeInterval
    let end: TimeInterval
    let text: String
}

// MARK: - VTT Parser

private func parseVTT(_ content: String) -> [VTTCue] {
    var cues: [VTTCue] = []
    let lines = content.components(separatedBy: "\n")
    var i = 0

    while i < lines.count {
        let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)

        // Timestamp lines contain " --> "
        if line.contains(" --> ") {
            let arrowParts = line.components(separatedBy: " --> ")
            if arrowParts.count >= 2,
               let start = parseVTTTimestamp(arrowParts[0]),
               // End time may be followed by positioning hints; take only the first token
               let end = parseVTTTimestamp(arrowParts[1].components(separatedBy: " ").first ?? arrowParts[1]) {

                var textLines: [String] = []
                i += 1
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    if t.isEmpty { break }
                    textLines.append(t)
                    i += 1
                }

                // Strip VTT/HTML tags and trim
                let raw = textLines.joined(separator: " ")
                let text = raw
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !text.isEmpty {
                    cues.append(VTTCue(start: start, end: end, text: text))
                }
            }
        }
        i += 1
    }
    return cues
}

private func parseVTTTimestamp(_ s: String) -> TimeInterval? {
    let trimmed = s.trimmingCharacters(in: .whitespaces)
    let parts = trimmed.components(separatedBy: ":")
    switch parts.count {
    case 3:
        guard let h = Double(parts[0]), let m = Double(parts[1]), let sec = Double(parts[2])
        else { return nil }
        return h * 3600 + m * 60 + sec
    case 2:
        guard let m = Double(parts[0]), let sec = Double(parts[1])
        else { return nil }
        return m * 60 + sec
    default:
        return nil
    }
}

// MARK: - Player View

struct CityMeetingPlayerView: View {
    let video: CityMeetingVideo

    @State private var player: AVPlayer?
    @State private var cues: [VTTCue] = []
    @State private var currentSubtitle = ""
    @State private var isLoading = true
    @State private var timeObserverToken: Any?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()

                overlayContent
            }
        }
        .task { await setup() }
        .onDisappear { teardown() }
    }

    // MARK: - Sub-views

    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2)
                .tint(CATSTheme.accentCoral)
            Text("Loading \(video.title)…")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(CATSTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 80)
        }
    }

    private var overlayContent: some View {
        VStack {
            // Info badge — top left
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 20))
                    Text(video.title)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black.opacity(0.6)))

                Spacer()
            }
            .padding(.top, 40)
            .padding(.leading, 40)

            Spacer()

            // Closed captions — bottom center
            if !currentSubtitle.isEmpty {
                Text(currentSubtitle)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(8)
                    .padding(.bottom, 60)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.15), value: currentSubtitle)
            }
        }
    }

    // MARK: - Setup / Teardown

    private func setup() async {
        // Load VTT captions (non-fatal if unavailable)
        if let (data, _) = try? await URLSession.shared.data(from: video.captionsURL),
           let text = String(data: data, encoding: .utf8) {
            cues = parseVTT(text)
        }

        let item = AVPlayerItem(url: video.videoURL)
        let avPlayer = AVPlayer(playerItem: item)
        avPlayer.automaticallyWaitsToMinimizeStalling = true

        // Wait for the item to be ready before playing so it doesn't hang
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var obs: NSKeyValueObservation?
            obs = item.observe(\.status, options: [.initial, .new]) { item, _ in
                guard item.status == .readyToPlay || item.status == .failed else { return }
                obs?.invalidate()
                obs = nil
                continuation.resume()
            }
        }

        // Attach periodic observer for subtitle sync (~4 times/sec)
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let token = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [cues] time in
            let t = time.seconds
            currentSubtitle = cues.first { $0.start <= t && t < $0.end }?.text ?? ""
        }
        timeObserverToken = token

        avPlayer.play()
        player = avPlayer
        isLoading = false
    }

    private func teardown() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
    }
}
