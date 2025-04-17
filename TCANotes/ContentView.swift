//
//  ContentView.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            NotesListView(store: store.scope(state: \.notesList, action: \.notesList))
        } destination: { store in
            switch store.case {
            case let .details(store):
                NoteDetailsView(store: store)
            case let .categoryList(store):
                CategoriesListView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            }
        }
    }
}

#Preview {
    let previewContainer = {
            let schema = Schema([Note.self, Category.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                
                // Add sample data
                let work = Category(name: "Work")
                let personal = Category(name: "Personal")
                container.mainContext.insert(work)
                container.mainContext.insert(personal)
                
                let notes = [
                    Note(title: "Meeting Notes", content: "Discuss project timeline and deliverables", category: work),
                    Note(title: "Shopping List", content: "Milk, Eggs, Bread", category: personal),
                    Note(title: "Book Ideas", content: "A novel about time travel", category: personal),
                    Note(title: "Project Tasks", content: "1. Update documentation\n2. Fix bugs\n3. Implement new features", category: work)
                ]
                
                for note in notes {
                    container.mainContext.insert(note)
                }
                
                return container
            } catch {
                fatalError("Could not create preview ModelContainer: \(error)")
            }
        }()
    
    return ContentView(store: .init(initialState: .init(), reducer: {
        AppFeature()
    }, withDependencies: {
        $0.modelContextWrapper = ModelContextWrapper(context: previewContainer.mainContext)
    }))
    .modelContainer(previewContainer)
}
