import Routing
import Vapor

public func routes(_ router: Router) throws {
    try router.register(collection: UserController())
    try router.register(collection: PostController())
    try router.register(collection: TagController())
}
