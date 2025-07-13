//
//  GenreDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 2/7/25.
//

import SwiftData

@Model
final class GenreDB {
    var id: String
    var genre: String

    init(id: String, genre: String) {
        self.id = id
        self.genre = genre
    }
}

extension GenreDB {
    var toGenre: Genre {
        Genre(
            id: id,
            genre: genre
        )
    }
}
