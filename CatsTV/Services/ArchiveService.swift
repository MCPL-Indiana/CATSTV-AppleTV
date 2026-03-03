//
//  ArchiveService.swift
//  CatsTV
//
//  Fetches and parses the CATS TV video archive from catstv.net.
//  Individual meeting pages live at https://catstv.net/m.php?q=<id>
//  Archive search at https://catstv.net/government.php?issearch=yes&...
//

import Foundation

actor ArchiveService {
    static let shared = ArchiveService()
    private init() {}

    // Simple in-memory cache keyed on search URL to avoid redundant requests.
    private var cache: [URL: [ArchiveVideo]] = [:]

    // Discovered meeterid values from the government.php form dropdown.
    // Populated once on first use, then reused for all subsequent requests.
    private var discoveredMeeterIDs: [ArchiveCategory: String]?

    // MARK: - Public API

    /// Fetches the video listing for a category, applying an optional text search and year filter.
    func fetchVideos(
        category: ArchiveCategory,
        query: String = "",
        year: Int? = nil
    ) async throws -> [ArchiveVideo] {
        let meeterid = try await resolvedMeeterid(for: category)
        let url = category.searchURL(meeterid: meeterid, query: query, year: year)

        if let cached = cache[url] { return cached }

        let html    = try await fetchHTML(from: url)
        let videos  = parseVideoList(html: html, category: category)
        cache[url]  = videos
        return videos
    }

    /// Fetches the individual meeting page (m.php?q=<id>) and attempts to extract
    /// a direct HLS / MP4 stream URL for AVPlayer.
    /// Returns nil only when no URL pattern is found; callers can fall back to
    /// showing an error or a link to the watch page.
    func resolveVideoURL(meetingID: String) async throws -> URL? {
        let pageURL = URL(string: "https://catstv.net/m.php?q=\(meetingID)")!
        let html    = try await fetchHTML(from: pageURL)

        if let url = extractVideoURL(from: html) { return url }

        // Secondary fallback: attempt direct file at /video/<id>.mp4
        return URL(string: "https://catstv.net/video/\(meetingID).mp4")
    }

    // MARK: - MeeterID Discovery

    /// Returns the best meeterid value for a category, discovering values from the
    /// government.php form dropdown on first call.
    private func resolvedMeeterid(for category: ArchiveCategory) async throws -> String {
        if let map = discoveredMeeterIDs, let id = map[category] {
            return id
        }

        // Discover meeterid values from the site's form
        let map = await discoverMeeterIDs()
        discoveredMeeterIDs = map

        return map[category] ?? "all"
    }

    /// Fetches the main government.php page and parses the meeterid <select> dropdown
    /// to discover the correct category values for City, County, and Community.
    private func discoverMeeterIDs() async -> [ArchiveCategory: String] {
        guard let url = URL(string: "https://catstv.net/government.php") else { return [:] }

        guard let html = try? await fetchHTML(from: url) else { return [:] }

        // Extract the <select> element that contains meeterid options.
        // The form may use name="meeterid" or similar.
        guard let selectRE = try? NSRegularExpression(
            pattern: #"<select[^>]*name\s*=\s*['"](meeterid|MeeterId|meeter_id)['"][^>]*>([\s\S]*?)</select>"#,
            options: .caseInsensitive
        ) else { return [:] }

        let ns = html as NSString
        guard let selectMatch = selectRE.firstMatch(
            in: html,
            range: NSRange(location: 0, length: ns.length)
        ), selectMatch.numberOfRanges >= 3,
              let contentRange = Range(selectMatch.range(at: 2), in: html) else {
            return [:]
        }

        let selectHTML = String(html[contentRange])

        // Extract all <option value="...">Label</option> pairs
        guard let optionRE = try? NSRegularExpression(
            pattern: #"<option[^>]*\bvalue\s*=\s*['"]([\w\-]+)['"][^>]*>\s*([^<]+?)\s*</option>"#,
            options: .caseInsensitive
        ) else { return [:] }

        let optNS = selectHTML as NSString
        var options: [(value: String, label: String)] = []

        for m in optionRE.matches(in: selectHTML, range: NSRange(location: 0, length: optNS.length)) {
            guard m.numberOfRanges >= 3,
                  let valR = Range(m.range(at: 1), in: selectHTML),
                  let labR = Range(m.range(at: 2), in: selectHTML) else { continue }
            let value = String(selectHTML[valR])
            let label = htmlDecode(
                String(selectHTML[labR]).trimmingCharacters(in: .whitespacesAndNewlines)
            )
            guard !value.isEmpty, !label.isEmpty else { continue }
            options.append((value, label))
        }

        return mapOptionsToCategories(options)
    }

    /// Maps discovered dropdown options to ArchiveCategory values.
    /// Prefers broad category-prefixed values (e.g., "category-M") over specific
    /// numeric board IDs (e.g., "117" for City Council).
    private func mapOptionsToCategories(
        _ options: [(value: String, label: String)]
    ) -> [ArchiveCategory: String] {
        var result: [ArchiveCategory: String] = [:]

        for category in ArchiveCategory.allCases {
            // First pass: look for broad category-prefixed values
            for (value, label) in options {
                guard value.hasPrefix("category-") else { continue }
                if matchesCategory(label: label, category: category) {
                    result[category] = value
                    break
                }
            }

            // Second pass: if no category-level match, try any option
            if result[category] == nil {
                for (value, label) in options {
                    if matchesCategory(label: label, category: category) {
                        result[category] = value
                        break
                    }
                }
            }
        }

        return result
    }

    /// Checks if a dropdown label matches a given ArchiveCategory based on keywords.
    private func matchesCategory(label: String, category: ArchiveCategory) -> Bool {
        let lower = label.lowercased()

        // Check exclude keywords first
        for kw in category.excludeKeywords {
            if lower.contains(kw) { return false }
        }

        // Check if any search keyword matches
        for kw in category.searchKeywords {
            if lower.contains(kw) { return true }
        }

        return false
    }

    // MARK: - Networking

    private func fetchHTML(from url: URL) async throws -> String {
        var req = URLRequest(url: url, timeoutInterval: 20)
        req.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        req.setValue(
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            forHTTPHeaderField: "Accept"
        )
        let (data, _) = try await URLSession.shared.data(for: req)
        return String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .isoLatin1)
            ?? ""
    }

    // MARK: - Parsing: archive listing page

    /// Scans the government.php HTML for anchor tags pointing to m.php?q=<id>
    /// and extracts title, date, and duration from the surrounding context.
    private func parseVideoList(html: String, category: ArchiveCategory) -> [ArchiveVideo] {
        // Match:  href="m.php?q=12345"  or  href='/m.php?q=12345'  (with optional leading /)
        guard let linkRE = try? NSRegularExpression(
            pattern: #"href=['"](/?)m\.php\?q=(\d+)[^'"]*['"][^>]*>\s*([^<]+?)\s*</a>"#,
            options: .caseInsensitive
        ) else { return [] }

        let durationRE = try? NSRegularExpression(pattern: #"\b(\d{1,2}:\d{2}:\d{2})\b"#)
        let dateRE     = try? NSRegularExpression(
            pattern: #"\b((?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-z]*,?\s+"# +
                     #"(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|"# +
                     #"Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|"# +
                     #"Nov(?:ember)?|Dec(?:ember)?)\s+\d{1,2}(?:,?\s+\d{4})?)\b"#,
            options: .caseInsensitive
        )

        let ns    = html as NSString
        var seen  = Set<String>()
        var out   = [ArchiveVideo]()

        for m in linkRE.matches(in: html, range: NSRange(location: 0, length: ns.length)) {
            guard m.numberOfRanges >= 4,
                  let idR    = Range(m.range(at: 2), in: html),
                  let titleR = Range(m.range(at: 3), in: html) else { continue }

            let mid   = String(html[idR])
            let title = htmlDecode(
                String(html[titleR]).trimmingCharacters(in: .whitespacesAndNewlines)
            )

            guard !mid.isEmpty, !title.isEmpty, !seen.contains(mid) else { continue }
            seen.insert(mid)

            // Look at ±300 chars around the link for date / duration metadata.
            let lo  = max(0, m.range.location - 200)
            let hi  = min(ns.length, NSMaxRange(m.range) + 300)
            let ctx = ns.substring(with: NSRange(location: lo, length: hi - lo))

            let date     = firstMatch(re: dateRE,     in: ctx, group: 1) ?? ""
            let duration = firstMatch(re: durationRE, in: ctx, group: 1) ?? ""

            out.append(ArchiveVideo(
                id:       mid,
                title:    title,
                date:     date,
                duration: duration,
                watchURL: URL(string: "https://catstv.net/m.php?q=\(mid)")!,
                category: category
            ))
        }
        return out
    }

    // MARK: - Parsing: individual meeting page

    /// Tries a series of regex patterns to locate the video stream URL embedded
    /// in the m.php watch page (HTML5 <source>, VideoJS config, bare mp4/m3u8, etc.)
    private func extractVideoURL(from html: String) -> URL? {
        let patterns: [(String, Int)] = [
            // HTML5 <source src="...">
            (#"<source[^>]+\bsrc=['"](https?://[^'"]+\.(?:mp4|m3u8|mov))['"]\s*/?>"#, 1),
            // JavaScript:  src: 'https://...'
            (#"\bsrc\s*:\s*['"](https?://[^'"]+\.(?:mp4|m3u8))['"]\s*"#, 1),
            // JavaScript:  file: 'https://...'
            (#"\bfile\s*:\s*['"](https?://[^'"]+\.(?:mp4|m3u8))['"]\s*"#, 1),
            // Direct catstv.net/video/ path
            (#"(https?://catstv\.net/video/[^\s'"<>)]+\.(?:mp4|m3u8))"#, 1),
            // Any .mp4 or .m3u8 URL
            (#"(https?://[^\s'"<>)]+\.(?:mp4|m3u8))(?:[^\w]|$)"#, 1),
        ]

        for (pattern, group) in patterns {
            if let re  = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let m   = re.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               m.numberOfRanges > group,
               let r   = Range(m.range(at: group), in: html),
               let url = URL(string: String(html[r])) {
                return url
            }
        }
        return nil
    }

    // MARK: - Helpers

    private func firstMatch(re: NSRegularExpression?, in text: String, group: Int) -> String? {
        guard let re,
              let m = re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              m.numberOfRanges > group,
              let r = Range(m.range(at: group), in: text) else { return nil }
        return String(text[r])
    }

    private func htmlDecode(_ s: String) -> String {
        s.replacingOccurrences(of: "&amp;",  with: "&")
         .replacingOccurrences(of: "&lt;",   with: "<")
         .replacingOccurrences(of: "&gt;",   with: ">")
         .replacingOccurrences(of: "&quot;", with: "\"")
         .replacingOccurrences(of: "&#39;",  with: "'")
         .replacingOccurrences(of: "&nbsp;", with: " ")
    }
}
