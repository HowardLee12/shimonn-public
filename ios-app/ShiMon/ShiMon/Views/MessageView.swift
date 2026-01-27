import SwiftUI

struct MessageView: View {
    @AppStorage("userEmail") private var userEmail: String = ""
    @State private var subject: String = "Emergency Alert: I haven't checked in"
    @State private var bodyText: String = "This is an automated message. I have not checked in to my Dead Man's Switch service for 48 hours. Please check on me."
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSendingTest = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Subject Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("郵件主旨")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))
                            .padding(.horizontal, 20)
                        
                        TextField("主旨", text: $subject)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(Color(hex: "#F8F9FA"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E5E7EB"), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Body Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("郵件內容")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))
                            .padding(.horizontal, 20)
                        
                        TextEditor(text: $bodyText)
                            .font(.system(size: 16))
                            .padding(12)
                            .frame(height: 200)
                            .background(Color(hex: "#F8F9FA"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E5E7EB"), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Save Button
                        Button(action: {
                            saveMessage()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                Text("儲存變更")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "#4FACFE").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        // Test Email Button
                        Button(action: {
                            sendTestEmail()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                                Text("發送測試郵件給自己")
                                    .font(.system(size: 16, weight: .semibold))
                                if isSendingTest {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: isSendingTest ? 
                                        [Color(hex: "#9CA3AF"), Color(hex: "#6B7280")] :
                                        [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "#4FACFE").opacity(isSendingTest ? 0.1 : 0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isSendingTest)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            .background(Color.white)
            .navigationTitle("預設遺言")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("通知"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("確定"))
                )
            }
        }
    }
    
    private func saveMessage() {
        // TODO: Save to backend
        alertMessage = "設定已儲存"
        showAlert = true
    }
    
    private func sendTestEmail() {
        if userEmail.isEmpty {
            alertMessage = "請先在「設定」頁面輸入您的電子郵件"
            showAlert = true
            return
        }
        
        isSendingTest = true
        
        Task {
            do {
                try await APIService.shared.sendTestEmail(to: userEmail)
                await MainActor.run {
                    isSendingTest = false
                    alertMessage = "測試郵件已發送到 \(userEmail)"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isSendingTest = false
                    alertMessage = "發送失敗: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
