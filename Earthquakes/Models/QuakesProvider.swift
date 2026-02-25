/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to fetch data from the remote server and save it to the Core Data store.
*/

import Foundation
import Observation

@Observable
class QuakesProvider {

    var quakes: [Quake] = []

    let client: QuakeClient

    func fetchQuakes() async throws {
        let latestQuakes = try await client.quakes
        self.quakes = latestQuakes
    }

    func deleteQuakes(atOffsets offsets: IndexSet) {
        quakes.remove(atOffsets: offsets)
    }

    init(client: QuakeClient = QuakeClient()) {
        self.client = client
    }
}

