//
//  CityMeetingVideo.swift
//  CatsTV
//
//  Model for a City Meeting video entry from the CATS JSON feed.
//  JSON source: https://3w.mcpl.info/catsjson/city.json
//  File storage: https://catstv.blob.core.windows.net/videoarchive/
//

import Foundation

struct CityMeetingVideo: Identifiable, Codable, Hashable {
    let title: String
    let m4vFile: String      // "data-m4v" field — e.g. "B_MPO_PC_260227.m4v"
    let vttFile: String      // "data-vtt" field — e.g. "B_MPO_PC_260227_subtitles.vtt"
    let thumbnailFile: String // "thumbnail" field — e.g. "B_MPO_PC_260227-0-thumbnail.jpg"

    var id: String { m4vFile }

    private enum CodingKeys: String, CodingKey {
        case title
        case m4vFile      = "data-m4v"
        case vttFile      = "data-vtt"
        case thumbnailFile = "thumbnail"
    }

    private static let baseURL = "https://catstv.blob.core.windows.net/videoarchive/"

    var videoURL: URL {
        URL(string: CityMeetingVideo.baseURL + m4vFile)!
    }
    var captionsURL: URL {
        URL(string: CityMeetingVideo.baseURL + vttFile)!
    }
    var thumbnailURL: URL {
        URL(string: CityMeetingVideo.baseURL + thumbnailFile)!
    }
}
