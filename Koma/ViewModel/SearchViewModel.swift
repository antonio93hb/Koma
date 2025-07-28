////
////  SearchViewModel.swift
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
    
    // MARK: - Método para realizar la búsqueda real
    func performSearch(reset: Bool = true) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        if reset { searchResults = [] }
        
        let query = CustomSearchDTO(
            searchTitle: searchTitle.isEmpty ? nil : searchTitle,
            searchAuthorFirstName: nil,
            searchAuthorLastName: nil,
            searchGenres: selectedGenres.isEmpty ? nil : selectedGenres,
            searchThemes: selectedThemes.isEmpty ? nil : selectedThemes,
            searchDemographics: selectedDemographics.isEmpty ? nil : selectedDemographics,
            searchContains: true
        )
        
        do {
            let response = try await network.searchMangas(query: query, page: 1)
            searchResults = response.items
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch let error as MangaError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
    }
}
