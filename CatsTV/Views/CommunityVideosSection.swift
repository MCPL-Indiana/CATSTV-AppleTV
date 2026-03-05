//
//  CommunityVideosSection.swift
//  CatsTV
//
//  Horizontal scrolling section that loads Community Videos from the CATS
//  JSON feed and lets users browse and play them.
//

import SwiftUI

struct CommunityVideosSection: View {
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
                Image(systemName: "person.3.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(CATSTheme.accentCoral)
                Text("COMMUNITY VIDEOS")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(CATSTheme.textPrimary)
            }
            .padding(.horizontal, 60)

            // Content
            if isLoading {
                HStack(spacing: 12) {
                    ProgressView().tint(CATSTheme.accentCoral)
                    Text("Loading videos…")
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
            videos = try await CommunityVideosService.shared.fetchVideos()
        } catch {
            errorMessage = "Could not load videos. Please check your network connection."
        }
        isLoading = false
    }
}
