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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with CATS logo
                        headerView
                            .padding(.top, 20)

                        // "WATCH CATS LIVE" heading
                        VStack(spacing: 8) {
                            (
                            Text("WATCH CATS ")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(CATSTheme.textPrimary)
                            + Text("LIVE")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(CATSTheme.accentCoral)
                        )
                            Text("Select a channel to start watching")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(CATSTheme.textSecondary)
                        }
                        .padding(.vertical, 36)

                        // Channel selection grid
                        channelGrid
                            .padding(.horizontal, 60)

                        // Divider before archive section
                        Rectangle()
                            .fill(CATSTheme.backgroundMedium.opacity(0.4))
                            .frame(height: 1)
                            .padding(.horizontal, 60)
                            .padding(.top, 36)

                        // "CATS ARCHIVE" section heading
                        Text("CATS ARCHIVE")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(CATSTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 24)

                        // City Meetings video section
                        CityMeetingsSection()
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                    }
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
            CATSLogoView(height: 56)
            Spacer()
            Text("LIVE STREAMS")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CATSTheme.accentCoral)
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
                let isFocused = focusedChannelID == channel.id
                let isSelected = isFocused

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
