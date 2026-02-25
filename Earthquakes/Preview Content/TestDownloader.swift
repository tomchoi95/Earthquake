/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A test class to fake a network connection.
*/

import Foundation

final class TestDownloader: HTTPDataDownloader {
    func httpData(from url: URL) async throws -> Data {
        try await Task.sleep(for: .milliseconds(.random(in: 100...500)))
        return testQuakesData
    }
}
