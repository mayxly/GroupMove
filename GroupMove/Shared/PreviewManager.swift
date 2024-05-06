//
//  PreviewManager.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-04-30.
//

import Foundation
import CoreData

class PreviewManager {
    static let shared = PreviewManager()
    
    func getBasicProperty(context: NSManagedObjectContext) -> Property {
        let newProperty = Property(context: context)
        newProperty.name = "Blair House"
        newProperty.color = "00A5E3"
        newProperty.dateCreated = Date()
        
        return newProperty
    }
    
    func getBasicPropertyWithRooms(context: NSManagedObjectContext) -> Property {
        let newProperty = Property(context: context)
        newProperty.name = "Blair House"
        newProperty.color = "00A5E3"
        newProperty.dateCreated = Date()
        
        let kitchen = Room(context: context)
        kitchen.name = "Kitchen"
        kitchen.orderIndex = 0
        
        let livingRoom = Room(context: context)
        livingRoom.name = "Living Room"
        livingRoom.orderIndex = 1
        
        newProperty.addToRooms(kitchen)
        newProperty.addToRooms(livingRoom)
        
        return newProperty
    }
    
    func getPropertyWithItemsAndRooms(context: NSManagedObjectContext) -> Property {
        let myProperty = getBasicProperty(context: context)
        
        let kitchen = Room(context: context)
        kitchen.name = "Kitchen"
        kitchen.orderIndex = 0
        
        let bedroom = Room(context: context)
        bedroom.name = "Bedroom"
        bedroom.orderIndex = 1
        
        let microwave = MoveItem(context: context)
        microwave.name = "Microwave"
        microwave.owner = ""
        microwave.dateCreated = Date()
        microwave.room = kitchen
        
        let lamp = MoveItem(context: context)
        lamp.name = "Lamp"
        lamp.owner = ""
        lamp.dateCreated = Date()
        lamp.room = bedroom
        
        myProperty.addToRooms(kitchen)
        myProperty.addToRooms(bedroom)
        
        myProperty.addToItems(microwave)
        myProperty.addToItems(lamp)
        
        return myProperty
    }
    
    func getMoveItem(context: NSManagedObjectContext) -> MoveItem {
        let bedroom = Room(context: context)
        bedroom.name = "Bedroom"
        bedroom.orderIndex = 1
        
        let lamp = MoveItem(context: context)
        lamp.name = "Lamp"
        lamp.owner = "May Ly"
        lamp.price = 0
        lamp.dateCreated = Date()
        lamp.room = bedroom
        return lamp
    }
    
    private init() {}
}
