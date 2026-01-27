import SwiftUI

struct ContactDetailView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @State var contact: EmergencyContact
    var isEditing: Bool = false
    
    @State private var showConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("基本資料")) {
                TextField("姓名", text: $contact.name)
                    .disabled(isEditing)
                    .foregroundColor(isEditing ? .gray : .primary)
                TextField("電子郵件", text: $contact.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(isEditing)
                    .foregroundColor(isEditing ? .gray : .primary)
                
                if isEditing {
                    Text("姓名與電子郵件無法修改")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("專屬遺言 (選填)")) {
                TextField("主旨 (預設: 緊急通知)", text: Binding(
                    get: { contact.customSubject ?? "" },
                    set: { contact.customSubject = $0.isEmpty ? nil : $0 }
                ))
                
                ZStack(alignment: .topLeading) {
                    if contact.customBody == nil || contact.customBody == "" {
                        Text("內容 (預設: 我已經超過48小時未打卡...)")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: Binding(
                        get: { contact.customBody ?? "" },
                        set: { contact.customBody = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 150)
                }
            }
            
            Section {
                Button(action: {
                    if !isEditing {
                        // Show confirmation alert for new contacts
                        showConfirmation = true
                    } else {
                        // Directly update for existing contacts (only custom message is editable anyway)
                        viewModel.updateContact(contact)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(isEditing ? "儲存變更" : "新增聯絡人")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(isEditing ? "編輯聯絡人" : "新增聯絡人")
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("確認新增"),
                message: Text("新增後，姓名與電子郵件將無法修改，僅能編輯專屬遺言。\n確認要新增嗎？"),
                primaryButton: .default(Text("確認"), action: {
                    viewModel.addContact(
                        name: contact.name,
                        email: contact.email,
                        customSubject: contact.customSubject,
                        customBody: contact.customBody
                    )
                    presentationMode.wrappedValue.dismiss()
                }),
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
}
