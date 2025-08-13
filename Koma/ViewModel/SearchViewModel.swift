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
    
    // MARK: - Dependencias
    let network: DataRepository
    var context: ModelContext?
    
    // MARK: - Estado de UI
    /// Indica si se ha realizado al menos una búsqueda
    private(set) var hasSearched: Bool = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var isFetchingMore = false
    
    // MARK: - Filtros de búsqueda
    var filters = SearchFilters()
    var searchTitle: String { get { filters.title } set { filters.title = newValue } }
    var selectedGenres: [String] { get { filters.genres } set { filters.genres = newValue } }
    var selectedThemes: [String] { get { filters.themes } set { filters.themes = newValue } }
    var selectedDemographics: [String] { get { filters.demographics } set { filters.demographics = newValue } }
    
    // MARK: - Resultados e historial
    private(set) var searchResults: [Manga] = []
    private(set) var searchHistory: [SearchDB] = []
    
    // MARK: - Paginación
    private var currentPage = 1
    private var totalItems = 0
    var hasMoreResults: Bool { searchResults.count < totalItems }
    
    // MARK: - Flags de presentación
    var shouldShowHistory: Bool { !hasSearched && !isLoading }
    var shouldShowResults: Bool { hasSearched && !isLoading && !searchResults.isEmpty }
    var shouldShowNoResults: Bool { hasSearched && !isLoading && searchResults.isEmpty }
    
    // MARK: - Inicializador
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
}

// MARK: - Métodos públicos
extension SearchViewModel {
    
    // MARK: - Gestión de búsqueda
    /// Limpia por completo el estado de la búsqueda. Borra resultados, marca que aún no se ha buscado y reinicia todos los filtros.
    func clearSearch() {
        searchResults.removeAll()
        hasSearched = false
        filters = SearchFilters()
    }
    
    /// Ejecuta una búsqueda solo si existen filtros válidos.
    ///
    /// Si los filtros están vacíos, resetea el estado; en caso contrario realiza la búsqueda.
    /// - Parameter reset: Si es `true`, reinicia la paginación y los resultados antes de buscar.
    func searchIfNeeded(reset: Bool = true) async {
        if filters.isEmpty {
            clearSearch()
        } else {
            await performSearch(reset: reset)
        }
    }
    
    // MARK: - Gestión de filtros
    /// Actualiza los filtros seleccionados y lanza la búsqueda correspondiente.
    ///
    /// Solo modifica aquellos parámetros que no sean `nil`.
    /// - Parameters:
    ///   - genres: Lista de géneros seleccionados.
    ///   - themes: Lista de temas seleccionados.
    ///   - demographics: Lista de demografías seleccionadas.
    func updateFilters(genres: [String]? = nil, themes: [String]? = nil, demographics: [String]? = nil) async {
        if let genres { filters.genres = genres }
        if let themes { filters.themes = themes }
        if let demographics { filters.demographics = demographics }
        await searchIfNeeded(reset: true)
    }
    
    // MARK: - Ejecución de búsqueda
    /// Marca el inicio de una búsqueda y delega la carga de resultados.
    ///
    /// Guarda la búsqueda en el historial tras finalizar la petición.
    /// - Parameter reset: Si es `true`, reinicia la paginación y limpia resultados previos.
    func performSearch(reset: Bool = true) async {
        hasSearched = true
        await fetchSearchResults(reset: reset)
    }
    
    // MARK: - Historial de búsquedas (SwiftData)
    /// Persiste la búsqueda actual en SwiftData evitando duplicados.
    ///
    /// Si existe una búsqueda equivalente (misma query normalizada y mismos filtros),
    /// actualiza su fecha y campos para que aparezca como la más reciente; si no existe,
    /// crea un nuevo registro. También limita el historial a 20 entradas.
    /// - Important: Requiere `context` válido.
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
    /// Carga el historial de búsquedas desde SwiftData ordenado por fecha descendente.
    ///
    /// - Important: Requiere `context` válido.
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
            print("AHB: ❌ Error al cargar historial de búsquedas: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Eliminación de entradas del historial
    // Elimina una búsqueda concreta del historial
    /// Elimina una entrada concreta del historial.
    ///
    /// Borra el objeto de SwiftData y actualiza el array en memoria.
    /// - Parameter search: Entrada del historial a eliminar.
    func deleteSearchHistory(_ search: SearchDB) async {
        guard let context = context else { return }
        do {
            context.delete(search)
            try context.save()
            searchHistory.removeAll { $0.id == search.id }
            print("AHB: 🗑️ Búsqueda eliminada: \(search.query)")
        } catch {
            print("AHB: ❌ Error eliminando búsqueda: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Reutilizar una búsqueda del historial
    // Realiza una búsqueda a partir de un elemento del historial
    /// Restaura filtros a partir de una entrada del historial y lanza la búsqueda.
    ///
    /// Copia `query`, `genres`, `themes` y `demographics` desde `search`.
    /// - Parameter search: Entrada del historial usada como plantilla.
    func performSearch(from search: SearchDB) async {
        searchTitle = search.query
        selectedGenres = search.genres
        selectedThemes = search.themes
        selectedDemographics = search.demographics
        hasSearched = true
        await searchIfNeeded()
    }
    
    // MARK: - Paginación
    /// Carga la siguiente página cuando el usuario llega al final del listado.
    ///
    /// Solo actúa si el `manga` recibido coincide con el último de `searchResults`,
    /// aún quedan más elementos y no hay otra carga en curso.
    /// - Parameter manga: Último elemento visible en la lista.
    func loadMoreIfNeeded(current manga: Manga) async {
        guard manga.id == searchResults.last?.id,
              hasMoreResults,
              !isLoading,
              !isFetchingMore else {
            return
        }
        
        await fetchSearchResults(reset: false)
    }
}

// MARK: - Métodos privados

extension SearchViewModel {
    
    /// Reinicia la paginación y limpia resultados
    private func resetPagination() {
        currentPage = 1
        totalItems = 0
        searchResults.removeAll()
    }
    
    // MARK: - Lógica central de búsqueda
    /// Lógica central de consulta a la API y manejo de paginación.
    ///
    /// Realiza la petición al repositorio, actualiza `searchResults`, `totalItems`
    /// y `currentPage`. Gestiona estados de carga y errores de red.
    /// - Parameter reset: Si es `true`, inicia la carga desde la página 1 y limpia resultados.
    private func fetchSearchResults(reset: Bool = false) async {
        if reset {
            isLoading = true
            resetPagination()
        } else {
            isFetchingMore = true
        }
        errorMessage = nil
        defer { reset ? (isLoading = false) : (isFetchingMore = false) }
        
        do {
            let response = try await network.searchMangas(query: filters.toDTO(), page: currentPage)
            if reset { searchResults = response.items } else { searchResults += response.items }
            totalItems = response.metadata.total
            currentPage += 1

            if reset, !filters.isEmpty {
                await saveSearch()
            }        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch let error as MangaError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
    }
}
