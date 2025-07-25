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
    var savedMangas: [Manga] = []
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
    /// Valida e intenta actualizar el número de tomos que posee el usuario. Devuelve true si se actualizó correctamente.
    func handleOwnedVolumeUpdate(for mangaID: Int, input: String, max: Int) async -> Bool {
        guard let value = Int(input), value >= 0, value <= max else {
            return false
        }

        do {
            try await updateOwnedVolumes(for: mangaID, to: value)
            return true
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return false
        }
    }
    
    /// Carga los mangas y los mejores mangas si aún no se han cargado.
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await fetchMangas()
        await getBestMangas()
    }
    
    /// Obtiene los mangas mejor valorados desde la red.
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
    
    /// Carga más mangas si el usuario ha llegado al final de la lista.
    func loadMoreIfNeeded(current manga: Manga) async {
        guard let index = mangas.firstIndex(where: { $0.id == manga.id }) else { return }
        
        let thresholdIndex = mangas.index(mangas.endIndex, offsetBy: -5, limitedBy: mangas.startIndex) ?? mangas.startIndex
        
        guard index >= thresholdIndex, hasMoreMangas, !isLoading else { return }
        await fetchMangas()
    }
    
    /// Guarda un manga en la base de datos local usando SwiftData.
    func saveManga(_ manga: Manga) async throws {
        guard let context else { return }
        let mangaDB = manga.toMangaDB()
        do {
            context.insert(mangaDB)
            try context.save()
            await getSavedMangas()
        } catch {
            throw MangaError.unknown(error)
        }
    }
    /// Obtiene todos los mangas guardados desde la base de datos local.
    func getSavedMangas() async {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate { $0.isSaved == true })
        do {
            let result = try context.fetch(descriptor)
            savedMangas = result.map { $0.toManga }
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            savedMangas = []
        }
    }
    
    /// Elimina un manga guardado de la base de datos local.
    func unSaveManga(_ manga: Manga) async throws {
        guard let context else { return }
        let id = manga.id

        let fetchDescriptor = FetchDescriptor<MangaDB>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            if let mangaDB = try context.fetch(fetchDescriptor).first {
                context.delete(mangaDB)
                try context.save()
                await getSavedMangas()
            }
        } catch {
            throw MangaError.unknown(error)
        }
    }
    
    /// Devuelve un manga guardado con el ID proporcionado, si existe.
    func getMangaById(_ id: Int) async throws -> Manga? {
        guard let context else { return nil }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate { $0.id == id })
        do {
            if let mangaDB = try context.fetch(descriptor).first {
                return mangaDB.toManga
            }
            return nil
        } catch {
            throw MangaError.unknown(error)
        }
    }
    
    /// Verifica si un manga con el ID dado ya está guardado en la base de datos.
    func isMangaSaved(_ id: Int) async throws -> Bool {
        guard let context else { return false }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate { $0.id == id })
        do {
            return try context.fetchCount(descriptor) > 0
        } catch {
            throw MangaError.unknown(error)
        }
    }

    /// Actualiza el número de tomos que posee el usuario para un manga guardado.
    func updateOwnedVolumes(for mangaID: Int, to newValue: Int) async throws {
        guard let context else { throw MangaError.invalidData }

        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate<MangaDB> { $0.id == mangaID })

        do {
            if let mangaDB = try context.fetch(descriptor).first {
                if newValue < 0 {
                    throw MangaError.custom("El número de tomos no puede ser negativo.")
                }

                if let totalVolumes = mangaDB.volumes, newValue > totalVolumes {
                    throw MangaError.custom("No puedes tener más tomos que los publicados.")
                }

                mangaDB.ownedVolumes = newValue
                try context.save()
            }
        } catch {
            throw MangaError.unknown(error)
        }
    }
    
    /// Devuelve el número de tomos que tiene un manga
    func getOwnedVolumes(for id: Int) async -> Int? {
        guard let context else { return nil }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate<MangaDB> { $0.id == id })
        do {
            if let mangaDB = try context.fetch(descriptor).first {
                return mangaDB.ownedVolumes
            }
            return nil
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return nil
        }
    }
    
    /// Alias para actualizar los mangas guardados.
    func refreshSavedMangas() async {
        await getSavedMangas()
    }
}

// MARK: Métodos Privados

private extension MangaViewModel {
    
    /// Solicita los mangas desde la red con soporte de paginación y actualiza el listado.
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
