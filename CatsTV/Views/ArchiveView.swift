//
//  ArchiveView.swift
//  CatsTV
//
//  Main archive browser — three categories, full-text search, and year filter.
//

import SwiftUI

// MARK: - ArchiveView

struct ArchiveView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: ArchiveCategory = .cityBloomington
    @State private var searchText: String  = ""
    @State private var selectedYear: Int?  = nil
    @State private var videos: [ArchiveVideo] = []
    @State private var isLoading   = false
    @State private var errorMsg: String? = nil
    @State private var selectedVideo: ArchiveVideo? = nil

    @FocusState private var searchFocused: Bool

    private var availableYears: [Int] {
        let cur = Calendar.current.component(.year, from: Date())
        return Array((cur - 5 ... cur).reversed())
    }

    // Unique string that changes whenever the user changes a filter;
    // SwiftUI cancels the previous .task and launches a new one automatically.
    private var taskID: String {
        "\(selectedCategory.id)|\(selectedYear ?? 0)|\(searchText)"
    }

    var body: some View {
        ZStack {
            CATSTheme.appBackgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                categoryTabs.padding(.top, 28)
                searchFilterBar.padding(.top, 20).padding(.horizontal, 80)
                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.top, 16)
                content
            }
        }
        .fullScreenCover(item: $selectedVideo) { video in
            ArchiveVideoPlayerView(video: video)
        }
        // Reload whenever category, year, or search text changes.
        // The 400 ms sleep gives a lightweight debounce for typing.
        .task(id: taskID) {
            if !searchText.isEmpty {
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard !Task.isCancelled else { return }
            }
            await loadVideos()
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center, spacing: 24) {
            CATSLogoView(height: 48)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("VIDEO ARCHIVE")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(CATSTheme.textPrimary)
                Text("Browse and search CATS TV programming")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(CATSTheme.textSecondary)
            }
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 18)
        .background(Rectangle().fill(CATSTheme.backgroundDark.opacity(0.6)))
    }

    // MARK: - Category tabs

    private var categoryTabs: some View {
        HStack(spacing: 20) {
            ForEach(ArchiveCategory.allCases) { cat in
                CategoryTabButton(
                    category: cat,
                    isActive: selectedCategory == cat
                ) {
                    guard selectedCategory != cat else { return }
                    selectedCategory = cat
                    videos = []
                }
            }
        }
        .padding(.horizontal, 80)
    }

    // MARK: - Search / year filter bar

    private var searchFilterBar: some View {
        HStack(spacing: 14) {
            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundStyle(CATSTheme.textSecondary)

                TextField("Search meetings and programs…", text: $searchText)
                    .font(.system(size: 18))
                    .foregroundStyle(CATSTheme.textPrimary)
                    .focused($searchFocused)
                    .onSubmit { Task { await loadVideos() } }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(CATSTheme.textMuted)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(CATSTheme.backgroundDark.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        searchFocused
                            ? CATSTheme.accentCoral.opacity(0.6)
                            : Color.white.opacity(0.08),
                        lineWidth: 2
                    )
            )

            // Year buttons
            HStack(spacing: 6) {
                yearButton(label: "All", year: nil)
                ForEach(availableYears.prefix(5), id: \.self) { yr in
                    yearButton(label: "\(yr)", year: yr)
                }
            }
        }
    }

    private func yearButton(label: String, year: Int?) -> some View {
        let active = selectedYear == year
        return Button {
            selectedYear = year
        } label: {
            Text(label)
                .font(.system(size: 15, weight: active ? .bold : .regular))
                .foregroundStyle(active ? .white : CATSTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(active ? CATSTheme.accentCoral : CATSTheme.backgroundDark.opacity(0.7))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Content area

    @ViewBuilder
    private var content: some View {
        if isLoading {
            Spacer()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.6)
                    .tint(CATSTheme.accentCoral)
                Text("Loading \(selectedCategory.rawValue) archive…")
                    .font(.system(size: 20))
                    .foregroundStyle(CATSTheme.textSecondary)
            }
            Spacer()
        } else if let err = errorMsg {
            Spacer()
            VStack(spacing: 18) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 52))
                    .foregroundStyle(CATSTheme.accentCoral)
                Text(err)
                    .font(.system(size: 20))
                    .foregroundStyle(CATSTheme.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Try Again") { Task { await loadVideos() } }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(CATSTheme.accentCoral))
            }
            Spacer()
        } else if videos.isEmpty && !isLoading {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "tv.slash")
                    .font(.system(size: 52))
                    .foregroundStyle(CATSTheme.textMuted)
                Text("No videos found")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(CATSTheme.textSecondary)
                if !searchText.isEmpty {
                    Text("Try different search terms or adjust the year filter.")
                        .font(.system(size: 18))
                        .foregroundStyle(CATSTheme.textMuted)
                }
            }
            Spacer()
        } else {
            videoList
        }
    }

    private var videoList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 6) {
                // Result count header
                HStack {
                    Text("\(videos.count) video\(videos.count == 1 ? "" : "s")")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CATSTheme.textMuted)
                    Spacer()
                }
                .padding(.horizontal, 80)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ForEach(videos) { video in
                    ArchiveVideoRowView(video: video) {
                        selectedVideo = video
                    }
                    .padding(.horizontal, 80)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    // MARK: - Data loading

    private func loadVideos() async {
        isLoading = true
        errorMsg  = nil
        do {
            videos = try await ArchiveService.shared.fetchVideos(
                category: selectedCategory,
                query:    searchText,
                year:     selectedYear
            )
        } catch {
            errorMsg = "Unable to load the archive.\nPlease check your network connection."
            videos   = []
        }
        isLoading = false
    }
}

