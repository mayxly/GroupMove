//
//  PropertyManager.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-31.
//

import Foundation

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
}
