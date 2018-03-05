import Routing
import Vapor

public func routes(_ router: Router) throws {
    router.get { (request) in
        return "Hello Vapor!"
    }
}
