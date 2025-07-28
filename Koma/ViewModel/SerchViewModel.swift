////
////  SerchViewModel.swift
////  Koma
////
////  Created by Antonio Hernández Barbadilla on 27/7/25.
////

import Foundation
import SwiftUI

@Observable
@MainActor
final class SearchViewModel {
    
    // MARK: - Dependencias
    let network: DataRepository
    
    // MARK: - Estado de búsqueda
    var searchResults: [Manga] = []
    var isLoading = false
    var errorMessage: String?
    
    var searchTitle: String = ""
    var selectedGenres: [String] = []
    var selectedThemes: [String] = []
    var selectedDemographics: [String] = []
    
    // MARK: - Inicializador
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
    
    // MARK: - Método básico para probar la búsqueda
    func testSearch() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        let query = CustomSearchDTO(
            searchTitle: "Naruto",
            searchAuthorFirstName: nil,
            searchAuthorLastName: nil,
            searchGenres: nil,
            searchThemes: nil,
            searchDemographics: nil,
            searchContains: true
        )
        
        do {
            let response = try await network.searchMangas(query: query, page: 1)
            searchResults = response.items
        } catch {
            errorMessage = "Error realizando la búsqueda: \(error.localizedDescription)"
        }
    }
}
