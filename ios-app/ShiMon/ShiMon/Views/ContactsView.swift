import SwiftUI

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @State private var showingAddContact = false
    @State private var showingUpgradeAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.contacts.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Icon with gradient background
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#4FACFE").opacity(0.1), Color(hex: "#00F2FE").opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 12) {
                            Text("尚未新增緊急聯絡人")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "#333333"))
                            
                            Text("新增最多 2 位緊急聯絡人\n當您未能及時打卡時，系統將自動通知他們")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "#666666"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 40)
                        
                        Button(action: { showingAddContact = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                Text("新增聯絡人")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color(hex: "#4FACFE").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Contact List
                    List {
                        ForEach(viewModel.contacts) { contact in
                            NavigationLink(destination: ContactDetailView(viewModel: viewModel, contact: contact, isEditing: true)) {
                                VStack(alignment: .leading) {
                                    Text(contact.name)
                                        .font(.headline)
                                    Text(contact.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteContact)
                    }
                }
            }

            .navigationTitle("緊急聯絡人")

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.contacts.count >= 2 {
                            showingUpgradeAlert = true
                        } else {
                            showingAddContact = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .alert(isPresented: $showingUpgradeAlert) {
                        Alert(
                            title: Text("升級方案"),
                            message: Text("如需新增更多聯絡人，請升級至付費方案"),
                            dismissButton: .default(Text("確定"))
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                NavigationView {
                    ContactDetailView(
                        viewModel: viewModel,
                        contact: EmergencyContact(id: UUID(), name: "", email: "", order: viewModel.contacts.count + 1),
                        isEditing: false
                    )
                }
            }

            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("錯誤"),
                    message: Text(viewModel.errorMessage ?? "未知錯誤"),
                    dismissButton: .default(Text("確定"))
                )
            }
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}
