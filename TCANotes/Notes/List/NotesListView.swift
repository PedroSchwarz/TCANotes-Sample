//
//  NotesListView.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import ComposableArchitecture

struct NotesListView: View {
    @Bindable var store: StoreOf<NotesListFeature>
    
    var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(store.filteredNotes) { note in
                        Button {
                            store.send(.noteSelected(note))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                
                                Text(note.updatedAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                store.send(.deleteNote(note))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .searchable(text: $store.searchText, prompt: "Search notes")
                .overlay {
                    if store.notes.isEmpty {
                        ContentUnavailableView(
                            label: {
                                Label("No Notes", systemImage: "note.text")
                            },
                            description: {
                                Text("Create your first note by tapping the add button")
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    Label("Add Note", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        store.send(.categoriesButtonTapped)
                    } label: {
                        Label("Categories", systemImage: "folder")
                    }
                    
                    Button {
                        store.send(.settingsButtonTapped)
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    NotesListView(store: .init(initialState: NotesListFeature.State(), reducer: {
        NotesListFeature()
    }))
}
