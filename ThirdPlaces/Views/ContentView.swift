import SwiftUI

struct ContentView: View {
    @MainActor @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: userViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            LeaderboardView(viewModel: userViewModel)
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
            
            ProfileView(viewModel: userViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
