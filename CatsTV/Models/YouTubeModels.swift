//
//  YouTubeModels.swift
//  CatsTV
//

import Foundation

struct YouTubeVideo: Identifiable, Hashable {
    let id: String          // YouTube video ID
    let title: String
    let thumbnailURL: URL?

    static func == (lhs: YouTubeVideo, rhs: YouTubeVideo) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
