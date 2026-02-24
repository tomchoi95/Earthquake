//
//  QuakeClient.swift
//  Earthquake
//
//  Created by Tom Choi on 2/24/26.
//

import Foundation

struct QuakeClient {
    var quakes: [Quake] {
        get async throws {
            let data = try await downloader.httpData(from: feedURL)
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)
            return allQuakes.quakes
        }
    }

    private var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    private let feedURL = URL(
        string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    )!

    private let downloader: any HTTPDataDownloader

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
}
