import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userManager: UserManager

    @State private var userEmail: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("帳號")) {
                    HStack {
                        Text("裝置 ID")
                        Spacer()
                        Text(userManager.deviceID?.prefix(8).description ?? "未知")
                            .foregroundColor(.gray)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Button("登出") {
                        userManager.logout()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("電子郵件"), footer: Text("用於接收測試郵件")) {
                    TextField("輸入您的電子郵件", text: $userEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Button(action: saveEmail) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("儲存郵件")
                        }
                    }
                    .disabled(userEmail.isEmpty)
                    
                    Button(action: sendTestEmail) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "paperplane")
                                Text("發送測試郵件給自己")
                            }
                        }
                    }
                    .disabled(userEmail.isEmpty || isLoading)
                }
                

                
                Section(header: Text("關於")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("設定")
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadEmail()
            }
        }
    }
    
    private func loadEmail() {
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            userEmail = email
        }
    }
    
    private func saveEmail() {
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        alertMessage = "電子郵件已儲存"
        showAlert = true
    }
    
    private func sendTestEmail() {
        guard !userEmail.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await APIService.shared.sendTestEmail(to: userEmail)
                await MainActor.run {
                    isLoading = false
                    alertMessage = "測試郵件已發送到 \(userEmail)"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "發送失敗：\(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(UserManager.shared)
    }
}
