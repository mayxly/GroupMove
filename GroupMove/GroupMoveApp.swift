//
//  GroupMoveApp.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-27.
//

import SwiftUI
import CoreData

@main
struct GroupMoveApp: App {
    let stack = CoreDataStack.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environment(\.managedObjectContext, stack.context)
                .environment(\.font, Font.custom("Satoshi Variable", size: 16))
        }
    }
}

struct LoadingScreen: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Property.dateCreated, ascending: true)],
        animation: .default)
    private var homes: FetchedResults<Property>
    let stack = CoreDataStack.shared
    private var propertyManager = PropertyManager.shared
    
    @State private var isLoaded = false
    
    var body: some View {
        VStack {
            if isLoaded {
                PropertyView()
            } else {
                Text("Loading")
            }
        }.onAppear {
            let activeProperty = getActiveProperty()
            propertyManager.activeProperty = activeProperty
            isLoaded = true
        }
    }
    
    private func getActiveProperty() -> Property {
        for home in homes {
            if home.active {
                return home
            }
        }
        return createNewProperty()
    }
    
    private func createNewProperty() -> Property {
        let newProperty = Property(context: stack.context)
        
        newProperty.name = "My Home"
        
        newProperty.budget = 0
        newProperty.hasBudget = false
        
        newProperty.dateCreated = Date()
        newProperty.color = "00A5E3"
        
        for room in createDefaultRooms() {
            newProperty.addToRooms(room)
        }
        
        // Set as active
        newProperty.active = true
        
        stack.save()
        return newProperty
    }
    
    private func createDefaultRooms() -> [Room] {
        var defaultRooms = [Room]()
        
        let kitchen = Room(context: stack.context)
        kitchen.name = "Kitchen"
        kitchen.orderIndex = 0
        let livingRoom = Room(context: stack.context)
        livingRoom.name = "Living Room"
        livingRoom.orderIndex = 1
        
        defaultRooms.append(kitchen)
        defaultRooms.append(livingRoom)
        
        return defaultRooms
    }
}
