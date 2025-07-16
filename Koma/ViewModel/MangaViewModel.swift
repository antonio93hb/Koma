//
//  MangaListViewModel.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 12/6/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class MangaViewModel {
    
    // MARK: Dependencias
    let network: DataRepository
    var context: ModelContext?
    
    // MARK: Datos
    var mangas: [Manga] = []
    private(set) var bestMangas: [Manga] = []
    
    // MARK: Estado UI
    private(set) var errorMessage: String?
    private(set) var errorLoadingBest: String?
    var isLoading = false
    var isLoadingBest = false
    private var hasLoaded = false
    
    // MARK: Paginación
    private var currentPage = 1
    private var totalItems = 0
    
    var hasMoreMangas: Bool {
        mangas.count < totalItems
    }
    
    // MARK: Init
    init(network: DataRepository = NetworkRepository()) {
        self.network = network
    }
}

// MARK: Métodos Públicos
extension MangaViewModel {
    
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await fetchMangas()
        await getBestMangas()
    }
    
    func getBestMangas() async {
        guard !isLoadingBest else { return }
        defer { isLoadingBest = false }
        isLoadingBest = true
        errorLoadingBest = nil
        do {
            let response = try await network.getBestMangas()
            bestMangas = response.items
        } catch {
            errorLoadingBest = MangaError.unknown(error).errorDescription
        }
    }
    
    func loadMoreIfNeeded(current manga: Manga) async {
        guard let index = mangas.firstIndex(where: { $0.id == manga.id }) else { return }
        
        let thresholdIndex = mangas.index(mangas.endIndex, offsetBy: -5, limitedBy: mangas.startIndex) ?? mangas.startIndex
        
        guard index >= thresholdIndex, hasMoreMangas, !isLoading else { return }
        await fetchMangas()
    }
    
    func getSavedMangas() async -> [Manga] {
        guard let context = context else { return [] }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate { $0.isSaved == true })
        do {
            let result = try context.fetch(descriptor)
            return result.map { $0.toManga }
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return []
        }
    }
}

// MARK: Métodos Privados

private extension MangaViewModel {
    
    private func fetchMangas() async {
        guard !isLoading else { return }
        defer { isLoading = false }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await network.getAllMangas(page: currentPage)
            
            if  currentPage == 1 {
                mangas = response.items
            } else {
                mangas += response.items
            }
            totalItems = response.metadata.total
            currentPage += 1
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
        }
    }
}
