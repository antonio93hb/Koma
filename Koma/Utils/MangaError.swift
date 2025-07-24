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
            return String(localized: "No se pudieron cargar los mangas guardados.")
        case .invalidData:
            return String(localized: "Los datos proporcionados no son válidos.")
        case .custom(let message):
            return message
        case .unknown(let error):
            return String(localized: "Error desconocido: \(error.localizedDescription)")
        }
    }
}
