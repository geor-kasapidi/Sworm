import CoreData
import Foundation
import Sworm
import SwormTools
import XCTest

enum TestDB {
    static func perform(
        with store: SQLiteStoreDescription,
        overwriteMergePolicy: Bool = false,
        action: (PersistentContainer) throws -> Void
    ) {
        do {
            let inMemoryStore = store.with(url: .devNull)
            let container = try NSPersistentContainer(store: inMemoryStore, bundle: .module)
            try container.loadPersistentStore()
            try action(.init(managedObjectContext: {
                let context = container.newBackgroundContext()
                if overwriteMergePolicy {
                    context.mergePolicy = NSOverwriteMergePolicy
                }
                return context
            }))
            try container.removePersistentStores()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func schedule(
        with store: SQLiteStoreDescription,
        overwriteMergePolicy: Bool = false,
        action: (PersistentContainer) async throws -> Void
    ) async {
        do {
            let inMemoryStore = store.with(url: .devNull)
            let container = try NSPersistentContainer(store: inMemoryStore, bundle: .module)
            try container.loadPersistentStore()
            try await action(.init(managedObjectContext: {
                let context = container.newBackgroundContext()
                if overwriteMergePolicy {
                    context.mergePolicy = NSOverwriteMergePolicy
                }
                return context
            }))
            try container.removePersistentStores()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
