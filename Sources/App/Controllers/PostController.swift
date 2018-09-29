import Vapor
import Fluent

final class PostController: RouteCollection {
    func boot(router: Router) throws {
        let posts = router.grouped("users", User.parameter, "posts")
        
        posts.get(use: get)
    }
    
    func get(_ request: Request)throws -> Future<[Post]> {
        return try request.parameters.next(User.self).flatMap { user in
            try user.posts.query(on: request).all()
        }
    }
}

struct PostBody: Content {
    let contents: String
    
    func model(with id: User.ID) -> Post {
        return Post(contents: self.contents, userID: id)
    }
}
