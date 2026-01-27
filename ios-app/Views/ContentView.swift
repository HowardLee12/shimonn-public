import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Check-In", systemImage: "checkmark.circle.fill")
                }
            
            ContactsView()
                .tabItem {
                    Label("Contacts", systemImage: "person.2.fill")
                }
            
            MessageView()
                .tabItem {
                    Label("Message", systemImage: "envelope.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
