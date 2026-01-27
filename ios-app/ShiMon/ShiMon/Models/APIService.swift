import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.shimonn.com" // HTTPS via CloudFlare
    // private let baseURL = "http://localhost:3000" // Local testing
    
    private init() {}
    
    // Flag to enable mock mode
    private let isMockMode = false  // Disabled for device auth
    
    var token: String?
    
    // Set auth token for API requests
    func setAuthToken(_ token: String?) {
        self.token = token
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self.token = authResponse.token
                    completion(.success(authResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func register(email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                do {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self.token = authResponse.token
                    completion(.success(authResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func checkIn(completion: @escaping (Result<CheckInResponse, Error>) -> Void) {
        if isMockMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Mock response
                let mock = CheckInResponse(
                    id: "mock",
                    checkedAt: Date().ISO8601Format(),
                    deadline: Date().addingTimeInterval(48*3600).ISO8601Format(),
                    notified: false,
                    streakDays: 7,
                    locked: false
                )
                completion(.success(mock))
            }
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/checkin") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(CheckInResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func getCheckInStatus(completion: @escaping (Result<CheckInResponse, Error>) -> Void) {
        if isMockMode {
            // Mock response
            completion(.success(CheckInResponse(
                id: "mock",
                checkedAt: Date().ISO8601Format(),
                deadline: Date().addingTimeInterval(48*3600).ISO8601Format(),
                notified: false,
                streakDays: 7,
                locked: false
            )))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/checkin/status") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(CheckInResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func sendTestEmail(to email: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/test-email") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "to": email,
            "subject": "死了嗎 測試信件",
            "text": "這是一封來自您的「死了嗎 (Shimonn)」應用程式的測試郵件，用於確認您的郵箱能正常接收通知。",
            "html": "<p>這是一封來自您的 <strong>死了嗎 (Shimonn)</strong> 應用程式的測試郵件，用於確認您的郵箱能正常接收通知。</p>"
        ]
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                 throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorJson.error])
            }
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Device Authentication
    
    func deviceAuth(deviceID: String) async throws -> DeviceAuthResponse {
        let url = URL(string: "\(baseURL)/api/auth/device")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["deviceID": deviceID, "deviceType": "iOS"]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(DeviceAuthResponse.self, from: data)
    }
    
    // MARK: - Contacts API

    func getContacts(completion: @escaping (Result<[EmergencyContact], Error>) -> Void) {
        // Mock mode handling
        if isMockMode {
            completion(.success([]))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/contacts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let contacts = try JSONDecoder().decode([EmergencyContact].self, from: data)
                    completion(.success(contacts))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func createContact(name: String, email: String, order: Int, customSubject: String? = nil, customBody: String? = nil, completion: @escaping (Result<EmergencyContact, Error>) -> Void) {
        // Mock mode handling
        if isMockMode {
            completion(.success(EmergencyContact(name: name, email: email, order: order, customSubject: customSubject, customBody: customBody)))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/contacts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        var body: [String: Any] = [
            "name": name,
            "email": email,
            "order": order
        ]
        
        if let customSubject = customSubject {
            body["custom_subject"] = customSubject
        }
        
        if let customBody = customBody {
            body["custom_body"] = customBody
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let contact = try JSONDecoder().decode(EmergencyContact.self, from: data)
                    completion(.success(contact))
                } catch {
                     print("Decoding error: \(error)")
                    // Try to print response string for debugging
                    if let str = String(data: data, encoding: .utf8) {
                        print("Response body: \(str)")
                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func updateContact(id: UUID, name: String, email: String, order: Int, customSubject: String? = nil, customBody: String? = nil, completion: @escaping (Result<EmergencyContact, Error>) -> Void) {
        // Mock mode handling
        if isMockMode {
            completion(.success(EmergencyContact(id: id, name: name, email: email, order: order, customSubject: customSubject, customBody: customBody)))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/contacts/\(id.uuidString)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        var body: [String: Any] = [
            "name": name,
            "email": email,
            "order": order
        ]
        
        if let customSubject = customSubject {
            body["custom_subject"] = customSubject
        }
        
        if let customBody = customBody {
            body["custom_body"] = customBody
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                do {
                    let contact = try JSONDecoder().decode(EmergencyContact.self, from: data)
                    completion(.success(contact))
                } catch {
                    print("Decoding error: \(error)")
                    if let str = String(data: data, encoding: .utf8) {
                        print("Response body: \(str)")
                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func deleteContact(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Mock mode handling
        if isMockMode {
            completion(.success(()))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/contacts/\(id.uuidString)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, 
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                completion(.success(()))
            }
        }.resume()
    }
}

// MARK: - Device Auth Models

struct DeviceAuthResponse: Codable {
    let auth: Bool
    let token: String
    let user: DeviceUser
}

struct DeviceUser: Codable {
    let id: String
    let deviceID: String
    let deviceType: String
    let createdAt: String
}

enum APIError: Error {
    case invalidResponse
    case authenticationFailed
}

struct ErrorResponse: Codable {
    let error: String
}

struct CheckInResponse: Codable {
    let id: String?
    let checkedAt: String?
    let deadline: String?
    let notified: Bool?
    let streakDays: Int?
    let locked: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case checkedAt = "checked_at"
        case deadline
        case notified
        case streakDays = "streak_days"
        case locked
    }
}
