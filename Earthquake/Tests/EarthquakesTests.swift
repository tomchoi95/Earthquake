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
}
