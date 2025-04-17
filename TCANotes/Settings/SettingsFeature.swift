//
//  SettingsFeature.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("isDarkModeEnabled")) var isDarkModeEnabled = false
        @Shared(.appStorage("notificationEnabled")) var notificationEnabled = true
        var noteCount = 0
        var categoryCount = 0
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case statsLoaded(notes: Int, categories: Int)
    }
    
    @Dependency(\.notesService) var notesService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let notes = try await notesService.fetchNotes()
                    let categories = try await notesService.fetchCategories()
                    await send(.statsLoaded(notes: notes.count, categories: categories.count))
                }
                
            case let .statsLoaded(notes, categories):
                state.noteCount = notes
                state.categoryCount = categories
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
