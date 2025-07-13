//
//  MangaDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 28/6/25.
//


import Foundation
import SwiftData
import SwiftUI

@Model
final class MangaDB {
    @Attribute(.unique) var id: Int
    var title: String
    var titleEnglish: String?
    var titleJapanese: String?
    var imageURL: String
    var url: String
    var startDate: Date?
    var endDate: Date?
    var score: Double?
    var status: String
    var volumes: Int?
    var chapters: Int?
    var synopsis: String?
    var background: String?
    var authors: [AuthorDB]
    var genres: [GenreDB]
    var demographics: [DemographicDB]
    var themes: [ThemeDB]
    var isSaved = false
    
    init(id: Int, title: String, titleEnglish: String? = nil, titleJapanese: String? = nil, imageURL: String, url: String, startDate: Date? = nil, endDate: Date? = nil, score: Double? = nil, status: String, volumes: Int? = nil, chapters: Int? = nil, synopsis: String? = nil, background: String? = nil, authors: [AuthorDB], genres: [GenreDB], demographics: [DemographicDB], themes: [ThemeDB], isSaved: Bool = false) {
        self.id = id
        self.title = title
        self.titleEnglish = titleEnglish
        self.titleJapanese = titleJapanese
        self.imageURL = imageURL
        self.url = url
        self.startDate = startDate
        self.endDate = endDate
        self.score = score
        self.status = status
        self.volumes = volumes
        self.chapters = chapters
        self.synopsis = synopsis
        self.background = background
        self.authors = authors
        self.genres = genres
        self.demographics = demographics
        self.themes = themes
        self.isSaved = isSaved
    }
}

extension MangaDB {
    var toManga: Manga {
        Manga(
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
            authors: authors.map { $0.toAuthor },
            genres: genres.map { $0.toGenre },
            demographics: demographics.map { $0.toDemographic },
            themes: themes.map { $0.toTheme },
            isSaved: isSaved
        )
    }
}
