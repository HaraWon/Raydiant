import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(0)
                    .tabItem { Label("Today", systemImage: "sun.max") }

                ForecastView()
                    .tag(1)
                    .tabItem { Label("Forecast", systemImage: "calendar") }

                TanPlanView()
                    .tag(2)
                    .tabItem { Label("Tan Plan", systemImage: "sparkles") }

                FriendsView()
                    .tag(3)
                    .tabItem { Label("Friends", systemImage: "person.2") }

                ProfileView()
                    .tag(4)
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
            .tint(.white)
            // Style the tab bar
            .onAppear { configureTabBar() }
        }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        itemAppearance.selected.iconColor = UIColor.white
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
