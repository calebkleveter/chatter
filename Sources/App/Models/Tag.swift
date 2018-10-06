import FluentPostgreSQL
import Vapor

final class Tag {
    var id: UUID?
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
