struct MangaResponseDTO: Codable {
    let items: [MangaDTO]
    let metadata: MetadataDTO
}

extension MangaResponseDTO {
    var toMangaResponse: MangaResponse {
        MangaResponse(
            items: items.map { $0.toManga },
            metadata: metadata.toMetadata
        )
    }
}
