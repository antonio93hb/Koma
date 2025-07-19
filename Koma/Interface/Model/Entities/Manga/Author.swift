struct Author: Hashable {
    let id: String
    let firstName: String
    let lastName: String
    let fullName: String
    let role: String
}

extension Author {
    func toAuthorDB() -> AuthorDB {
        AuthorDB(id: id, firstName: firstName, lastName: lastName,  fullName: fullName, role: role)
    }
}
