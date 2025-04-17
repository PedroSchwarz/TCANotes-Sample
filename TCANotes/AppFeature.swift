//
//  AppFeature.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var notesList = NotesListFeature.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case notesList(NotesListFeature.Action)
        case path(StackActionOf<Path>)
    }
    
    @Reducer
    enum Path {
        case details(NoteDetailsFeature)
        case categoryList(CategoriesListFeature)
        case settings(SettingsFeature)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.notesList, action: \.notesList) {
            NotesListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .notesList(.noteSelected(note)):
                state.path.append(.details(NoteDetailsFeature.State(note: note)))
                return .none
                
            case .notesList(.categoriesButtonTapped):
                state.path.append(.categoryList(CategoriesListFeature.State()))
                return .none
                
            case .notesList(.settingsButtonTapped):
                state.path.append(.settings(SettingsFeature.State()))
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
