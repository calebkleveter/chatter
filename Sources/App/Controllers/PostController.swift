import Vapor
import Fluent

final class PostController: RouteCollection {
    func boot(router: Router) throws {
        let posts = router.grouped("users", User.parameter, "posts")
        
        posts.post(PostBody.self, use: create)
        posts.get(use: get)
        posts.get(Post.ID.parameter, use: single)
        posts.patch(PostBody.self, at: Post.ID.parameter, use: patch)
        posts.delete(Post.ID.parameter, use: delete)
    }
    
    func create(_ request: Request, body: PostBody)throws -> Future<Post> {
        guard let value = request.parameters.rawValues(for: User.self).first, let id = UUID(value) else {
            throw Abort(.badRequest, reason: "User ID paramater not convertible to UUID")
        }
        let post = body.model(with: id)
        let tags = body.tags?.map(Tag.init)
        
        let savedTags = tags?.map { tag in tag.save(on: request) }.flatten(on: request) ?? request.future([])
        let savedPost = savedTags.transform(to: request).flatMap(post.save)
        let postTags = flatMap(savedTags, savedPost) { tags, post in
            return try tags.map { tag in
                return try PostTag(post: post, tag: tag).save(on: request)
            }.flatten(on: request)
        }
        
        return postTags.flatMap { _ in savedPost }
    }
    
    func get(_ request: Request)throws -> Future<[Post]> {
        return try request.parameters.next(User.self).flatMap { user in
            return try user.posts.query(on: request).all()
        }
    }
    
    func single(_ request: Request)throws -> Future<Post> {
        return try request.parameters.next(User.self).flatMap { user in
            let postID = try request.parameters.next(Post.ID.self)
            let error = try Abort(.notFound, reason: "No post with ID '\(postID)' found for user with ID '\(user.requireID())'")
            
            return try user.posts.query(on: request).filter(\.id == postID).first().unwrap(or: error)
        }
    }
    
    func patch(_ request: Request, body: PostBody)throws -> Future<Post> {
        return try request.parameters.next(User.self).flatMap { user -> Future<Post> in
            let postID = try request.parameters.next(Post.ID.self)
            let notFound = try Abort(.notFound, reason: "No post with ID '\(postID)' found for user '\(user.requireID())'")
            
            return try user.posts.query(on: request).filter(\.id == postID).update(\.contents, to: body.contents).first().unwrap(or: notFound)
        }.flatMap { (post: Post) -> Future<Post> in
            guard let tags = body.tags else {
                return request.future(post)
            }
            let query = PostTag.query(on: request).join(\Tag.id, to: \PostTag.tagID)
            try query.filter(\.postID == post.requireID())
            query.filter(\Tag.name ~~ tags)
                
            return query.delete().transform(to: post)
        }.flatMap { post -> Future<Post> in
            let newTags = body.tags?.map(Tag.init).map { tag in tag.save(on: request) }.flatten(on: request) ?? request.future([])
            let postTags = newTags.flatMap { tags in
                return try tags.map { tag in
                    return try PostTag(post: post, tag: tag).save(on: request)
                }.flatten(on: request)
            }
            
            return postTags.transform(to: post)
        }
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(User.self).flatMap { user in
            let postID = try request.parameters.next(Post.ID.self)
            return try user.posts.query(on: request).filter(\.id == postID).delete().transform(to: .noContent)
        }
    }
}

struct PostBody: Content {
    let contents: String
    let tags: [String]?
    
    func model(with id: User.ID) -> Post {
        return Post(contents: self.contents, userID: id)
    }
}
