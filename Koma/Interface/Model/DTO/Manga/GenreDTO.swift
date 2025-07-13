import Foundation

struct GenreDTO: Codable {
    let id: String
    let genre: String
}

extension GenreDTO {
    var toGenre: Genre {
        Genre(id: id, genre: genre)
    }
}
