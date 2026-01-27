import SwiftUI
import UserNotifications

struct TutorialView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0
    
    let pages = [
        TutorialPage(image: "clock.arrow.circlepath", title: "每日打卡", description: "每天記得打開 App 報平安，\n系統會重置您的 48 小時倒數計時。"),
        TutorialPage(image: "hourglass", title: "自動倒數", description: "若您未在時間內打卡，\n系統將認定您可能發生意外。"),
        TutorialPage(image: "envelope.fill", title: "發送遺言", description: "計時結束後，系統將自動把您預設的遺言\n發送給指定的緊急聯絡人。")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F7FA").edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        requestNotificationPermission()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "下一步" : "開始使用")
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                onComplete()
            }
        }
    }
}

struct TutorialPage {
    let image: String
    let title: String
    let description: String
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.image)
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding()
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 200, height: 200)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "#333333"))
            
            Text(page.description)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#666666"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineSpacing(6)
        }
        .padding()
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(onComplete: {})
    }
}
