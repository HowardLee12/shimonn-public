import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var lastCheckIn: Date = Date()
    @Published var deadline: Date = Date().addingTimeInterval(48 * 3600)
    @Published var timeRemainingString: String = "48:00:00"
    @Published var timeRemainingColor: String = "Normal" // Simple state representation
    
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func checkIn() {
        APIService.shared.checkIn { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.lastCheckIn = Date()
                    self?.deadline = Date().addingTimeInterval(48 * 3600)
                    self?.updateTimeRemaining()
                case .failure(let error):
                    print("Check-in failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        let remaining = deadline.timeIntervalSince(now)
        
        if remaining <= 0 {
            timeRemainingString = "00:00:00"
            timeRemainingColor = "Critical"
        } else {
            let hours = Int(remaining) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60
            timeRemainingString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            if remaining < 3600 {
                timeRemainingColor = "Critical"
            } else if remaining < 24 * 3600 {
                timeRemainingColor = "Warning"
            } else {
                timeRemainingColor = "Normal"
            }
        }
    }
}
