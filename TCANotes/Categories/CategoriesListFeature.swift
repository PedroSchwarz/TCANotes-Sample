//
//  CategoriesListFeature.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import ComposableArchitecture

@Reducer
struct CategoriesListFeature {
    @ObservableState
    struct State: Equatable {
        var categories: [Category] = []
        var isLoading = false
        var newCategoryName = ""
        var categoryToDelete: Category?
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case categoriesLoaded([Category])
        case addCategoryButtonTapped
        case deleteCategory(Category)
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
                
                return .run { send in
                    let categories = try await notesService.fetchCategories()
                    await send(.categoriesLoaded(categories))
                }
                
            case let .categoriesLoaded(categories):
                state.categories = categories
                state.isLoading = false
                return .none
                
            case .addCategoryButtonTapped:
                guard !state.newCategoryName.isEmpty else { return .none }
                
                let newCategory = Category(name: state.newCategoryName)
                state.newCategoryName = ""
                
                return .run { send in
                    try await notesService.saveCategory(newCategory)
                    await send(.onAppear)
                }
                
            case let .deleteCategory(category):
                state.categoryToDelete = category
                
                state.alert = AlertState {
                    TextState("Delete Category")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete '\(category.name)'? All notes in this category will be uncategorized.")
                }
                return .none
                
            case .alert(.presented(.confirmDeletion)):
                guard let category = state.categoryToDelete else { return .none }
                state.categoryToDelete = nil
                
                return .run { send in
                    try await notesService.deleteCategory(category)
                    await send(.onAppear)
                }
                
            case .alert(.dismiss):
                state.categoryToDelete = nil
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
