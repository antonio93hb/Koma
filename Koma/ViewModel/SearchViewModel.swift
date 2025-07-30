////
////  SearchViewModel.swift
////  Koma
////
////  Created by Antonio Hernández Barbadilla on 27/7/25.
////

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class SearchViewModel {
    
    // Indica si se ha realizado al menos una búsqueda
    public var hasSearched: Bool = false
    
    // MARK: - Dependencias
    let network: DataRepository
    var context: ModelContext?
    
    // MARK: - Estado de búsqueda
    var searchResults: [Manga] = []
    var searchHistory: [SearchDB] = []
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
    
    // Propiedad calculada para saber si hay filtros válidos
    var hasValidFilters: Bool {
        !searchTitle.isEmpty ||
        !selectedGenres.isEmpty ||
        !selectedThemes.isEmpty ||
        !selectedDemographics.isEmpty
    }
    
    // MARK: - Inicializador
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
    
    // MARK: - Búsqueda
    func performSearch(reset: Bool = true) async {
        hasSearched = true
        await fetchSearchResults(reset: reset)
        await saveSearch()
    }
    
    // Limpiar búsqueda y filtros
    func clearSearch() {
        searchResults.removeAll()
        hasSearched = false
        searchTitle = ""
        selectedGenres.removeAll()
        selectedThemes.removeAll()
        selectedDemographics.removeAll()
    }

    // Buscar si hay filtros válidos, limpiar si no
    func searchIfNeeded(reset: Bool = true) async {
        if hasValidFilters {
            await performSearch(reset: reset)
        } else {
            clearSearch()
        }
    }

    // Actualizar filtros y buscar si corresponde
    func updateFilters(genres: [String]? = nil, themes: [String]? = nil, demographics: [String]? = nil) async {
        if let genres = genres {
            selectedGenres = genres
        }
        if let themes = themes {
            selectedThemes = themes
        }
        if let demographics = demographics {
            selectedDemographics = demographics
        }
        await searchIfNeeded(reset: true)
    }
    
    // MARK: - Guardar búsqueda en SwiftData
    func saveSearch() async {
        guard let context = context else {
            print("AHB: ❌ No hay contexto disponible para guardar la búsqueda")
            return
        }

        print("AHB: ℹ️ Se va a guardar la búsqueda con query: '\(searchTitle)', géneros: \(selectedGenres), temas: \(selectedThemes), demografía: \(selectedDemographics)")

        let newSearch = SearchDB(
            query: searchTitle,
            genres: selectedGenres,
            themes: selectedThemes,
            demographics: selectedDemographics
        )

        context.insert(newSearch)
        print("AHB: ℹ️ Búsqueda insertada en el contexto")

        do {
            try context.save()
            print("AHB: ✅ Búsqueda guardada: \(searchTitle), Géneros: \(selectedGenres), Temas: \(selectedThemes), Demografía: \(selectedDemographics)")
            print("AHB: ℹ️ Refrescando historial de búsquedas...")
            await loadSearchHistory()   // 👈 🔥 Refresca inmediatamente el historial
        } catch {
            print("AHB: ❌ Error al guardar búsqueda: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cargar historial de búsquedas desde SwiftData
    func loadSearchHistory() async {
        guard let context else {
            print("AHB: ❌ No hay contexto disponible para cargar el historial")
            return
        }
        print("AHB: 🔍 Contexto usado para load: \(context)")
        do {
            let descriptor = FetchDescriptor<SearchDB>(sortBy: [SortDescriptor(\.query)])
            let results = try context.fetch(descriptor)
            searchHistory = results
            print("AHB: ✅ Historial recuperado con \(results.count) elementos: \(results.map { $0.query })")
        } catch {
            print("❌ Error al cargar historial de búsquedas: \(error.localizedDescription)")
        }
    }
    
    // Elimina una búsqueda concreta del historial
    func deleteSearchHistory(_ search: SearchDB) async {
        guard let context = context else { return }
        do {
            context.delete(search)
            try context.save()
            searchHistory.removeAll { $0.id == search.id }
            print("🗑️ Búsqueda eliminada: \(search.query)")
        } catch {
            print("❌ Error eliminando búsqueda: \(error.localizedDescription)")
        }
    }

    // Realiza una búsqueda a partir de un elemento del historial
    func performSearch(from search: SearchDB) async {
        searchTitle = search.query
        selectedGenres = search.genres
        selectedThemes = search.themes
        selectedDemographics = search.demographics
        hasSearched = true
        await searchIfNeeded()
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
