//
//  NotesListFeature.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import ComposableArchitecture

@Reducer
struct NotesListFeature {
    @ObservableState
    struct State: Equatable {
        var notes: [Note] = []
        var isLoading = false
        var searchText = ""
        var noteToDelete: Note?
        @Presents var alert: AlertState<Action.Alert>?
        
        var filteredNotes: [Note] {
            if searchText.isEmpty {
                return notes
            }
            return notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case notesLoaded([Note])
        case noteSelected(Note)
        case addButtonTapped
        case deleteNote(Note)
        case categoriesButtonTapped
        case settingsButtonTapped
        case alert(PresentationAction<Alert>)
        
        enum Alert {
            case confirmDeletion
        }
    }
    
    @Dependency(\.notesService) var notesService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                
                return .merge(
                    .run { send in
                        let notes = try await notesService.fetchNotes()
                        await send(.notesLoaded(notes))
                    },
                )
                
            case let .notesLoaded(notes):
                state.notes = notes
                state.isLoading = false
                return .none
                
            case .noteSelected:
                return .none
                
            case .addButtonTapped:
                let newNote = Note(title: "New Note", content: "")
                
                return .run { send in
                    try await notesService.saveNote(newNote)
                    await send(.onAppear)
                }
                
            case let .deleteNote(note):
                state.noteToDelete = note
                
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
                
            case .categoriesButtonTapped, .settingsButtonTapped:
                return .none
                
            case .alert(.presented(.confirmDeletion)):
                guard let note = state.noteToDelete else { return .none }
                state.noteToDelete = nil
                
                return .run { send in
                    try await notesService.deleteNote(note)
                    await send(.onAppear)
                }
                
            case .alert(.dismiss):
                state.noteToDelete = nil
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
