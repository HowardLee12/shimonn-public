import Foundation

struct User: Identifiable, Codable, Sendable {
    let id: UUID
    let email: String
    var createdAt: Date
    
    // Auth token or similar would be stored securely, not necessarily in this simple model struct
    // depending on the auth strategy (JWT etc)
}

struct AuthResponse: Codable, Sendable {
    let user: User
    let token: String
}
