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
        } catch let networkError as NetworkError {
            errorLoadingBest = networkError.errorDescription
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
    func updateOwnedVolumesInDB(for mangaID: Int, to newValue: Int) async throws {
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
    
    /// Actualiza el número de tomos leídos en la base de datos local.
    func updateReadVolumesInDB(for mangaID: Int, to newValue: Int) async throws {
        guard let context else { throw MangaError.invalidData }

        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate<MangaDB> { $0.id == mangaID })

        do {
            if let mangaDB = try context.fetch(descriptor).first {
                if newValue < 0 {
                    throw MangaError.custom("El número de tomos leídos no puede ser negativo.")
                }
                if let owned = mangaDB.ownedVolumes, newValue > owned {
                    throw MangaError.custom("No puedes leer más tomos de los que posees.")
                }
                mangaDB.readVolumes = newValue
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
    
    /// Devuelve el número de tomos leídos para un manga
    func getReadVolumes(for id: Int) async -> Int? {
        guard let context else { return nil }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate<MangaDB> { $0.id == id })
        do {
            if let mangaDB = try context.fetch(descriptor).first {
                return mangaDB.readVolumes
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

    /// Guarda un manga en la base de datos y refresca la lista de guardados. Devuelve true si la operación fue exitosa.
    func saveMangaAndRefresh(_ manga: Manga) async -> Bool {
        do {
            try await saveManga(manga)
            await refreshSavedMangas()
            return true
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return false
        }
    }

    /// Guarda un manga y devuelve el AppAlert correspondiente.
    func saveMangaAndGetAlert(_ manga: Manga) async -> AppAlert {
        let success = await saveMangaAndRefresh(manga)
        return success ? .saved : .failedToSave
    }

    /// Actualiza el número de tomos poseídos para un manga dado y devuelve true si se realizó correctamente.
    func updateOwnedVolumes(for manga: Manga, to newValue: Int) async -> Bool {
        if let max = manga.volumes, newValue < 0 || newValue > max {
            return false
        }
        do {
            try await updateOwnedVolumesInDB(for: manga.id, to: newValue)
            // Ajusta readVolumes si es mayor que ownedVolumes
            if let read = await getReadVolumes(for: manga.id), read > newValue {
                _ = await updateReadVolumes(for: manga, to: newValue)
            }
            await refreshSavedMangas()
            return true
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return false
        }
    }
    
    /// Actualiza el número de tomos leídos para un manga dado y devuelve true si se realizó correctamente.
    func updateReadVolumes(for manga: Manga, to newValue: Int) async -> Bool {
        if let owned = await getOwnedVolumes(for: manga.id), newValue < 0 || newValue > owned {
            return false
        }
        do {
            try await updateReadVolumesInDB(for: manga.id, to: newValue)
            await refreshSavedMangas()
            return true
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
            return false
        }
    }

    /// Incrementa el número de tomos poseídos para un manga dado y devuelve true si se actualizó correctamente.
    func increaseOwnedVolumes(for manga: Manga) async -> Bool {
        let current = await getOwnedVolumes(for: manga.id) ?? 0
        let max = manga.volumes ?? Int.max
        
        guard current < max else { return false }   // Si ya está en el máximo, no hace nada y no dispara alerta
        
        let newValue = current + 1
        return await updateOwnedVolumes(for: manga, to: newValue)
    }
    
    /// Incrementa el número de tomos leídos para un manga dado y devuelve true si se actualizó correctamente.
    func increaseReadVolumes(for manga: Manga) async -> Bool {
        let current = await getReadVolumes(for: manga.id) ?? 0
        let max = await getOwnedVolumes(for: manga.id) ?? 0
        guard current < max else { return false }
        return await updateReadVolumes(for: manga, to: current + 1)
    }

    /// Decrementa el número de tomos poseídos para un manga dado y devuelve true si se actualizó correctamente.
    func decreaseOwnedVolumes(for manga: Manga) async -> Bool {
        let current = await getOwnedVolumes(for: manga.id) ?? 0
        
        guard current > 0 else { return false }    // Si ya está en 0, no hace nada y no dispara alerta
        
        let newValue = current - 1
        return await updateOwnedVolumes(for: manga, to: newValue)
    }
    
    /// Decrementa el número de tomos leídos para un manga dado y devuelve true si se actualizó correctamente.
    func decreaseReadVolumes(for manga: Manga) async -> Bool {
        let current = await getReadVolumes(for: manga.id) ?? 0
        guard current > 0 else { return false }
        return await updateReadVolumes(for: manga, to: current - 1)
    }

    /// Elimina un manga guardado y devuelve true si se eliminó correctamente.
    func deleteManga(_ manga: Manga) async -> Bool {
        do {
            try await unSaveManga(manga)
            await refreshSavedMangas()
            return true
        } catch {
            return false
        }
    }

    /// Elimina un manga y devuelve el AppAlert correspondiente.
    func deleteMangaAndGetAlert(_ manga: Manga) async -> AppAlert {
        let success = await deleteManga(manga)
        if !success {
            errorMessage = MangaError.custom("No se pudo eliminar el manga").errorDescription
        }
        return success ? .deleted : .failedToDelete
    }

    /// Carga el estado de un manga, devolviendo si está guardado y cuántos tomos posee.
    func loadMangaState(_ manga: Manga) async -> (isSaved: Bool, ownedVolumes: Int?, readVolumes: Int?) {
        let saved = (try? await isMangaSaved(manga.id)) ?? false
        let volumes = await getOwnedVolumes(for: manga.id)
        let read = await getReadVolumes(for: manga.id)
        return (saved, volumes, read)
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
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = MangaError.unknown(error).errorDescription
        }
    }
}
