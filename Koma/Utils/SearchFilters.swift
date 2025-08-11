//
//  SearchFilters.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 11/8/25.
//

import Foundation

struct SearchFilters: Equatable {
    var title: String = ""
    var genres: [String] = []
    var themes: [String] = []
    var demographics: [String] = []

    var isEmpty: Bool {
        title.isEmpty && genres.isEmpty && themes.isEmpty && demographics.isEmpty
    }

    func toDTO() -> CustomSearchDTO {
        CustomSearchDTO(
            searchTitle: title.isEmpty ? nil : title,
            searchAuthorFirstName: nil,
            searchAuthorLastName: nil,
            searchGenres: genres.isEmpty ? nil : genres,
            searchThemes: themes.isEmpty ? nil : themes,
            searchDemographics: demographics.isEmpty ? nil : demographics,
            searchContains: true
        )
    }
}
