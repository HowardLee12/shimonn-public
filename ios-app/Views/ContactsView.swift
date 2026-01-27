import SwiftUI

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @State private var showingAddContact = false
    @State private var newContactName = ""
    @State private var newContactEmail = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.contacts) { contact in
                    VStack(alignment: .leading) {
                        Text(contact.name)
                            .font(.headline)
                        Text(contact.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: viewModel.deleteContact)
            }
            .navigationTitle("Emergency Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.contacts.count < 2 {
                        Button(action: { showingAddContact = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                NavigationView {
                    Form {
                        Section(header: Text("New Contact")) {
                            TextField("Name", text: $newContactName)
                            TextField("Email", text: $newContactEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                    }
                    .navigationTitle("Add Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddContact = false
                                newContactName = ""
                                newContactEmail = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                viewModel.addContact(name: newContactName, email: newContactEmail)
                                showingAddContact = false
                                newContactName = ""
                                newContactEmail = ""
                            }
                            .disabled(newContactName.isEmpty || newContactEmail.isEmpty)
                        }
                    }
                }
            }
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}
