import FluentPostgreSQL
import Vapor

final class PostTag: PostgreSQLUUIDPivot {
    typealias Left = Post
    typealias Right = Tag
    
    static var leftIDKey: WritableKeyPath<PostTag, UUID> = \.postID
    static var rightIDKey: WritableKeyPath<PostTag, UUID> = \.tagID
    
    var id: UUID?
    var postID: UUID
    var tagID: UUID
    
    init(post: Post, tag: Tag)throws {
        self.postID = try post.requireID()
        self.tagID = try tag.requireID()
    }
}

extension Post {
    var tags: Siblings<Post, Tag, PostTag> {
        return self.siblings()
    }
}

extension Tag {
    var posts: Siblings<Tag, Post, PostTag> {
        return self.siblings()
    }
}

extension PostTag: Content {}
extension PostTag: Migration {}
