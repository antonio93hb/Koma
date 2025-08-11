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
    
    var filters = SearchFilters()
    
    var searchTitle: String {
        get { filters.title }
        set { filters.title = newValue }
    }
    var selectedGenres: [String] {
        get { filters.genres }
        set { filters.genres = newValue }
    }
    var selectedThemes: [String] {
        get { filters.themes }
        set { filters.themes = newValue }
    }
    var selectedDemographics: [String] {
        get { filters.demographics }
        set { filters.demographics = newValue }
    }
    private var currentPage = 1
    private var totalItems = 0
    
    var hasMoreResults: Bool { searchResults.count < totalItems }
    
    var shouldShowHistory: Bool { !hasSearched && !isLoading }
    var shouldShowResults: Bool { hasSearched && !isLoading && !searchResults.isEmpty }
    var shouldShowNoResults: Bool { hasSearched && !isLoading && searchResults.isEmpty }
    
    // MARK: - Inicializador
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
    
    // MARK: - Búsqueda
    func clearSearch() {
        searchResults.removeAll()
        hasSearched = false
        filters = SearchFilters() // limpia todo
    }
    
    func searchIfNeeded(reset: Bool = true) async {
        if filters.isEmpty {
            clearSearch()
        } else {
            await performSearch(reset: reset)
        }
    }
    
    func updateFilters(genres: [String]? = nil, themes: [String]? = nil, demographics: [String]? = nil) async {
        if let genres { filters.genres = genres }
        if let themes { filters.themes = themes }
        if let demographics { filters.demographics = demographics }
        await searchIfNeeded(reset: true)
    }
    
    func performSearch(reset: Bool = true) async {
        hasSearched = true
        await fetchSearchResults(reset: reset)
        await saveSearch()
    }
    
    // MARK: - Guardar búsqueda en SwiftData (evita duplicados y actualiza)
    func saveSearch() async {
        guard let context else {
            print("AHB: ❌ No hay contexto disponible para guardar la búsqueda")
            return
        }

        let storedQuery  = filters.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let compareQuery = filters.title.normalized()
        let targetGenres = Set(filters.genres)
        let targetThemes = Set(filters.themes)
        let targetDemo   = Set(filters.demographics)

        print("AHB: ℹ️ Guardar búsqueda -> query: '\(storedQuery)', géneros: \(filters.genres), temas: \(filters.themes), demografía: \(filters.demographics)")

        do {
            let all = try context.fetch(FetchDescriptor<SearchDB>())

            if let existing = all.first(where: { item in
                item.query.normalized() == compareQuery &&
                Set(item.genres) == targetGenres &&
                Set(item.themes) == targetThemes &&
                Set(item.demographics) == targetDemo
            }) {
                existing.query        = storedQuery
                existing.genres       = filters.genres
                existing.themes       = filters.themes
                existing.demographics = filters.demographics
                existing.createdAt    = Date()
                try context.save()
                print("AHB: 🔁 Búsqueda existente actualizada (reciente): \(existing.query)")
                await loadSearchHistory()
                return
            }

            let newSearch = SearchDB(
                query: storedQuery,
                genres: filters.genres,
                themes: filters.themes,
                demographics: filters.demographics
            )
            context.insert(newSearch)
            try context.save()
            print("AHB: ✅ Búsqueda guardada: \(storedQuery)")
            await loadSearchHistory()

            if searchHistory.count > 20 {
                let toDelete = searchHistory
                    .sorted { $0.createdAt > $1.createdAt }
                    .dropFirst(20)
                toDelete.forEach { context.delete($0) }
                try? context.save()
                await loadSearchHistory()
                print("AHB: 🧹 Historial recortado a 20 elementos")
            }
        } catch {
            print("AHB: ❌ Error al guardar/actualizar búsqueda: \(error.localizedDescription)")
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
            let descriptor = FetchDescriptor<SearchDB>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
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
            currentPage = 1
            searchResults.removeAll()
        } else {
            isFetchingMore = true
        }
        errorMessage = nil
        defer { reset ? (isLoading = false) : (isFetchingMore = false) }
        
        do {
            let response = try await network.searchMangas(
                query: filters.toDTO(),
                page: currentPage
            )
            if reset { searchResults = response.items } else { searchResults += response.items }
            totalItems = response.metadata.total
            currentPage += 1
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch let error as MangaError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
    }
}
