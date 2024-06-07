//
//  PropertyManager.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-31.
//

import CoreData
import SwiftUI

class PropertyManager: ObservableObject {
    static let shared = PropertyManager()
    
    @Published var activeProperty: Property?
    
    private init() {}
}

extension PropertyManager {
    func setNewActiveProperty(property: Property) {
        let stack = CoreDataStack.shared
        
        property.active = true
        activeProperty?.active = false
        activeProperty = property
    
        stack.save()
    }
    
    func deleteActiveProperty(newProperty: Property) {
        let stack = CoreDataStack.shared
        
        if let items = activeProperty?.items?.allObjects as? [MoveItem] {
            for item in items {
                stack.deleteMoveItem(item)
            }
        }
        if let rooms = activeProperty?.rooms?.allObjects as? [Room] {
            for room in rooms {
                stack.deleteRoom(room)
            }
        }
        
        stack.deleteProperty(activeProperty!)
        
        newProperty.active = true
        activeProperty = newProperty
        
        stack.save()
    }
}
