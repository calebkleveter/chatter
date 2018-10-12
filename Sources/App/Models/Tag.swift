import FluentPostgreSQL
import Vapor

final class Tag {
    var id: UUID?
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func save(on conn: DatabaseConnectable) -> EventLoopFuture<Tag> {
        return Tag.query(on: conn).save(self).catchFlatMap { error in
            guard let psqlError = error as? PostgreSQLError else { throw error }
            if psqlError.identifier == "server.error._bt_check_unique" {
                let error = NotFound(rootCause: FluentError(identifier: "modelNotFound", reason: "No tag with name '\(self.name)' was found"))
                return Tag.query(on: conn).filter(\.name == self.name).first().unwrap(or: error)
            } else {
                throw error
            }
        }
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
