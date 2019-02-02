import JWT

final class Payload: JWTPayload {
    let id: User.ID
    let iat: TimeInterval
    let exp: TimeInterval
    
    init(id: User.ID, exp: TimeInterval = 3600) {
        let now = Date()
        self.id = id
        self.iat = now.timeIntervalSince1970
        self.exp = now.timeIntervalSince1970 + exp
    }
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired()
        
        let initiated = Date(timeIntervalSince1970: self.iat)
        try NotBeforeClaim(value: initiated).verifyNotBefore()
    }
}
