//
//  CacheEntryObject.swift
//  Earthquakes
//
//  Created by Tom Choi on 2/25/26.
//

import Foundation

final class CacheEntryObject {
    let entry: CacheEntry
    
    init(entry: CacheEntry) {
        self.entry = entry
    }
}

enum CacheEntry {
    case inProgress(Task<QuakeLocation, Error>)
    case ready(QuakeLocation)
}
