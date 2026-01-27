import SwiftUI

struct OnboardingContainerView: View {
    enum OnboardingStep {
        case welcome
        case legal
        case tutorial
    }
    
    @State private var currentStep: OnboardingStep = .welcome
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView {
                    withAnimation {
                        currentStep = .legal
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            
            case .legal:
                LegalView {
                    withAnimation {
                        currentStep = .tutorial
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            case .tutorial:
                TutorialView {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView()
    }
}
