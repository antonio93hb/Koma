//
//  SearchDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 29/7/25.
//

import SwiftData
import Foundation

@Model
final class SearchDB {
    @Attribute(.unique) var id: UUID
    var query: String
    var genres: [String]
    var themes: [String]
    var demographics: [String]
    var createdAt: Date

    init(query: String,
         genres: [String] = [],
         themes: [String] = [],
         demographics: [String] = []) {
        self.id = UUID()
        self.query = query
        self.genres = genres
        self.themes = themes
        self.demographics = demographics
        self.createdAt = Date()
    }
}
