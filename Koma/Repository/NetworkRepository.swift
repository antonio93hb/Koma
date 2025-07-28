import Foundation

struct NetworkRepository: DataRepository, NetworkInteractor {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getAllMangas(page: Int) async throws -> MangaResponse {
        return try await getJSON(
            request: .get(url: .allMangas(page: page)),
            type: MangaResponseDTO.self
        ).toMangaResponse
        
    }
    func getBestMangas() async throws -> MangaResponse {
        return try await getJSON(
            request: .get(url: .bestMangas()),
            type: MangaResponseDTO.self
        ).toMangaResponse
    }
    func searchMangas(query: CustomSearchDTO, page: Int) async throws -> MangaResponse {
        // Codificar el cuerpo de la petición
        let request = URLRequest.post(
            url: .searchManga(),
            body: query
        )

        return try await getJSON(
            request: request,
            type: MangaResponseDTO.self
        ).toMangaResponse
    }
}
