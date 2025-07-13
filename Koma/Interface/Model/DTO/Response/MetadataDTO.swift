struct MetadataDTO: Codable {
    let per: Int
    let page: Int
    let total: Int
}

extension MetadataDTO {
    var toMetadata: Metadata {
        Metadata(per: per, page: page, total: total)
    }
}
