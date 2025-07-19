//
//  DemographicDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 2/7/25.
//
import SwiftData

@Model
final class DemographicDB {
    var id: String
    var name: String
    
    // 🔁 Relación inversa con MangaDB
    @Relationship(inverse: \MangaDB.demographics)
    var mangas: [MangaDB] = []
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension DemographicDB {
    var toDemographic: Demographic {
        Demographic(
            id: id,
            name: name
        )
    }
}
