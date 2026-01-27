import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isRegistering ? "建立帳號" : "歡迎回來")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("電子郵件", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    #endif
                
                SecureField("密碼", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Button(action: {
                        if isRegistering {
                            authViewModel.register()
                        } else {
                            authViewModel.login()
                        }
                    }) {
                        Text(isRegistering ? "註冊" : "登入")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    isRegistering.toggle()
                    authViewModel.errorMessage = nil
                }) {
                    Text(isRegistering ? "已經有帳號了？登入" : "還沒有帳號？註冊")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthViewModel())
    }
}
