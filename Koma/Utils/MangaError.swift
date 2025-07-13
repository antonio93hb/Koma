//
//  MangaError.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 9/7/25.
//

import Foundation

enum MangaError: LocalizedError {
    case loadFromPersistence
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .loadFromPersistence:
            return String(localized: "No se pudieron cargar los mangas guardados.")
        case .unknown(let error):
            return String(localized: "Error desconocido: \(error.localizedDescription)")
        }
    }
}
