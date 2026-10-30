import SwiftUI

@main
struct VeraApp: App {
    @StateObject private var store = VeraStore.shared
    @State private var selectedQuoteID: String?

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    guard url.scheme == "vera", url.host == "quote" else { return }
                    selectedQuoteID = url.pathComponents.dropFirst().first
                    NotificationCenter.default.post(name: .openVeraQuote, object: selectedQuoteID)
                }
        }
    }
}

extension Notification.Name {
    static let openVeraQuote = Notification.Name("openVeraQuote")
}
