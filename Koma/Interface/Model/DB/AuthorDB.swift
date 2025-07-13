//
//  AuthorDB.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 2/7/25.
//

import SwiftData

@Model
final class AuthorDB {
    var id: String
    var firstName: String
    var lastName: String
    var fullName: String
    var role: String

    init(id: String, firstName: String, lastName: String, fullName: String, role: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.role = role
    }
}

extension AuthorDB {
    var toAuthor: Author {
        Author(
            id: id,
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            role: role
        )
    }
}
