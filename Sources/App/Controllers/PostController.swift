import Vapor
import Fluent

final class PostController: RouteCollection {
    func boot(router: Router) throws {
        let posts = router.grouped("users", User.parameter, "posts")
        
        posts.post(PostBody.self, use: create)
        posts.get(use: get)
    }
    
    func create(_ request: Request, body: PostBody)throws -> Future<Post> {
        guard let value = request.parameters.rawValues(for: User.self).first, let id = UUID(value) else {
            throw Abort(.badRequest, reason: "User ID paramater not convertible to UUID")
        }
        let post = body.model(with: id)
        return post.save(on: request)
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
