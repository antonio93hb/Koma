import Foundation

struct ThemeDTO: Codable {
    let id: String
    let theme: String
}

extension ThemeDTO {
    var toTheme: Theme {
        Theme(id: id, name: theme)
    }
}
