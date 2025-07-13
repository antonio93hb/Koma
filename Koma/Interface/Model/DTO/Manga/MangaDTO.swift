import Foundation

struct MangaDTO: Codable {
    let id: Int
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let mainPicture: String
    let url: String
    let startDate: String?
    let endDate: String?
    let score: Double?
    let status: String
    let volumes: Int?
    let chapters: Int?
    let synopsis: String?
    let background: String?
    let authors: [AuthorDTO]
    let genres: [GenreDTO]
    let demographics: [DemographicDTO]
    let themes: [ThemeDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, titleEnglish, titleJapanese, mainPicture, url, startDate, endDate, score, status, volumes, chapters, background, authors, genres, demographics, themes
        case synopsis = "sypnosis" // corregido aquí synopsis por sypnosis
    }
}
// MARK: - Mapping

extension MangaDTO {
    var toManga: Manga {
        Manga(
            id: id,
            title: title,
            titleEnglish: titleEnglish,
            titleJapanese: titleJapanese,
            imageURL: mainPicture.trimmingCharacters(in: .init(charactersIn: "\"")),
            url: url.trimmingCharacters(in: .init(charactersIn: "\"")),
            startDate: Self.dateFormatter.date(from: startDate ?? ""),
            endDate: Self.dateFormatter.date(from: endDate ?? ""),
            score: score,
            status: status,
            volumes: volumes,
            chapters: chapters,
            synopsis: synopsis,
            background: background,
            authors: authors.map { $0.toAuthor },
            genres: genres.map { $0.toGenre },
            demographics: demographics.map { $0.toDemographic },
            themes: themes.map { $0.toTheme }
        )
    }
    private static let dateFormatter = ISO8601DateFormatter()
}
