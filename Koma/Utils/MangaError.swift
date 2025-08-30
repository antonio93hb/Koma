//
//  MangaError.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 9/7/25.
//

import Foundation

enum MangaError: LocalizedError {
    case loadFromPersistence
    case invalidData
    case custom(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .loadFromPersistence:
            return String(localized: "load_persistence_error")
        case .invalidData:
            return String(localized: "invalid_data_error")
        case .custom(let message):
            return message
        case .unknown(let error):
            return String(localized: "unknown_error: \(error.localizedDescription)")
        }
    }
}
