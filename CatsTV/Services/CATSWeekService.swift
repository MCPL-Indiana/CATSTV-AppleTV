//
//  CATSWeekService.swift
//  CatsTV
//
//  Fetches and decodes the CATSWeek JSON feed from MCPL.
//

import Foundation

actor CATSWeekService {
    static let shared = CATSWeekService()
    private init() {}

    private let feedURL = URL(string: "https://3w.mcpl.info/catsjson/catsweek.json")!
    private var cache: [CityMeetingVideo]?

    func fetchVideos() async throws -> [CityMeetingVideo] {
        if let cache { return cache }

        var request = URLRequest(url: feedURL, timeoutInterval: 20)
        request.setValue(
            "Mozilla/5.0 (AppleTV; CPU OS 18_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        let videos = try JSONDecoder().decode([CityMeetingVideo].self, from: data)
        cache = videos
        return videos
    }
}
