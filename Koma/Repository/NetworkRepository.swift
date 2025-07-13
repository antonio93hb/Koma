import Foundation

struct NetworkRepository: DataRepository, NetworkInteractor {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getAllMangas(page: Int) async throws -> MangaResponse {
        return try await getJSON(
            request: .get(.allMangas(page: page)),
            type: MangaResponseDTO.self
        ).toMangaResponse
        
    }
    func getBestMangas() async throws -> MangaResponse {
        return try await getJSON(
            request: .get(.bestMangas()),
            type: MangaResponseDTO.self
        ).toMangaResponse
    }
    
//    func getBestMangasDB() async throws -> [Manga] {
//        return try await getJSON(
//            request: .get(.bestMangas()),
//            type: MangaResponseDTO.self
//        ).toMangaResponse
//    }
}


//¿Como puedo pasar MangaResponseDTO a [Manga] -> Clase 33 min 1:14
