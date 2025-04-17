//
//  NoteDetailsFeature.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct NoteDetailsFeature {
    @ObservableState
    struct State: Equatable {
        var note: Note
        var editedTitle: String
        var editedContent: String
        var categories: [Category] = []
        var selectedCategoryID: UUID?
        @Presents var alert: AlertState<Action.Alert>?
        
        init(note: Note) {
            self.note = note
            self.editedTitle = note.title
            self.editedContent = note.content
            self.selectedCategoryID = note.category?.id
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case saveButtonTapped
        case categoriesLoaded([Category])
        case deleteButtonTapped
        case alert(PresentationAction<Alert>)
        
        enum Alert {
            case confirmDeletion
        }
    }
    
    @Dependency(\.notesService) var notesService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let categories = try await notesService.fetchCategories()
                    await send(.categoriesLoaded(categories))
                }
                
            case let .categoriesLoaded(categories):
                state.categories = categories
                return .none
                
            case .saveButtonTapped:
                state.note.title = state.editedTitle
                state.note.content = state.editedContent
                
                if let categoryID = state.selectedCategoryID,
                   let category = state.categories.first(where: { $0.id == categoryID }) {
                    state.note.category = category
                } else {
                    state.note.category = nil
                }
                
                return .run { [note = state.note] send in
                    try await notesService.updateNote(note)
                    await self.dismiss()
                }
                
            case .deleteButtonTapped:
                state.alert = AlertState {
                    TextState("Delete Note")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete this note? This cannot be undone.")
                }
                return .none
                
            case .alert(.presented(.confirmDeletion)):
                return .run { [note = state.note] send in
                    try await notesService.deleteNote(note)
                    await self.dismiss()
                }
                
            case .alert(.dismiss):
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
