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
    
    private var currentPage = 1
    private var totalItems = 0
    
    var hasMoreResults: Bool { searchResults.count < totalItems }
    
    // MARK: - Inicializador
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
    
    // MARK: - Método para realizar la búsqueda real
    func performSearch(reset: Bool = true) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        if reset {
            currentPage = 1
            searchResults = []
        }
        
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
            let response = try await network.searchMangas(query: query, page: currentPage)
            if reset {
                searchResults = response.items
            } else {
                searchResults += response.items
            }
            totalItems = response.metadata.total
            if hasMoreResults {
                currentPage += 1
            }
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch let error as MangaError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
    }
    
    func loadMoreIfNeeded(current manga: Manga) async {
        guard let index = searchResults.firstIndex(where: { $0.id == manga.id }) else { return }
        let thresholdIndex = searchResults.index(searchResults.endIndex, offsetBy: -5, limitedBy: searchResults.startIndex) ?? searchResults.startIndex
        guard index >= thresholdIndex, hasMoreResults, !isLoading else { return }
        await performSearch(reset: false)
    }
}
