//
//  NotesService+Live.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import Foundation
import SwiftData
import Dependencies

extension NotesService: DependencyKey {
    static var liveValue: NotesService {
        @Dependency(\.modelContextWrapper) var modelContextWrapper
        
        return .init(
            fetchNotes: {
                let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
                return try await modelContextWrapper.performAsync { context in
                    try context.fetch(descriptor)
                }
            },
            fetchNote: { id in
                let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == id })
                return try await modelContextWrapper.performAsync { context in
                    let notes = try context.fetch(descriptor)
                    return notes.first
                }
            },
            saveNote: { note in
                try await modelContextWrapper.performAsync { context in
                    context.insert(note)
                    try context.save()
                }
            },
            deleteNote: { note in
                try await modelContextWrapper.performAsync { context in
                    context.delete(note)
                    try context.save()
                }
            },
            updateNote: { note in
                note.updatedAt = Date()
                try await modelContextWrapper.performAsync { context in
                    note.updatedAt = Date()
                    try context.save()
                }
            },
            fetchCategories: {
                let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
                return try await modelContextWrapper.performAsync { context in
                    try context.fetch(descriptor)
                }
            },
            fetchCategory: { id in
                let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.id == id })
                return try await modelContextWrapper.performAsync { context in
                    let categories = try context.fetch(descriptor)
                    return categories.first
                }
            },
            saveCategory: { category in
                try await modelContextWrapper.performAsync { context in
                    context.insert(category)
                    try context.save()
                }
            },
            deleteCategory: { category in
                try await modelContextWrapper.performAsync { context in
                    context.delete(category)
                    try context.save()
                }
            },
            updateCategory: { category in
                try await modelContextWrapper.performAsync { context in
                    try context.save()
                }
            }
        )
    }
}

extension DependencyValues {
    var notesService: NotesService {
        get { self[NotesService.self] }
        set { self[NotesService.self] = newValue }
    }
}
