import FluentPostgreSQL
import Vapor

final class Tag {
    var id: UUID?
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Tag: Migration {
    public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
}

extension Tag: Content {}
extension Tag: Parameter {}
extension Tag: PostgreSQLUUIDModel {}
