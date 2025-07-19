import Foundation
import SwiftData

struct Manga: Identifiable, Hashable {

    let id: Int
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let imageURL: String
    let url: String
    let startDate: Date?
    let endDate: Date?
    let score: Double?
    let status: String
    let volumes: Int?
    let chapters: Int?
    let synopsis: String?
    let background: String?
    let authors: [Author]
    let genres: [Genre]
    let demographics: [Demographic]
    let themes: [Theme]
    var isSaved = false
}

extension Manga: Equatable {
    static func == (lhs: Manga, rhs: Manga) -> Bool {
        lhs.id == rhs.id
    }
}

extension Manga {
    func toMangaDB() -> MangaDB {
        MangaDB(
            id: id,
            title: title,
            titleEnglish: titleEnglish,
            titleJapanese: titleJapanese,
            imageURL: imageURL,
            url: url,
            startDate: startDate,
            endDate: endDate,
            score: score,
            status: status,
            volumes: volumes,
            chapters: chapters,
            synopsis: synopsis,
            background: background,
            authors: authors.map { $0.toAuthorDB() },
            genres: genres.map { $0.toGenreDB() },
            demographics: demographics.map { $0.toDemographicDB() },
            themes: themes.map { $0.toThemeDB() },
            isSaved: true
        )
    }
}
