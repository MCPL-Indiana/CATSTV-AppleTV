//
//  Channel.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import Foundation

struct Channel: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let streamURL: URL
    let iconName: String

    static let allChannels: [Channel] = [
        Channel(
            id: "city",
            name: "City Channel",
            subtitle: "Bloomington City Government",
            streamURL: URL(string: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/f8f183aa686dea8fded26ffa5475d3f5/source/index.m3u8")!,
            iconName: "building.columns"
        ),
        Channel(
            id: "county",
            name: "County Channel",
            subtitle: "Monroe County Government",
            streamURL: URL(string: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/717441a0f28e627c7d64f28827fd262f/source/index.m3u8")!,
            iconName: "map"
        ),
        Channel(
            id: "library",
            name: "Library Channel",
            subtitle: "Monroe County Public Library",
            streamURL: URL(string: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/cfa6d8a759fc6aedf7e8a04c4ad003e6/source/index.m3u8")!,
            iconName: "books.vertical"
        ),
        Channel(
            id: "special2",
            name: "Special 2",
            subtitle: "Special Programming",
            streamURL: URL(string: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/86d196fc-7e71-42df-c6f5-d1eafa67f0c1/index.m3u8")!,
            iconName: "star"
        )
    ]
}
