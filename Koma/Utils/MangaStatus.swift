//
//  MangaStatus.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//
import SwiftUI

enum MangaStatus: String {
    case finished = "finished"
    case currentlyPublishing = "currently_publishing"
    case onHiatus = "on_hiatus"
    case unknown = "unknown" // Para cualquier otro valor no previsto

    init(from rawValue: String?) {
        guard let raw = rawValue?.lowercased() else {
            self = .unknown
            return
        }
        self = MangaStatus(rawValue: raw) ?? .unknown
    }
    
    /// Texto amigable para la UI
    var text: String {
        switch self {
        case .finished:
            return String(localized: "status_finished")
        case .currentlyPublishing:
            return String(localized: "status_currently_publishing")
        case .onHiatus:
            return String(localized: "status_on_hiatus")
        case .unknown:
            return String(localized: "status_unknown")
        }
    }

    /// Color asociado al estado
    var color: Color {
        switch self {
        case .finished: return .red
        case .currentlyPublishing: return .green
        case .onHiatus: return .orange
        case .unknown: return .secondary
        }
    }
}
