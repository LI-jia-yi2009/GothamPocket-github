import SwiftUI

@main
struct GothamPocketApp: App {
    @StateObject private var store = PetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
