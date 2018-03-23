import FluentPostgreSQL
import Foundation
import Vapor

final class User: Content {
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

extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
