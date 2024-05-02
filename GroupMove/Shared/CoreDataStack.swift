//
//  CoreDataStack.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-01.
//

import CoreData
import CloudKit

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var privatePersistentStore: NSPersistentStore {
        guard let privateStore = _privatePersistentStore else {
            fatalError("Private store is not set")
        }
        return privateStore
    }
    
    var sharedPersistentStore: NSPersistentStore {
        guard let sharedStore = _sharedPersistentStore else {
            fatalError("Shared store is not set")
        }
        return sharedStore
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "GroupMove")
        
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
        
        // TODO: 1
        let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription
            .copy() as? NSPersistentStoreDescription else {
            fatalError(
                "Copying the private store description returned an unexpected value."
            )
        }
        sharedStoreDescription.url = sharedStoreURL
        
        // TODO: 2
        guard let containerIdentifier = privateStoreDescription
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get containerIdentifier")
        }
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: containerIdentifier
        )
        sharedStoreOptions.databaseScope = .shared
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        // TODO: 3
        container.persistentStoreDescriptions.append(sharedStoreDescription)
        
        // TODO: 4
        
        container.loadPersistentStores { loadedStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            } else if let cloudKitContainerOptions = loadedStoreDescription
                .cloudKitContainerOptions {
                guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
                    return
                }
                if cloudKitContainerOptions.databaseScope == .private {
                    let privateStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._privatePersistentStore = privateStore
                } else if cloudKitContainerOptions.databaseScope == .shared {
                    let sharedStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._sharedPersistentStore = sharedStore
                }
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    private init() {}
}

// MARK: Save or delete from Core Data
extension CoreDataStack {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ViewContext save error: \(error)")
            }
        }
    }
    
//    func delete(_ destination: Destination) {
//        context.perform {
//            self.context.delete(destination)
//            self.save()
//        }
//    }
}
