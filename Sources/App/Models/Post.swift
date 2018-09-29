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

extension Post: Content {}
extension Post: Parameter {}
extension Post: Migration {}
extension Post: PostgreSQLUUIDModel {}
