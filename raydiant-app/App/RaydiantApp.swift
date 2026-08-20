import SwiftUI

@main
struct RaydiantApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(appState)
                } else {
                    OnboardingView()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
        }
    }
}
