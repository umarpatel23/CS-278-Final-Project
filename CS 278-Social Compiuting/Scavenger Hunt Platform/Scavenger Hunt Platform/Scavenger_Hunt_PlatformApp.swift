//
//  Scavenger_Hunt_PlatformApp.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/25/24.
//

import SwiftUI
import SwiftData

@main
struct Scavenger_Hunt_PlatformApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScavengerHunt.self,
            User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
