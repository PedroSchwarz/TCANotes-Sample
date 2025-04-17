//
//  NoteDetailsView.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import ComposableArchitecture

struct NoteDetailsView: View {
    @Bindable var store: StoreOf<NoteDetailsFeature>
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $store.editedTitle)
                    .font(.headline)
            }
            
            Section(header: Text("Category")) {
                Picker("Category", selection: $store.selectedCategoryID) {
                    Text("None").tag(nil as UUID?)
                    
                    ForEach(store.categories) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }
            }
            
            Section(header: Text("Content")) {
                TextEditor(text: $store.editedContent)
                    .frame(minHeight: 200)
            }
            
            Section {
                Button(role: .destructive) {
                    store.send(.deleteButtonTapped)
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Note")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    store.send(.saveButtonTapped)
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
    NoteDetailsView(store: .init(initialState: .init(note: Note(title: "Note", content: "Content")), reducer: {
        NoteDetailsFeature()
    }))
}
