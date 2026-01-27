import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // Flag to enable mock mode
    private let isMockMode = true
    
    // Real API call
    func login() {
        if isMockMode {
            loginMock()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func register() {
        if isMockMode {
            loginMock()
            return
        }
        
        isLoading = true

        errorMessage = nil
        
        APIService.shared.register(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        email = ""
        password = ""
    }
    
    // Mock login for testing without backend
    private func loginMock() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.isAuthenticated = true
        }
    }
}
