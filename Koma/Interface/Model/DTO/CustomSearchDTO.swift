//
//  CustomSearchDTO.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 28/7/25.
//

struct CustomSearchDTO: Codable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool
}
