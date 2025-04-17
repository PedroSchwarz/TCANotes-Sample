//
//  Category.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import Foundation
import SwiftData

@Model
final class Category: @unchecked Sendable {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Note.category)
    var notes: [Note]?
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.notes = []
    }
}
