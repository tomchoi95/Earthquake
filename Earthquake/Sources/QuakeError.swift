//
//  QuakeError.swift
//  Earthquake
//
//  Created by Tom Choi on 2/24/26.
//

import Foundation

enum QuakeError: Error {
    case missingData
    case networkError
}

extension QuakeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingData:
            return NSLocalizedString(
                "Found and will discard a quake missing a valid code, magnitude, place, or time.",
                comment: ""
            )
        case .networkError:
            return NSLocalizedString(
                "네트워크 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도하세요.",
                comment: ""
            )
        }
    }
}

