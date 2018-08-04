import FluentPostgreSQL

final class UserConnection: PostgreSQLPivot {
    typealias Left = User
    typealias Right = User
    
    static var leftIDKey: WritableKeyPath<UserConnection, String> = \.leftID
    static var rightIDKey: WritableKeyPath<UserConnection, String> = \.rightID
    
    var id: Int?
    var leftID: String
    var rightID: String
    
    init(left: User, right: User)throws {
        self.leftID = try left.requireID()
        self.rightID = try right.requireID()
    }
}

extension UserConnection: Migration {}


extension User {
    var following: Siblings<User, User, UserConnection> {
        return self.siblings(\UserConnection.leftID, \UserConnection.rightID)
    }
    
    var followers: Siblings<User, User, UserConnection> {
        return self.siblings(\UserConnection.rightID, \UserConnection.leftID)
    }
    
    func follow(user: User, on connection: DatabaseConnectable) -> Future<(current: User, following: User)> {
        return Future.flatMap(on: connection) {
            let pivot = try UserConnection(left: self, right: user)
            return pivot.save(on: connection).map { _ in return (self, user) }
        }
    }
    
    func unfollow(user: User, on connection: DatabaseConnectable) -> Future<(current: User, unfollowed: User)> {
        return Future.flatMap(on: connection) {
            return self.following.detach(user, on: connection).map { _ in (self, user) }
        }
    }
}
