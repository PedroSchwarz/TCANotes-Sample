//
//  NotesService.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
struct NotesService {
    var fetchNotes: @Sendable () async throws -> [Note] = { [] }
    var fetchNote: @Sendable (UUID) async throws -> Note? = { _ in nil }
    var saveNote: @Sendable (Note) async throws -> Void = { _ in }
    var deleteNote: @Sendable (Note) async throws -> Void = { _ in }
    var updateNote: @Sendable (Note) async throws -> Void = { _ in }
    
    var fetchCategories: @Sendable () async throws -> [Category] = { [] }
    var fetchCategory: @Sendable (UUID) async throws -> Category? = { _ in nil }
    var saveCategory: @Sendable (Category) async throws -> Void = { _ in }
    var deleteCategory: @Sendable (Category) async throws -> Void = { _ in }
    var updateCategory: @Sendable (Category) async throws -> Void = { _ in }
}
