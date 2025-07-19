//
//  ThemeDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 2/7/25.
//

import SwiftData

@Model
final class ThemeDB {
    var id: String
    var name: String
    
    // 🔁 Relación inversa con MangaDB
    @Relationship(inverse: \MangaDB.themes)
    var mangas: [MangaDB] = []

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension ThemeDB {
    var toTheme: Theme {
        Theme(
            id: id,
            name: name
        )
    }
}
