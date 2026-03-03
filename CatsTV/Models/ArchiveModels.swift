//
//  ArchiveModels.swift
//  CatsTV
//

import Foundation

// MARK: - ArchiveVideo

struct ArchiveVideo: Identifiable, Hashable {
    let id: String          // Meeting ID from m.php?q=<id>
    let title: String
    let date: String
    let duration: String
    let watchURL: URL       // https://catstv.net/m.php?q=<id>
    let category: ArchiveCategory

    static func == (lhs: ArchiveVideo, rhs: ArchiveVideo) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - ArchiveCategory

enum ArchiveCategory: String, CaseIterable, Identifiable {
    case cityBloomington = "City of Bloomington"
    case monroeCounty    = "Monroe County"
    case community       = "Community Videos"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .cityBloomington: return "building.columns"
        case .monroeCounty:    return "map"
        case .community:       return "play.tv"
        }
    }

    /// Keywords used to match this category against dropdown labels on government.php.
    var searchKeywords: [String] {
        switch self {
        case .cityBloomington: return ["city", "bloomington"]
        case .monroeCounty:    return ["county", "monroe"]
        case .community:       return ["community", "public access"]
        }
    }

    /// Keywords that should disqualify a label from matching this category.
    var excludeKeywords: [String] {
        switch self {
        case .cityBloomington: return ["county"]
        case .monroeCounty:    return []
        case .community:       return []
        }
    }

    /// Builds the government.php search URL for this category.
    /// - Parameters:
    ///   - meeterid: The meeterid value to use (discovered or fallback).
    ///   - query: Free-text search (maps to `webquery`).
    ///   - year:  Specific year to filter, or nil for the rolling last-12-months window.
    func searchURL(meeterid: String, query: String, year: Int?) -> URL {
        var comps = URLComponents(string: "https://catstv.net/government.php")!
        let cal  = Calendar.current
        let now  = Date()
        let curY = cal.component(.year,  from: now)
        let curM = cal.component(.month, from: now)

        let (minY, minM, maxY, maxM): (Int, Int, Int, Int) = year.map { y in
            (y, 1, y, 12)
        } ?? (curY - 1, curM, curY, curM)

        comps.queryItems = [
            .init(name: "issearch", value: "yes"),
            .init(name: "webquery", value: query),
            .init(name: "minyear",  value: "\(minY)"),
            .init(name: "minmonth", value: String(format: "%02d", minM)),
            .init(name: "maxyear",  value: "\(maxY)"),
            .init(name: "maxmonth", value: String(format: "%02d", maxM)),
            .init(name: "meeterid", value: meeterid),
        ]
        return comps.url!
    }
}
