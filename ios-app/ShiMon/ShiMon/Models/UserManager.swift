import Foundation
import CloudKit
import Combine

/// Manages user authentication using iCloud ID or Keychain UUID
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var isAuthenticated = false
    @Published var userID: String?
    @Published var deviceID: String?
    @Published var authToken: String?
    @Published var isLoading = false
    
    private let keychainKey = "deviceUserID"
    
    private init() {}
    
    /// Automatically authenticate user on app launch
    func autoLogin() async {
        print("🔄 Starting auto-login...")
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Get device ID (iCloud or Keychain)
            print("📱 Getting device ID...")
            let deviceID = try await getDeviceID()
            print("✅ Device ID obtained: \(deviceID.prefix(8))...")
            
            await MainActor.run {
                self.deviceID = deviceID
            }
            
            // Authenticate with backend
            print("🌐 Authenticating with backend...")
            try await authenticateWithBackend(deviceID: deviceID)
            
            await MainActor.run {
                isAuthenticated = true
            }
            print("✅ Auto-login successful!")
        } catch let error as URLError {
            print("❌ Network error: \(error.localizedDescription)")
            print("   Error code: \(error.code.rawValue)")
            print("   URL: \(error.failureURLString ?? "unknown")")
            await MainActor.run {
                isAuthenticated = false
            }
        } catch {
            print("❌ Auto-login failed: \(error)")
            print("   Error type: \(type(of: error))")
            await MainActor.run {
                isAuthenticated = false
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    /// Get device ID with priority: iCloud > Keychain
    private func getDeviceID() async throws -> String {
        #if targetEnvironment(simulator)
        // On Simulator, skip iCloud and use Keychain directly
        let keychainID = getKeychainUserID()
        print("✅ Using Keychain ID (Simulator): \(keychainID.prefix(8))...")
        return keychainID
        #else
        // On real device, try iCloud first
        if let iCloudID = try? await getICloudUserID() {
            print("✅ Using iCloud ID: \(iCloudID.prefix(8))...")
            return iCloudID
        }
        
        // Fallback to Keychain UUID
        let keychainID = getKeychainUserID()
        print("✅ Using Keychain ID: \(keychainID.prefix(8))...")
        return keychainID
        #endif
    }
    
    /// Get iCloud user record ID
    private func getICloudUserID() async throws -> String? {
        let container = CKContainer.default()
        let recordID = try await container.userRecordID()
        return recordID.recordName
    }
    
    /// Get or create Keychain UUID
    private func getKeychainUserID() -> String {
        // Try to load existing ID
        if let existingID = KeychainHelper.shared.load(key: keychainKey) {
            return existingID
        }
        
        // Create new UUID
        let newID = UUID().uuidString
        _ = KeychainHelper.shared.save(key: keychainKey, value: newID)
        return newID
    }
    
    /// Authenticate with backend using device ID
    private func authenticateWithBackend(deviceID: String) async throws {
        let response = try await APIService.shared.deviceAuth(deviceID: deviceID)
        
        await MainActor.run {
            self.userID = response.user.id
            self.authToken = response.token
        }
        
        // Save token for future API requests
        APIService.shared.setAuthToken(response.token)
        
        print("✅ Backend authentication successful")
        print("   User ID: \(response.user.id)")
        print("   Device ID: \(response.user.deviceID.prefix(8))...")
    }
    
    /// Logout user (clear local state)
    func logout() {
        isAuthenticated = false
        userID = nil
        deviceID = nil
        authToken = nil
        APIService.shared.setAuthToken(nil)
        
        print("✅ User logged out")
    }
    
    /// Force re-authentication (useful for testing)
    func reAuthenticate() async {
        logout()
        await autoLogin()
    }
}
