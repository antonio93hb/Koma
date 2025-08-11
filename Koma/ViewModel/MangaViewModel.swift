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

// MARK: - Persistencia (SwiftData)
extension MangaViewModel {

    // MARK: Guardar, obtener y eliminar
    /// Guarda un manga en la base de datos local usando SwiftData.
    /// - Parameter manga: Manga a guardar localmente.
    /// - Throws: `MangaError` si ocurre un error durante la inserción o guardado.
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
    /// Actualiza la propiedad `savedMangas`.
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
    /// - Parameter manga: Manga que se desea eliminar.
    /// - Throws: `MangaError` si ocurre un error durante la eliminación o guardado.
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

    // MARK: Consultas
    /// Devuelve un manga guardado con el ID proporcionado, si existe.
    /// - Parameter id: Identificador del manga.
    /// - Returns: Manga guardado o `nil` si no existe.
    /// - Throws: `MangaError` si ocurre un error durante la consulta.
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
    /// - Parameter id: Identificador del manga.
    /// - Returns: `true` si está guardado, `false` en caso contrario.
    /// - Throws: `MangaError` si ocurre un error durante la consulta.
    func isMangaSaved(_ id: Int) async throws -> Bool {
        guard let context else { return false }
        let descriptor = FetchDescriptor<MangaDB>(predicate: #Predicate { $0.id == id })
        do {
            return try context.fetchCount(descriptor) > 0
        } catch {
            throw MangaError.unknown(error)
        }
    }
    
    // MARK: Lectura de datos de volúmenes
    /// Devuelve el número de tomos que tiene un manga guardado.
    /// - Parameter id: Identificador del manga.
    /// - Returns: Número de tomos poseídos o `nil` si no existe o error.
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

    /// Devuelve el número de tomos leídos para un manga guardado.
    /// - Parameter id: Identificador del manga.
    /// - Returns: Número de tomos leídos o `nil` si no existe o error.
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

    // MARK: Actualización de volúmenes guardados y leidos
    /// Actualiza el número de tomos que posee el usuario para un manga guardado.
    /// - Parameters:
    ///   - mangaID: Identificador del manga.
    ///   - newValue: Nuevo valor para tomos poseídos.
    /// - Throws: `MangaError` si el valor es inválido o ocurre un error durante la actualización.
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
    /// - Parameters:
    ///   - mangaID: Identificador del manga.
    ///   - newValue: Nuevo valor para tomos leídos.
    /// - Throws: `MangaError` si el valor es inválido o ocurre un error durante la actualización.
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
}

// MARK: - Lógica de negocio y UI
extension MangaViewModel {

    // MARK: Inicio y destacados
    /// Carga los mangas y los mejores mangas si aún no se han cargado.
    /// Evita cargas repetidas usando la propiedad `hasLoaded`.
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await fetchMangas()
        await getBestMangas()
    }

    /// Obtiene los mangas mejor valorados desde la red y actualiza la propiedad `bestMangas`.
    /// Maneja errores específicos y generales actualizando `errorLoadingBest`.
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

    // MARK: Paginación
    /// Carga más mangas si el usuario está cerca del final de la lista y hay más mangas para cargar.
    /// - Parameter manga: Manga actual que se está visualizando para determinar el umbral de carga.
    func loadMoreIfNeeded(current manga: Manga) async {
        guard let index = mangas.firstIndex(where: { $0.id == manga.id }) else { return }

        let thresholdIndex = mangas.index(mangas.endIndex, offsetBy: -5, limitedBy: mangas.startIndex) ?? mangas.startIndex

        guard index >= thresholdIndex, hasMoreMangas, !isLoading else { return }
        await fetchMangas()
    }

    // MARK: Acciones sobre la colección (UI)
    /// Guarda un manga en la base de datos y refresca la lista de guardados.
    /// - Parameter manga: Manga a guardar.
    /// - Returns: `true` si la operación fue exitosa, `false` en caso contrario.
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

    /// Guarda un manga y devuelve el `AppAlert` correspondiente según el resultado.
    /// - Parameter manga: Manga a guardar.
    /// - Returns: `AppAlert` indicando éxito o fallo.
    func saveMangaAndGetAlert(_ manga: Manga) async -> AppAlert {
        let success = await saveMangaAndRefresh(manga)
        return success ? .saved : .failedToSave
    }
    
    /// Alias para actualizar la lista de mangas guardados.
    func refreshSavedMangas() async {
        await getSavedMangas()
    }

