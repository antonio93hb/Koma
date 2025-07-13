import Foundation

struct DemographicDTO: Codable {
    let id: String
    let demographic: String
}

extension DemographicDTO {
    var toDemographic: Demographic {
        Demographic(id: id, name: demographic)
    }
}
