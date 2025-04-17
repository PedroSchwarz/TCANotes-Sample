import ComposableArchitecture
import SwiftData
import Foundation

final class ModelContextWrapper: @unchecked Sendable {
    let context: ModelContext
    private let queue = DispatchQueue(label: "com.app.ModelContextQueue")
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func perform<T>(_ operation: @escaping (ModelContext) throws -> T) throws -> T {
        try queue.sync {
            try operation(context)
        }
    }
    
    func performAsync<T>(_ operation: @escaping (ModelContext) throws -> T) async throws -> T {
        try await Task {
            try self.queue.sync {
                try operation(context)
            }
        }.value
    }
}

// Dependency key for model context wrapper
private enum ModelContextWrapperKey: DependencyKey {
    static var liveValue: ModelContextWrapper {
        // This is a placeholder that should be overridden
        fatalError("ModelContextWrapper not configured. Use withDependencies to configure this value.")
    }
}

extension DependencyValues {
    var modelContextWrapper: ModelContextWrapper {
        get { self[ModelContextWrapperKey.self] }
        set { self[ModelContextWrapperKey.self] = newValue }
    }
}
