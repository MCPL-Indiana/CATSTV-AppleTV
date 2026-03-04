//
//  YouTubePlayerView.swift
//  CatsTV
//
//  Full-screen player for YouTube videos using YouTubePlayerKit.
//

import SwiftUI
import YouTubePlayerKit

struct YouTubePlayerView: View {
    let video: YouTubeVideo
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player: YouTubePlayer

    init(video: YouTubeVideo) {
        self.video = video
        _player = StateObject(wrappedValue: YouTubePlayer(
            source: .video(id: video.id),
            configuration: .init(
                autoPlay: true,
                showControls: true,
                showRelatedVideos: false
            )
        ))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            YouTubePlayerKit.YouTubePlayerView(player)
                .ignoresSafeArea()

            // Title overlay at top
            VStack {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "play.tv")
                            .font(.system(size: 24))
                        Text(video.title)
                            .font(.system(size: 22, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(CATSTheme.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.6))
                    )

                    Spacer()
                }
                .padding(.top, 40)
                .padding(.leading, 40)

                Spacer()
            }
        }
    }
}
