struct Genre: Identifiable, Hashable {
    let id: String
    let genre: String
}
extension Genre {
    func toGenreDB() -> GenreDB {
        GenreDB(id: id, genre: genre)
    }
}
