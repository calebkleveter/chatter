import Routing
import Vapor

public func routes(_ router: Router) throws {
    router.get { (request) in
        return "Hello Vapor!"
    }
    
    router.post(User.self, at: "users") { (request, user) in
        return user.save(on: request)
    }
}
