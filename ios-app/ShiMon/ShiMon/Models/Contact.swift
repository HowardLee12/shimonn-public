import Foundation

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var order: Int
    var customSubject: String?
    var customBody: String?
    
    init(id: UUID = UUID(), name: String, email: String, order: Int, customSubject: String? = nil, customBody: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.order = order
        self.customSubject = customSubject
        self.customBody = customBody
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case order = "contact_order"
        case customSubject = "custom_subject"
        case customBody = "custom_body"
    }
}
