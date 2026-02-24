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
        let quake = try decoder.decode(Quake.self, from: testFeature_nc73649170)
        #expect(quake.code == "73649170")
    }
}
