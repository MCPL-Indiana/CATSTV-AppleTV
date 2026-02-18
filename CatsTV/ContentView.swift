//
//  ContentView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedChannel: Channel?
    @State private var isPlayingStream = false
    @FocusState private var focusedChannelID: String?

    private let channels = Channel.allChannels

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen dark background
                CATSTheme.appBackgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with CATS logo
                    headerView
                        .padding(.top, 20)

                    Spacer()

                    // "WATCH CATS LIVE" heading
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Text("WATCH CATS")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(CATSTheme.textPrimary)
                            Text("LIVE")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(CATSTheme.accentCoral)
                        }
                        Text("Select a channel to start watching")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(CATSTheme.textSecondary)
                    }
                    .padding(.bottom, 40)

                    // Channel selection grid
                    channelGrid
                        .padding(.horizontal, 60)

                    Spacer()

                    // Footer
                    footerView
                        .padding(.bottom, 20)
                }
            }
            .fullScreenCover(isPresented: $isPlayingStream) {
                if let channel = selectedChannel {
                    LiveStreamPlayerView(channel: channel)
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            CATSLogoView(size: 56)
            Spacer()
            HStack(spacing: 30) {
                Text("LIVE STREAMS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CATSTheme.accentCoral)
            }
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(CATSTheme.backgroundDark.opacity(0.5))
        )
    }

    // MARK: - Channel Grid

    private var channelGrid: some View {
        HStack(spacing: 36) {
            ForEach(channels) { channel in
                let isSelected = selectedChannel?.id == channel.id
                let isFocused = focusedChannelID == channel.id

                Button {
                    selectedChannel = channel
                    isPlayingStream = true
                } label: {
                    ChannelCardView(
                        channel: channel,
                        isSelected: isSelected,
                        isFocused: isFocused
                    )
                }
                .buttonStyle(CardButtonStyle())
                .focused($focusedChannelID, equals: channel.id)
                .onChange(of: focusedChannelID) { _, newValue in
                    if newValue == channel.id {
                        selectedChannel = channel
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 4) {
            Text("Community Access Television Services")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(CATSTheme.textSecondary)
            Text("303 E. Kirkwood Ave. \u{2022} Bloomington, IN 47408 \u{2022} (812) 349-3111")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(CATSTheme.textMuted)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(CATSTheme.footerGray.opacity(0.3))
        )
    }
}

// MARK: - Card Button Style (for tvOS focus)

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

#Preview {
    ContentView()
}
