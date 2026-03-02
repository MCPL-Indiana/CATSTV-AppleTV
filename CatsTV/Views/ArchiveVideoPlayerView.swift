//
//  ArchiveVideoPlayerView.swift
//  CatsTV
//
//  Resolves the direct stream URL for an archived meeting and plays it with AVPlayer.
//  The ArchiveService fetches the m.php watch page, extracts the video URL, and
//  falls back to a /video/<id>.mp4 path if no URL can be parsed.
//

import SwiftUI
import AVKit

struct ArchiveVideoPlayerView: View {
    let video: ArchiveVideo

    @State private var player: AVPlayer? = nil
    @State private var resolving = true
    @State private var errorMessage: String? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch (resolving, player, errorMessage) {
            case (true, _, _):
                loadingView

            case (false, let p?, _):
                VideoPlayer(player: p)
                    .ignoresSafeArea()
                infoOverlay   // transparent overlay showing title / date

            case (false, _, let err?):
                errorView(err)

            default:
                EmptyView()
            }
        }
        .task { await resolveAndPlay() }
        .onDisappear {
            player?.pause()
            player = nil
        }
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

    private func errorView(_ msg: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(CATSTheme.accentCoral)

            Text("Video Unavailable")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(CATSTheme.textPrimary)

            Text(msg)
                .font(.system(size: 20))
                .foregroundStyle(CATSTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 100)

            Button("Go Back") { dismiss() }
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 10).fill(CATSTheme.accentCoral))
                .padding(.top, 8)
        }
    }

    /// Translucent title / date badge in the top-left corner (mimics LiveStreamPlayerView).
    private var infoOverlay: some View {
        VStack {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: video.category.iconName)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(video.title)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                        if !video.date.isEmpty {
                            Text(video.date)
                                .font(.system(size: 14))
                                .opacity(0.8)
                        }
                    }
                    if !video.duration.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(video.duration)
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.leading, 4)
                    }
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
        }
    }

    // MARK: - Video resolution

    private func resolveAndPlay() async {
        resolving     = true
        errorMessage  = nil

        do {
            guard let url = try await ArchiveService.shared.resolveVideoURL(meetingID: video.id) else {
                errorMessage = "This video could not be found for streaming.\nPlease try again later."
                resolving = false
                return
            }

            let item     = AVPlayerItem(url: url)
            let avPlayer = AVPlayer(playerItem: item)
            avPlayer.play()
            player    = avPlayer
        } catch {
            errorMessage = "Unable to load the video.\nPlease check your network connection."
        }
        resolving = false
    }
}

#Preview {
    ArchiveVideoPlayerView(
        video: ArchiveVideo(
            id:       "12345",
            title:    "Bloomington City Council 3/10",
            date:     "Mon, March 10, 2025",
            duration: "2:14:32",
            watchURL: URL(string: "https://catstv.net/m.php?q=12345")!,
            category: .cityBloomington
        )
    )
}
