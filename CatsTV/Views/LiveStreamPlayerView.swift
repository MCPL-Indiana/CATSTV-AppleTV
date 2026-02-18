//
//  LiveStreamPlayerView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI
import AVKit

struct LiveStreamPlayerView: View {
    let channel: Channel
    @State private var player: AVPlayer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                // Loading state
                VStack(spacing: 24) {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(CATSTheme.accentCoral)

                    Text("Loading \(channel.name) Live Stream...")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(CATSTheme.textPrimary)
                }
            }

            // Channel info overlay at top
            VStack {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: channel.iconName)
                            .font(.system(size: 24))
                        Text(channel.name.uppercased())
                            .font(.system(size: 24, weight: .bold))
                        HStack(spacing: 6) {
                            Circle()
                                .fill(CATSTheme.accentCoral)
                                .frame(width: 8, height: 8)
                            Text("LIVE")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(CATSTheme.accentCoral)
                        }
                        .padding(.leading, 8)
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
            .opacity(player != nil ? 1 : 0)
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: channel.streamURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.play()
        self.player = avPlayer
    }
}

#Preview {
    LiveStreamPlayerView(channel: Channel.allChannels[0])
}
