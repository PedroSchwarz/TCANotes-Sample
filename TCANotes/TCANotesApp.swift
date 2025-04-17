//
//  TCANotesApp.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct TCANotesApp: App {
    let store: StoreOf<AppFeature>
    let container: ModelContainer
    
    init() {
        let schema = Schema([Note.self, Category.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let wrapper = ModelContextWrapper(context: container.mainContext)
            
            // Configure the store with dependencies
            self.store = Store(initialState: AppFeature.State()) {
                AppFeature()
            } withDependencies: {
                $0.modelContextWrapper = wrapper
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .modelContainer(container)
        }
    }
}
