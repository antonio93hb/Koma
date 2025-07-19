struct Demographic: Identifiable, Hashable {
    let id: String
    let name: String
}
extension Demographic {
    func toDemographicDB() -> DemographicDB {
        DemographicDB(id: id, name: name)
    }
}
