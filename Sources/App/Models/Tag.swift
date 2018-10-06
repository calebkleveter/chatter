import FluentPostgreSQL
import Vapor

final class Tag {
    var id: UUID?
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Tag: Content {}
extension Tag: Parameter {}
extension Tag: Migration {}
extension Tag: PostgreSQLUUIDModel {}
