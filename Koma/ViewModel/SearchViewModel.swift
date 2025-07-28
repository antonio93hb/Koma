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
    
    // Indica si se ha realizado al menos una búsqueda
    public var hasSearched: Bool = false
    
    // MARK: - Dependencias
    let network: DataRepository
    
    // MARK: - Estado de búsqueda
    var searchResults: [Manga] = []
    var isLoading = false
    var errorMessage: String?
    
    private var isFetchingMore = false
    
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
        hasSearched = true
        await fetchSearchResults(reset: reset)
    }
    
    // MARK: - Paginación
    func loadMoreIfNeeded(current manga: Manga) async {
        guard manga.id == searchResults.last?.id,
              hasMoreResults,
              !isLoading,
              !isFetchingMore else {
            return
        }
        
        isFetchingMore = true
        defer { isFetchingMore = false }
        
        await fetchSearchResults(reset: false)
    }
    
    // MARK: - Lógica central de búsqueda
    private func fetchSearchResults(reset: Bool = false) async {
        if reset {
            isLoading = true
            errorMessage = nil
            currentPage = 1
            searchResults.removeAll()
        } else {
            isFetchingMore = true
            errorMessage = nil
        }
        
        defer {
            if reset {
                isLoading = false
            } else {
                isFetchingMore = false
            }
        }
        
        do {
            let query = CustomSearchDTO(
                searchTitle: searchTitle.isEmpty ? nil : searchTitle,
                searchAuthorFirstName: nil,
                searchAuthorLastName: nil,
                searchGenres: selectedGenres.isEmpty ? nil : selectedGenres,
                searchThemes: selectedThemes.isEmpty ? nil : selectedThemes,
                searchDemographics: selectedDemographics.isEmpty ? nil : selectedDemographics,
                searchContains: true
            )
            
            let response = try await network.searchMangas(query: query, page: currentPage)
            
            if reset {
                searchResults = response.items
            } else {
                searchResults += response.items
            }
            
            totalItems = response.metadata.total
            
            if !reset {
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
}
