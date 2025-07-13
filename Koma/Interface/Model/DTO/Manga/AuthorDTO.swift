import Foundation

struct AuthorDTO: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let role: String
}

extension AuthorDTO {
    var toAuthor: Author {
        Author(
            id: id,
            firstName: firstName,
            lastName: lastName,
            fullName: "\(firstName) \(lastName)",
            role: role)
    }
}
