//
//  Extensions.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 11/8/25.
//

import Foundation

/// Normaliza strings para comparaciones: quita tildes, espacios sobrantes y hace lowercased.
extension String {
    func normalized() -> String {
        self
            .folding(options: .diacriticInsensitive, locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
