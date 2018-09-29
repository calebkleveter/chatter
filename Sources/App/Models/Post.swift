import Vapor
import FluentPostgreSQL

final class Post {
    var id: UUID?
    var contents: String
    let userID: User.ID
    
    public init(contents: String, userID: User.ID) {
        self.contents = contents
        self.userID = userID
    }
}

extension Post: Migration {
    public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Post: Content {}
extension Post: Parameter {}
extension Post: PostgreSQLUUIDModel {}
