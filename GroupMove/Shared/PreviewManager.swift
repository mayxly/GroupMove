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
    
    func getPropertyWithItemsAndRooms(context: NSManagedObjectContext) -> Property {
        let myProperty = getBasicProperty(context: context)
        
        let kitchen = Room(context: context)
        kitchen.name = "Kitchen"
        
        let bedroom = Room(context: context)
        bedroom.name = "Bedroom"
        
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
    
    private init() {}
}
