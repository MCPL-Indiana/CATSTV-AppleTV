//
//  CityMeetingsSection.swift
//  CatsTV
//
//  Horizontal scrolling section that loads City Meeting videos from the CATS
//  JSON feed and lets users browse and play them.
//
//  Focus approach mirrors ContentView/ChannelCardView:
//    • CityMeetingCardView is a pure rendering View (no Button, no FocusState)
//    • CityMeetingsSection owns @FocusState and wraps each card in a Button
//      with CardButtonStyle, which suppresses tvOS's built-in focus halo
//    • All focus visuals (coral glow shadow, scale, border) live inside
//      CityMeetingCardView, driven by the isFocused Bool prop
//

import SwiftUI

// MARK: - Section container

struct CityMeetingsSection: View {
    @State private var videos: [CityMeetingVideo] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedVideo: CityMeetingVideo?
    @State private var isPlaying = false
    @FocusState private var focusedID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 10) {
                Image(systemName: "building.columns")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(CATSTheme.accentCoral)
                Text("CITY MEETINGS")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(CATSTheme.textPrimary)
            }
            .padding(.horizontal, 60)

            // Content
            if isLoading {
                HStack(spacing: 12) {
                    ProgressView().tint(CATSTheme.accentCoral)
                    Text("Loading meetings…")
                        .font(.system(size: 18))
                        .foregroundStyle(CATSTheme.textSecondary)
                }
                .padding(.horizontal, 60)
                .frame(height: 240)

            } else if let err = errorMessage {
                Text(err)
                    .font(.system(size: 18))
                    .foregroundStyle(CATSTheme.textSecondary)
                    .padding(.horizontal, 60)
                    .frame(height: 240)

            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(videos) { video in
                            let isFocused = focusedID == video.id

                            Button {
                                selectedVideo = video
                                isPlaying = true
                            } label: {
                                CityMeetingCardView(video: video, isFocused: isFocused)
                            }
                            .buttonStyle(CardButtonStyle())
                            .focused($focusedID, equals: video.id)
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.vertical, 8)
                }
            }
        }
        .task { await load() }
        .fullScreenCover(isPresented: $isPlaying) {
            if let video = selectedVideo {
                CityMeetingPlayerView(video: video)
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            videos = try await CityMeetingsService.shared.fetchVideos()
        } catch {
            errorMessage = "Could not load meetings. Please check your network connection."
        }
        isLoading = false
    }
}

// MARK: - Pure card view (no Button, no FocusState — mirrors ChannelCardView)

struct CityMeetingCardView: View {
    let video: CityMeetingVideo
    let isFocused: Bool

    private let cardWidth: CGFloat = 320
    private let thumbnailHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            AsyncImage(url: video.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    ZStack {
                        CATSTheme.backgroundMedium
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundStyle(CATSTheme.textMuted)
                    }
                @unknown default:
                    CATSTheme.backgroundMedium
                }
            }
            .frame(width: cardWidth, height: thumbnailHeight)
            .clipped()

            // Title
            Text(video.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(
                    isFocused ? CATSTheme.accentCoral : CATSTheme.textPrimary
                )
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(width: cardWidth, alignment: .leading)
                .background(
                    isFocused
                        ? CATSTheme.backgroundDark.opacity(0.95)
                        : CATSTheme.backgroundMedium.opacity(0.6)
                )
        }
        .frame(width: cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isFocused ? CATSTheme.accentCoral : Color.clear,
                    lineWidth: 3
                )
        )
        .scaleEffect(isFocused ? 1.08 : 1.0)
        .shadow(
            color: isFocused ? CATSTheme.accentCoral.opacity(0.4) : .black.opacity(0.3),
            radius: isFocused ? 20 : 8,
            y: isFocused ? 8 : 4
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
