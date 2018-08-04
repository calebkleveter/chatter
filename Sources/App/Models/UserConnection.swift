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
