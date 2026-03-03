//
//  YouTubeService.swift
//  CatsTV
//
//  Fetches playlist items from the YouTube Data API v3.
//

import Foundation

actor YouTubeService {
    static let shared = YouTubeService()
    private init() {}

    private let apiKey = "AIzaSyBA8_s9sYz4iwoQPKg3EGAIxwIBMJaRlwE"
    private var cache: [String: [YouTubeVideo]] = [:]

    /// Fetches all videos from a YouTube playlist.
    func fetchPlaylist(id playlistID: String) async throws -> [YouTubeVideo] {
        if let cached = cache[playlistID] { return cached }

        var videos: [YouTubeVideo] = []
        var nextPageToken: String?

        repeat {
            var comps = URLComponents(string: "https://www.googleapis.com/youtube/v3/playlistItems")!
            var items: [URLQueryItem] = [
                .init(name: "part", value: "snippet"),
                .init(name: "playlistId", value: playlistID),
                .init(name: "maxResults", value: "50"),
                .init(name: "key", value: apiKey),
            ]
            if let token = nextPageToken {
                items.append(.init(name: "pageToken", value: token))
            }
            comps.queryItems = items

            let (data, _) = try await URLSession.shared.data(from: comps.url!)
            let response = try JSONDecoder().decode(PlaylistResponse.self, from: data)

            for item in response.items {
                let snippet = item.snippet
                guard let videoID = snippet.resourceId.videoId else { continue }

                let thumb = snippet.thumbnails.high?.url
                    ?? snippet.thumbnails.medium?.url
                    ?? snippet.thumbnails.default?.url

                videos.append(YouTubeVideo(
                    id: videoID,
                    title: snippet.title,
                    thumbnailURL: thumb.flatMap { URL(string: $0) }
                ))
            }

            nextPageToken = response.nextPageToken
        } while nextPageToken != nil

        cache[playlistID] = videos
        return videos
    }
}

// MARK: - API Response Models

private struct PlaylistResponse: Decodable {
    let items: [PlaylistItem]
    let nextPageToken: String?
}

private struct PlaylistItem: Decodable {
    let snippet: Snippet
}

private struct Snippet: Decodable {
    let title: String
    let thumbnails: Thumbnails
    let resourceId: ResourceId
}

private struct Thumbnails: Decodable {
    let `default`: Thumbnail?
    let medium: Thumbnail?
    let high: Thumbnail?
}

private struct Thumbnail: Decodable {
    let url: String
}

private struct ResourceId: Decodable {
    let videoId: String?
}
