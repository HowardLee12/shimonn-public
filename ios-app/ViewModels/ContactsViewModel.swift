import Foundation
import Combine

class ContactsViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    
    // Temporary for UI development
    init() {
        // load dummy data
    }
    
    func addContact(name: String, email: String) {
        guard contacts.count < 2 else { return }
        let newContact = EmergencyContact(name: name, email: email, order: contacts.count + 1)
        contacts.append(newContact)
    }
    
    func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        // re-order logic if strictly needed, or just let it be lists
    }
    
    func updateContact(_ contact: EmergencyContact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        }
    }
}
