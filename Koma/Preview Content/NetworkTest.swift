//
//  NetworkTest.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//

import Foundation

struct NetworkTest: DataRepository {
    func getAllMangas(page: Int) async throws -> MangaResponse {
        let allMangas = try getJSON(fileName: "MangaTestPreview", type: MangaResponseDTO.self)
            .toMangaResponse
        return allMangas
    }
    func getBestMangas() async throws -> MangaResponse {
        let bestMangas = try getJSON(fileName: "MangaTestPreview", type: MangaResponseDTO.self)
            .toMangaResponse
        return bestMangas
    }
    func searchMangas(query: CustomSearchDTO, page: Int) async throws -> MangaResponse {
        // Datos mock para previews (no filtra por query ni página)
        try getJSON(fileName: "MangaTestPreview", type: MangaResponseDTO.self)
            .toMangaResponse
    }
    
    private func getJSON<JSON>(fileName: String, type: JSON.Type) throws -> JSON where JSON: Decodable {
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(JSON.self, from: data)
    }
}
