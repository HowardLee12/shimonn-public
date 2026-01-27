import Foundation

struct EmergencyMessage: Identifiable, Codable {
    let id: UUID
    var subject: String
    var body: String
    
    static let defaultMessage = EmergencyMessage(
        id: UUID(),
        subject: "Emergency Alert: I haven't checked in",
        body: "This is an automated message. I have not checked in to my Dead Man's Switch service for 48 hours. Please check on me."
    )
}
