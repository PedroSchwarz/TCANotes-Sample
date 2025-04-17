//
//  CategoriesListView.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import ComposableArchitecture

struct CategoriesListView: View {
    @Bindable var store: StoreOf<CategoriesListFeature>
    
    var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
            } else {
                List {
                    Section(header: Text("Add Category")) {
                        HStack {
                            TextField("New Category", text: $store.newCategoryName)
                            
                            Button {
                                store.send(.addCategoryButtonTapped)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(store.newCategoryName.isEmpty)
                        }
                    }
                    
                    Section(header: Text("Categories")) {
                        if store.categories.isEmpty {
                            Text("No categories")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(store.categories) { category in
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                    Text("\(category.notes?.count ?? 0) notes")
                                        .foregroundColor(.secondary)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.send(.deleteCategory(category))
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    CategoriesListView(store: .init(initialState: .init(), reducer: {
        CategoriesListFeature()
    }))
}
