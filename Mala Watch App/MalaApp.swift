import SwiftUI

@main
struct MalaApp: App {
    @StateObject private var watchSession = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchSession)
        }
    }
}