// MARK: - CategoryTabButton

struct CategoryTabButton: View {
    let category: ArchiveCategory
    let isActive: Bool
    let action: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.system(size: 17, weight: .medium))
                Text(category.rawValue)
                    .font(.system(size: 18, weight: (isActive || isFocused) ? .bold : .medium))
            }
            .foregroundStyle(isActive ? CATSTheme.accentCoral
                             : isFocused ? .white
                             : CATSTheme.textSecondary)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? CATSTheme.backgroundDark.opacity(0.85)
                          : isFocused ? CATSTheme.backgroundMedium.opacity(0.6)
                          : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isActive ? CATSTheme.accentCoral.opacity(0.55)
                        : isFocused ? CATSTheme.textSecondary.opacity(0.4)
                        : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
        .buttonStyle(.card)
        .focused($isFocused)
    }
}

// MARK: - ArchiveVideoRowView

struct ArchiveVideoRowView: View {
    let video: ArchiveVideo
    let onSelect: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 20) {
                // Play icon circle
                ZStack {
                    Circle()
                        .fill(isFocused
                              ? CATSTheme.accentCoral
                              : CATSTheme.backgroundMedium.opacity(0.5))
                        .frame(width: 56, height: 56)
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isFocused ? .white : CATSTheme.textSecondary)
                }

                // Metadata
                VStack(alignment: .leading, spacing: 5) {
                    Text(video.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(CATSTheme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 18) {
                        if !video.date.isEmpty {
                            Label(video.date, systemImage: "calendar")
                                .font(.system(size: 15))
                                .foregroundStyle(CATSTheme.textSecondary)
                        }
                        if !video.duration.isEmpty {
                            Label(video.duration, systemImage: "clock")
                                .font(.system(size: 15))
                                .foregroundStyle(CATSTheme.textSecondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundStyle(isFocused ? CATSTheme.accentCoral : CATSTheme.textMuted)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFocused
                          ? CATSTheme.backgroundDark.opacity(0.95)
                          : CATSTheme.backgroundMedium.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isFocused ? CATSTheme.accentCoral.opacity(0.65) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isFocused ? 1.015 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
    }
}

#Preview {
    ArchiveView()
}
