import Foundation

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var order: Int
    
    init(id: UUID = UUID(), name: String, email: String, order: Int) {
        self.id = id
        self.name = name
        self.email = email
        self.order = order
    }
}
