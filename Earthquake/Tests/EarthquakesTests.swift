//
//  EarthquakesTests.swift
//  EarthquakeTests
//
//  Created by Tom Choi on 2/24/26.
//

import Foundation
import Testing

@testable import Earthquake

struct EarthquakesTests {
    @Test
    func geoJSONDecoderDecodesQuake() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let quake = try decoder.decode(Quake.self, from: testFeature_nc73649170)
        #expect(quake.code == "73649170")

        let expectedSeconds = TimeInterval(1_636_129_710_550 / 1000.0)
        let expectedTime = Date(timeIntervalSince1970: expectedSeconds)
        #expect(quake.time == expectedTime)
    }

    @Test
    func geoJSONDecoderDecodesGeoJSON() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decoded = try decoder.decode(GeoJSON.self, from: testQuakesData)
        #expect(decoded.quakes.count == 6)
        #expect(decoded.quakes[0].code == "73649170")

        let expectedSeconds = TimeInterval(1_636_129_710_550 / 1000.0)
        let expectedTime = Date(timeIntervalSince1970: expectedSeconds)
        #expect(decoded.quakes[0].time == expectedTime)
    }

    @Test
    func quakeDetailDecoder() throws {
        let decoded = try JSONDecoder().decode(QuakeLocation.self, from: testDetail_hv72783692)
        #expect(decoded.latitude == 19.2189998626709)
    }

    @Test func clientDoesFetchEarthquakeData() async throws {
        let downloader = TestDownloader()
        let client = QuakeClient(downloader: downloader)
        let quakes = try await client.quakes
        #expect(quakes.count == 6)
    }
}
