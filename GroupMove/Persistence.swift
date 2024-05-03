//
//  Persistence.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-27.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Example
        let newProperty = Property(context: viewContext)
        newProperty.name = "Blair House"
        newProperty.color = "00A5E3"
        newProperty.dateCreated = Date()
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GroupMove")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // From CoreDataStack
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
          fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
        
        // Cloudkit Sharing
        
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
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
