struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
}
extension Theme {
    func toThemeDB() -> ThemeDB {
        ThemeDB(id: id, name: name)
    }
}
