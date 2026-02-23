import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    
    var body: some View {
        ZStack {
            AmbientBackground()
            
            ZStack {
                switch store.flow {
                case .onboarding:
                    OnboardingView()
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                case .hub:
                    HubView()
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                case .journey(let kind):
                    ExperienceJourneyWrapper(kind: kind)
                        .transition(.opacity)
                case .synthesis:
                    SynthesisView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 1.2), value: store.flow)

            
            if store.flow != .onboarding {
                VStack {
                    Spacer()
                    BottomDock()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .ignoresSafeArea(.keyboard)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: store.flow)
            }
            
            if store.showMenu {
                CalmMenuOverlay()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
}
