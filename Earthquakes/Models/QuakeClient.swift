/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A class to fetch and cache data from the remote server.
 */

import Foundation

struct QuakeClient {
    private let quakeCache: NSCache<NSString, CacheEntryObject> = NSCache()

    private var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    /// Geological data provided by the U.S. Geological Survey (USGS). See ACKNOWLEDGMENTS.txt for additional details.
    private let feedURL = URL(
        string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    )!

    private let downloader: any HTTPDataDownloader

    var quakes: [Quake] {
        get async throws {
            let data = try await downloader.httpData(from: feedURL)
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)
            return allQuakes.quakes
        }
    }

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
}
