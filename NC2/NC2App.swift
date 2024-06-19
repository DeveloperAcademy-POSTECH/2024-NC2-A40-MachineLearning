//
//  NC2App.swift
//  NC2
//
//  Created by DevJonny on 2024/6/15.
//

import SwiftUI
import SwiftData

@main
struct NC2App: App {
    @StateObject private var viewStateManager = ViewStateManager()
    
//    var modelContainer: ModelContainer = {
//        let schema = Schema([Transaction.self])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewStateManager)
        }
//        .modelContainer(modelContainer)
    }
}
