//
//  TestDownloader.swift
//  Earthquake
//
//  Created by Tom Choi on 2/25/26.
//

import Foundation

final class TestDownloader: HTTPDataDownloader {
    func httpData(from: URL) async throws -> Data {
        try await Task.sleep(for: .microseconds(.random(in: 100...500)))
        return testQuakesData
    }
}
