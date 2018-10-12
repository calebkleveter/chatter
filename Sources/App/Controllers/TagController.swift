import FluentPostgreSQL
import Vapor

final class TagController: RouteCollection {
    func boot(router: Router) throws {
        let tags = router.grouped("tags", Tag.parameter)
        
        tags.get("posts", use: posts)
    }
    
    func posts(_ request: Request)throws -> Future<[Post]> {
        return try request.parameters.next(Tag.self).flatMap { tag in
            return try tag.posts.query(on: request).all()
        }
    }
}
