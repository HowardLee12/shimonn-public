import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var lastCheckIn: Date = Date()
    @Published var deadline: Date = Date().addingTimeInterval(48 * 3600)
    @Published var timeRemainingString: String = "48:00:00"
    @Published var timeRemainingColor: String = "Normal" // Simple state representation
    
    @Published var streakDays: Int = 1
    @Published var isAccountLocked: Bool = false
    
    // ISO8601 Date Formatter
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // Fallback formatter for standard ISO8601
    private let standardIsoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private func parseDate(_ string: String) -> Date? {
        return isoFormatter.date(from: string) ?? standardIsoFormatter.date(from: string)
    }

    private var timer: Timer?
    
    init() {
        startTimer()
        fetchStatus()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchStatus() {
        APIService.shared.getCheckInStatus { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.updateWithResponse(response)
                    
                    // Check if account is locked
                    if response.locked == true {
                        self?.isAccountLocked = true
                    }
                case .failure(let error):
                    print("Failed to fetch status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkIn() {
        APIService.shared.checkIn { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.updateWithResponse(response)
                    
                    if response.locked == true {
                        self?.isAccountLocked = true
                    }
                case .failure(let error):
                    print("Check-in failed: \(error.localizedDescription)")
                    
                    // Check for 403 Forbidden (Locked)
                    let nsError = error as NSError
                    if nsError.code == 403 {
                        self?.isAccountLocked = true
                    }
                }
            }
        }
    }
    
    private func updateWithResponse(_ response: CheckInResponse) {
        if let checkedAtStr = response.checkedAt,
           let date = parseDate(checkedAtStr) {
            self.lastCheckIn = date
        } else {
            self.lastCheckIn = Date()
        }
        
        if let deadlineStr = response.deadline,
           let date = parseDate(deadlineStr) {
            self.deadline = date
        } else {
            self.deadline = Date().addingTimeInterval(48 * 3600)
        }
        
        if let streak = response.streakDays {
            self.streakDays = streak
        }
        
        self.updateTimeRemaining()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    @Published var timeRemainingPercentage: Double = 1.0
    
    private let totalTimeInterval: TimeInterval = 48 * 3600
    
    private func updateTimeRemaining() {
        let now = Date()
        let remaining = max(0, deadline.timeIntervalSince(now))
        
        // Calculate percentage (0.0 to 1.0)
        timeRemainingPercentage = remaining / totalTimeInterval
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60
        timeRemainingString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        // Color logic based on percentage
        if timeRemainingPercentage < 0.25 {
            timeRemainingColor = "Critical" // Red
        } else if timeRemainingPercentage < 0.5 {
            timeRemainingColor = "Warning"  // Orange
        } else if timeRemainingPercentage < 0.75 {
            timeRemainingColor = "Caution"  // Yellow
        } else {
            timeRemainingColor = "Normal"   // Green/Blue
        }
    }
}
