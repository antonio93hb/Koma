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
        await fetchSearchResults(reset: reset)
    }
    
    // MARK: - Paginación
    func loadMoreIfNeeded(current manga: Manga) async {
        guard manga.id == searchResults.last?.id,
              hasMoreResults,
              !isLoading,
              !isFetchingMore else {
            print("AHB: ⛔ loadMoreIfNeeded cancelado - condición no cumplida")
            return
        }
        
        print("AHB ✅ loadMoreIfNeeded → solicitando página \(currentPage + 1)")
        isFetchingMore = true
        defer { isFetchingMore = false }
        
        await fetchSearchResults(reset: false)
    }
    
    // MARK: - Lógica central de búsqueda
    private func fetchSearchResults(reset: Bool = false) async {
        guard !isLoading else { return }
        //isLoading = true
        errorMessage = nil
        
        if reset {
            currentPage = 1
            searchResults.removeAll()
        } else {
            currentPage += 1
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
            
            print("AHB 🟢 JSON enviado: \(query), página: \(currentPage)")
            let response = try await network.searchMangas(query: query, page: currentPage)
            
            if currentPage == 1 {
                searchResults = response.items
            } else {
                searchResults += response.items
            }
            
            totalItems = response.metadata.total
            print("AHB ✅ Página \(currentPage) cargada. Acumulados: \(searchResults.count)/\(totalItems)")
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch let error as MangaError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
