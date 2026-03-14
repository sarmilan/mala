import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("Practice", systemImage: "circle.fill") }
            SessionLogView()
                .tabItem { Label("Log", systemImage: "scroll") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .preferredColorScheme(.dark)
    }
}
