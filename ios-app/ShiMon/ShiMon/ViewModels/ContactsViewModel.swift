import Foundation
import Combine
import SwiftUI

class ContactsViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        fetchContacts()
    }
    
    func fetchContacts() {
        isLoading = true
        APIService.shared.getContacts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedContacts):
                    self?.contacts = fetchedContacts
                case .failure(let error):
                    print("Error fetching contacts: \(error)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addContact(name: String, email: String, customSubject: String? = nil, customBody: String? = nil) {
        guard contacts.count < 2 else { return }
        
        isLoading = true
        let order = contacts.count + 1
        
        APIService.shared.createContact(name: name, email: email, order: order, customSubject: customSubject, customBody: customBody) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newContact):
                    self?.contacts.append(newContact)
                case .failure(let error):
                    print("Error adding contact: \(error)")
                    self?.errorMessage = "Failed to add contact: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteContact(at offsets: IndexSet) {
        offsets.forEach { index in
            let contact = contacts[index]
            APIService.shared.deleteContact(id: contact.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Contact deleted successfully")
                    case .failure(let error):
                        print("Error deleting contact: \(error)")
                        self?.errorMessage = "Failed to delete contact"
                        // Re-fetch contacts to ensure UI is in sync if delete failed
                        self?.fetchContacts()
                    }
                }
            }
        }
        
        // Optimistically remove from UI
        contacts.remove(atOffsets: offsets)
    }
    
    func updateContact(_ contact: EmergencyContact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            // Optimistically update UI
            let oldContact = contacts[index]
            contacts[index] = contact
            
            APIService.shared.updateContact(
                id: contact.id,
                name: contact.name,
                email: contact.email,
                order: contact.order,
                customSubject: contact.customSubject,
                customBody: contact.customBody
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedContact):
                        // Update with server response to be sure
                        if let idx = self?.contacts.firstIndex(where: { $0.id == updatedContact.id }) {
                            self?.contacts[idx] = updatedContact
                        }
                    case .failure(let error):
                        print("Error updating contact: \(error)")
                        self?.errorMessage = "Failed to update contact"
                        // Revert optimistic update
                        if let idx = self?.contacts.firstIndex(where: { $0.id == oldContact.id }) {
                            self?.contacts[idx] = oldContact
                        }
                    }
                }
            }
        }
    }
}
