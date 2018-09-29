import FluentPostgreSQL
import Foundation
import Vapor

final class User: Content, Parameter {
    var id: UUID?
    var username: String
    var firstname: String
    var lastname: String
    var email: String
    var password: String
    
    init(username: String, firstname: String, lastname: String, email: String, password: String) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
    }
}

extension User {
    var posts: Children<User, Post> {
        return self.children(\.userID)
    }
}

extension User: Migration {
    public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
            builder.unique(on: \.email)
        }
    }
}

extension User: PostgreSQLUUIDModel {}
