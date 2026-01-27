import SwiftUI

struct WelcomeView: View {
    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "#F5F7FA").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                    // Icon with glow effect
                    ZStack {
                        Image("GhostSayHi")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                    }
                
                VStack(spacing: 16) {
                    Text("Shimonn")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(hex: "#333333"))
                    
                    Text("守護您的最後訊息\n為摯愛留下永恆的叮嚀")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#666666"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                
                Spacer()
                
                Button(action: onNext) {
                    Text("開始使用")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "#4FACFE").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}
