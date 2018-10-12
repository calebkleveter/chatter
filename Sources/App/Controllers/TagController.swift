import FluentPostgreSQL
import Vapor

final class TagController: RouteCollection {
    func boot(router: Router) throws {
        let tags = router.grouped("tags")
        
        tags.get(use: get)
        tags.get(Tag.parameter, "posts", use: posts)
    }
    
    func get(_ request: Request)throws -> Future<[Tag]> {
        return Tag.query(on: request).all()
    }
    
    func posts(_ request: Request)throws -> Future<[Post]> {
        return try request.parameters.next(Tag.self).flatMap { tag in
            return try tag.posts.query(on: request).all()
        }
    }
}
