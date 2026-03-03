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
    @State private var showArchive = false
    @State private var catsweekVideos: [YouTubeVideo] = []
    @State private var selectedYouTubeVideo: YouTubeVideo?
    @FocusState private var focusedChannelID: String?
    @FocusState private var archiveFocused: Bool

    private let channels = Channel.allChannels
    private let catsweekPlaylistID = "PLLKIocQNuYsu1nbJUXiESqzL9UzQWcSCt"

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
                        .padding(.top, 40)
                        .padding(.bottom, 40)

                        // Channel selection grid
                        channelGrid
                            .padding(.horizontal, 60)

                        // Archive button
                        archiveButton
                            .padding(.top, 40)

                        // CATSweek section
                        if !catsweekVideos.isEmpty {
                            catsweekSection
                                .padding(.top, 60)
                        }

                        Spacer().frame(height: 60)
                    }
                }
            }
            .fullScreenCover(isPresented: $isPlayingStream) {
                if let channel = selectedChannel {
                    LiveStreamPlayerView(channel: channel)
                }
            }
            .fullScreenCover(isPresented: $showArchive) {
                ArchiveView()
            }
            .fullScreenCover(item: $selectedYouTubeVideo) { video in
                YouTubePlayerView(video: video)
            }
            .task {
                await loadCATSweek()
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
                let isSelected = selectedChannel?.id == channel.id && !archiveFocused
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

    // MARK: - Archive Button

    private var archiveButton: some View {
        Button {
            showArchive = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "archivebox")
                    .font(.system(size: 20, weight: .semibold))
                Text("VIDEO ARCHIVE")
                    .font(.system(size: 22, weight: .bold))
            }
            .foregroundStyle(archiveFocused ? .white : CATSTheme.textSecondary)
            .frame(width: 400)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(archiveFocused
                          ? CATSTheme.backgroundDark.opacity(0.95)
                          : CATSTheme.backgroundMedium.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        archiveFocused ? CATSTheme.accentCoral : CATSTheme.textMuted.opacity(0.3),
                        lineWidth: archiveFocused ? 3 : 1
                    )
            )
            .scaleEffect(archiveFocused ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: archiveFocused)
        }
        .buttonStyle(CardButtonStyle())
        .focused($archiveFocused)
    }

    // MARK: - CATSweek Section

    private var catsweekSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CATSweek")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(CATSTheme.textPrimary)
                .padding(.horizontal, 80)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(catsweekVideos) { video in
                        CATSweekCardView(video: video) {
                            selectedYouTubeVideo = video
                        }
                    }
                }
                .padding(.horizontal, 80)
            }
        }
    }

    // MARK: - Data Loading

    private func loadCATSweek() async {
        do {
            catsweekVideos = try await YouTubeService.shared.fetchPlaylist(id: catsweekPlaylistID)
        } catch {
            catsweekVideos = []
        }
    }
}

// MARK: - CATSweek Card View

struct CATSweekCardView: View {
    let video: YouTubeVideo
    let onSelect: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CATSTheme.backgroundMedium)

                    if let url = video.thumbnailURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                                .tint(CATSTheme.accentCoral)
                        }
                    }

                    // Play icon overlay
                    Circle()
                        .fill(.black.opacity(0.5))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .offset(x: 2)
                        )
                }
                .frame(width: 320, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Title
                Text(video.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CATSTheme.textPrimary)
                    .lineLimit(2)
                    .frame(width: 320, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 4)
            }
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isFocused ? CATSTheme.accentCoral : Color.clear,
                        lineWidth: 3
                    )
                    .padding(-6)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
        .buttonStyle(.card)
        .focused($isFocused)
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
