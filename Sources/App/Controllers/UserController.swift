import Vapor
import Fluent

final class UserController: RouteCollection {
    func boot(router: Router) throws {}
    
    func create(_ request: Request, _ user: User)throws -> Future<User> {
        return user.save(on: request)
    }
    
    func index(_ request: Request)throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    func show(_ request: Request)throws -> Future<User> {
        return try request.parameter(User.self)
    }
}
