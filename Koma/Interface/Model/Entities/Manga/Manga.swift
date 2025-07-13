import Foundation

struct Manga: Identifiable {

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
