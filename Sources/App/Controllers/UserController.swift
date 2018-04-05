import Vapor
import Fluent

final class UserController: RouteCollection {
    func boot(router: Router) throws {}
    
    func index(_ request: Request)throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    func show(_ request: Request)throws -> Future<User> {
        return try request.parameter(User.self)
    }
}
