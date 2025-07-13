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
//        await loadFromSwiftData() // Primero los locales
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
            
            //Guardar en SwiftData
//            if let context = context {
//                for manga in response.items {
//                    await saveMangaIfNeeded(manga, in: context)
//                }
//            }
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
        }
    }
    
//    private func saveMangaIfNeeded(_ manga: Manga, in context: ModelContext) async {
//        guard !(await mangaExists(id: manga.id)) else { return }
//        
//        let mangaDB = MangaDB(
//            id: manga.id,
//            title: manga.title,
//            titleEnglish: manga.titleEnglish,
//            titleJapanese: manga.titleJapanese,
//            imageURL: manga.imageURL,
//            url: manga.url,
//            startDate: manga.startDate,
//            endDate: manga.endDate,
//            score: manga.score,
//            status: manga.status,
//            volumes: manga.volumes,
//            chapters: manga.chapters,
//            synopsis: manga.synopsis,
//            background: manga.background,
//            authors: [],
//            genres: [],
//            demographics: [],
//            themes: []
//        )
//        context.insert(mangaDB)
//    }
    
//    private func mangaExists(id: Int) async -> Bool {
//        guard let context = context else { return false }
//        var descriptor = FetchDescriptor<MangaDB>(
//            predicate: #Predicate { $0.id == id }
//        )
//        descriptor.fetchLimit = 1
//        
//        do {
//            let result = try context.fetch(descriptor)
//            return !result.isEmpty
//        } catch {
//            return false
//        }
//    }
    
//    private func loadFromSwiftData() async {
//        guard let context = context else { return }
//        do {
//            let descriptor = FetchDescriptor<MangaDB>()
//            let result = try context.fetch(descriptor)
//            self.mangas = result.map { $0.toManga }
//        } catch {
//            self.mangas = []
//            self.errorMessage = MangaError.loadFromPersistence.errorDescription
//        }
//    }
}
