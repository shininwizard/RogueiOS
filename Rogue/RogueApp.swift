import SwiftUI

@main
struct RogueApp: App {
    var hero = HeroController()
    var instance = InstanceController()
    var state = StateController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hero)
                .environmentObject(instance)
                .environmentObject(state)
        }
    }
}