    // MARK: Lógica de negocio: volúmenes (poseídos y leídos)
    /// Actualiza el número de tomos poseídos para un manga dado.
    /// - Parameters:
    ///   - manga: Manga a actualizar.
    ///   - newValue: Nuevo valor para tomos poseídos.
    /// - Returns: `true` si la actualización fue exitosa, `false` en caso contrario.
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

    /// Actualiza el número de tomos leídos para un manga dado.
    /// - Parameters:
    ///   - manga: Manga a actualizar.
    ///   - newValue: Nuevo valor para tomos leídos.
    /// - Returns: `true` si la actualización fue exitosa, `false` en caso contrario.
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

    /// Incrementa el número de tomos poseídos para un manga dado en 1.
    /// - Parameter manga: Manga a actualizar.
    /// - Returns: `true` si se actualizó correctamente, `false` si ya estaba en el máximo o error.
    func increaseOwnedVolumes(for manga: Manga) async -> Bool {
        let current = await getOwnedVolumes(for: manga.id) ?? 0
        let max = manga.volumes ?? Int.max

        guard current < max else { return false }   // Si ya está en el máximo, no hace nada y no dispara alerta

        let newValue = current + 1
        return await updateOwnedVolumes(for: manga, to: newValue)
    }

    /// Incrementa el número de tomos leídos para un manga dado en 1.
    /// - Parameter manga: Manga a actualizar.
    /// - Returns: `true` si se actualizó correctamente, `false` si ya estaba en el máximo o error.
    func increaseReadVolumes(for manga: Manga) async -> Bool {
        let current = await getReadVolumes(for: manga.id) ?? 0
        let max = await getOwnedVolumes(for: manga.id) ?? 0
        guard current < max else { return false }
        return await updateReadVolumes(for: manga, to: current + 1)
    }

    /// Decrementa el número de tomos poseídos para un manga dado en 1.
    /// - Parameter manga: Manga a actualizar.
    /// - Returns: `true` si se actualizó correctamente, `false` si ya estaba en cero o error.
    func decreaseOwnedVolumes(for manga: Manga) async -> Bool {
        let current = await getOwnedVolumes(for: manga.id) ?? 0

        guard current > 0 else { return false }    // Si ya está en 0, no hace nada y no dispara alerta

        let newValue = current - 1
        return await updateOwnedVolumes(for: manga, to: newValue)
    }

    /// Decrementa el número de tomos leídos para un manga dado en 1.
    /// - Parameter manga: Manga a actualizar.
    /// - Returns: `true` si se actualizó correctamente, `false` si ya estaba en cero o error.
    func decreaseReadVolumes(for manga: Manga) async -> Bool {
        let current = await getReadVolumes(for: manga.id) ?? 0
        guard current > 0 else { return false }
        return await updateReadVolumes(for: manga, to: current - 1)
    }

    // MARK: Eliminación y alertas
    /// Elimina un manga guardado y actualiza la lista de guardados.
    /// - Parameter manga: Manga a eliminar.
    /// - Returns: `true` si se eliminó correctamente, `false` en caso de error.
    func deleteManga(_ manga: Manga) async -> Bool {
        do {
            try await unSaveManga(manga)
            await refreshSavedMangas()
            return true
        } catch {
            return false
        }
    }

    /// Elimina un manga y devuelve el `AppAlert` correspondiente según el resultado.
    /// - Parameter manga: Manga a eliminar.
    /// - Returns: `AppAlert` indicando éxito o fallo.
    func deleteMangaAndGetAlert(_ manga: Manga) async -> AppAlert {
        let success = await deleteManga(manga)
        if !success {
            errorMessage = MangaError.custom("No se pudo eliminar el manga").errorDescription
        }
        return success ? .deleted : .failedToDelete
    }

    // MARK: Estado para vista de detalle
    /// Carga el estado de un manga, devolviendo si está guardado y cuántos tomos posee y ha leído.
    /// - Parameter manga: Manga a consultar.
    /// - Returns: Tupla con `isSaved` indicando si está guardado, `ownedVolumes` y `readVolumes` opcionales.
    func loadMangaState(_ manga: Manga) async -> (isSaved: Bool, ownedVolumes: Int?, readVolumes: Int?) {
        let saved = (try? await isMangaSaved(manga.id)) ?? false
        let volumes = await getOwnedVolumes(for: manga.id)
        let read = await getReadVolumes(for: manga.id)
        return (saved, volumes, read)
    }
}

// MARK: - Red (privado)
private extension MangaViewModel {

    /// Solicita los mangas desde la red con soporte de paginación y actualiza el listado.
    /// Actualiza las propiedades `mangas`, `totalItems` y `currentPage`.
    /// Maneja errores actualizando `errorMessage`.
    func fetchMangas() async {
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
