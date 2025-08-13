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
        let all = try getJSON(fileName: "MangaTestPreview", type: MangaResponseDTO.self).toMangaResponse
        let per = all.metadata.per

        // Filtro muy simple por título
        let q = (query.searchTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered = q.isEmpty ? all.items : all.items.filter { m in
            let haystack = [m.title, m.titleEnglish, m.titleJapanese]
                .compactMap { $0?.lowercased() }
                .joined(separator: " ")
            return query.searchContains ? haystack.contains(q) : haystack.hasPrefix(q)
        }

        // Paginación básica
        let start = max(0, (page - 1) * per)
        let pageItems = Array(filtered.dropFirst(start).prefix(per))

        return MangaResponse(
            items: pageItems,
            metadata: .init(per: per, page: page, total: filtered.count)
        )
    }
    
    private func getJSON<JSON>(fileName: String, type: JSON.Type) throws -> JSON where JSON: Decodable {
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(JSON.self, from: data)
    }
}
