import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isPressing = false
    @State private var pressProgress: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showLockedAlert = false
    
    // Haptic feedback generators
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        ZStack {
            // Ceramic White Background
            Color(hex: "#F8F9FA")
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer()
                
                // Main Floating Pulse Button
                FloatingPulseButton(
                    isPressing: $isPressing,
                    pressProgress: $pressProgress,
                    pulseScale: $pulseScale,
                    timeRemaining: viewModel.timeRemainingString,
                    timePercentage: viewModel.timeRemainingPercentage
                )
                .frame(width: 320, height: 320)
                .gesture(
                    LongPressGesture(minimumDuration: 1.5)
                        .onChanged { _ in
                            handlePressStart()
                        }
                        .onEnded { _ in
                            handlePressEnd()
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressing {
                                // Crisp, light tap
                                lightImpact.impactOccurred()
                                isPressing = true
                                startPressAnimation()
                            }
                        }
                        .onEnded { _ in
                            if isPressing && pressProgress < 1.0 {
                                cancelPress()
                            }
                        }
                )
                
                Spacer()
                
                // Bottom Frosted Glass Cards
                HStack(spacing: 16) {
                    FrostedCard(
                        title: "上次打卡",
                        value: viewModel.lastCheckIn,
                        style: .relative
                    )
                    
                    FrostedCard(
                        title: "連續天數",
                        value: "\(viewModel.streakDays) 天",
                        style: .text
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            startPulseAnimation()
        }
        .alert("帳號已鎖定", isPresented: $showLockedAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("您的帳號已因超過 48 小時未打卡而鎖定。\n未來將提供付費重新啟用功能。")
        }
        .onChange(of: viewModel.isAccountLocked) { newValue in
            if newValue {
                showLockedAlert = true
            }
        }
    }
    
    private func handlePressStart() {
        // Check if account is locked
        if viewModel.isAccountLocked {
            showLockedAlert = true
            return
        }
        
        if pressProgress >= 1.0 {
            // Success haptic - distinct click pattern
            heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                mediumImpact.impactOccurred()
            }
            
            viewModel.checkIn()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressing = false
                pressProgress = 0
            }
        }
    }
    
    private func handlePressEnd() {
        // Fallback
    }
    
    private func startPressAnimation() {
        withAnimation(.linear(duration: 1.5)) {
            pressProgress = 1.0
        }
        
        // Build-up vibration during press
        var hapticStep = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            if isPressing && pressProgress < 1.0 {
                hapticStep += 1
                let intensity = CGFloat(min(hapticStep, 10)) / 10.0
                
                if intensity < 0.4 {
                    lightImpact.impactOccurred(intensity: intensity)
                } else if intensity < 0.7 {
                    mediumImpact.impactOccurred(intensity: intensity)
                } else {
                    heavyImpact.impactOccurred(intensity: intensity)
                }
            } else {
                timer.invalidate()
            }
        }
        timer.fire()
    }
    
    private func cancelPress() {
        // Light tap on cancel
        lightImpact.impactOccurred()
        withAnimation(.easeOut(duration: 0.2)) {
            isPressing = false
            pressProgress = 0
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.03
        }
    }
}

// MARK: - Floating Pulse Button Component
struct FloatingPulseButton: View {
    @Binding var isPressing: Bool
    @Binding var pressProgress: CGFloat
    @Binding var pulseScale: CGFloat
    let timeRemaining: String
    let timePercentage: Double
    
    // Dynamic colors based on time remaining
    private var ringColors: [Color] {
        if timePercentage <= 0 {
            return [Color(hex: "#FF3B30"), Color(hex: "#FF6B6B")] // Red
        } else if timePercentage < 0.25 {
            return [Color(hex: "#FF3B30"), Color(hex: "#FF6B6B")] // Red
        } else if timePercentage < 0.5 {
            return [Color(hex: "#FF9500"), Color(hex: "#FFCC00")] // Orange
        } else if timePercentage < 0.75 {
            return [Color(hex: "#FFCC00"), Color(hex: "#FFD60A")] // Yellow
        } else {
            return [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")] // Blue/Cyan
        }
    }

    
    var body: some View {
        ZStack {
            // Soft colored shadow (floating effect)
            Circle()
                .fill(
                    LinearGradient(
                        colors: ringColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .opacity(0.2)
                .offset(y: 15)
            
            // Progress Arc (Time Left)
            Circle()
                .trim(from: 0, to: CGFloat(timePercentage))
                .stroke(
                    LinearGradient(
                        colors: ringColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 300, height: 300)
            
            // Main Ring Border
            Circle()
                .stroke(
                    LinearGradient(
                        colors: ringColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 260, height: 260)
                .shadow(color: ringColors[0].opacity(0.25), radius: 20, x: 0, y: 10)
                .scaleEffect(pulseScale)
            
            // Press Progress Ring
            if isPressing {
                Circle()
                    .trim(from: 0, to: pressProgress)
                    .stroke(
                        Color(hex: "#333333").opacity(0.6),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 250, height: 250)
            }
            
            // Inner Circle (Ceramic Surface)
            Circle()
                .fill(Color(hex: "#FAFBFC"))
                .frame(width: 240, height: 240)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .scaleEffect(isPressing ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isPressing)
            
            // Content
            VStack(spacing: 10) {
                Text("報平安")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#333333"))
                
                Text("Life Check")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "#666666"))
                    .tracking(2)
                
                Spacer().frame(height: 12)
                
                Image(systemName: "touchid")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: ringColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.7)
                
                Spacer().frame(height: 8)
                
                Text(timeRemaining)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: ringColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

// MARK: - Frosted Glass Card Component
struct FrostedCard: View {
    let title: String
    let value: Any
    let style: DisplayStyle
    
    enum DisplayStyle {
        case relative
        case text
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#666666"))
                .tracking(1)
            
            if style == .relative, let date = value as? Date {
                Text(date, style: .relative)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#333333"))
            } else if let text = value as? String {
                Text(text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#333333"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
