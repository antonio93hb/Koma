import Foundation

protocol DataRepository {
    func getAllMangas(page: Int) async throws -> MangaResponse
    func getBestMangas() async throws -> MangaResponse
    func searchMangas(query: CustomSearchDTO, page: Int) async throws -> MangaResponse
}
