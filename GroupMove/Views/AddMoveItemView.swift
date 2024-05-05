//
//  AddMoveItemView.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-04-30.
//

import SwiftUI

struct AddMoveItemView: View {
    @Environment(\.dismiss) var done
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedMoveItem: MoveItem?
    @State private var name: String
    @State private var price: Float?
    @State private var room: Room
    @State private var owner: String
    
    private var stack = CoreDataStack.shared
    
    var property: Property
    var rooms: [Room]
    var hasBudget: Bool
    
    init(passedMoveItem: MoveItem?, passedProperty: Property) {
        property = passedProperty
        if let allRooms = property.rooms?.allObjects as? [Room] {
            rooms = allRooms.sorted(by: { $0.orderIndex < $1.orderIndex })
        } else {
            rooms = []
        }
        hasBudget = property.hasBudget
        
        if let moveItem = passedMoveItem {
            _selectedMoveItem = State(initialValue: moveItem)
            _name = State(initialValue: moveItem.name ?? "")
            _price = State(initialValue: Float(moveItem.price))
            _room = State(initialValue: moveItem.room!)
            _owner = State(initialValue: moveItem.owner ?? "")
        } else {
            _name = State(initialValue: "")
            _price = State(initialValue: Float(0))
            _room = State(initialValue: rooms[0])
            _owner = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item Name", text: $name)
                }
                if hasBudget {
                    Section("Price") {
                        TextField("Price", value: $price, format: .number)
                         .keyboardType(.decimalPad)
                    }
                }
                Section("Room") {
                    Picker("Room", selection: $room) {
                        if !rooms.isEmpty {
                            ForEach(rooms, id:\.self) {
                                Text($0.name ?? "Untitled")
                            }
                        } else {
                            Text("Untitled").tag(Room())
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        done()
                    }.foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveItem()
                    }
                }
            }
        }
    }
    
    func saveItem() {
        withAnimation {
            if selectedMoveItem == nil {
                selectedMoveItem = MoveItem(context: viewContext)
            }
            
            selectedMoveItem?.name = name
            selectedMoveItem?.price = Float(price ?? 0)
            selectedMoveItem?.room = room
            selectedMoveItem?.dateCreated = Date()
            selectedMoveItem?.owner = name
            
            property.addToItems(selectedMoveItem!)
            
            stack.save()
        }
        done()
    }
}



#Preview {
    var viewContext = CoreDataStack.shared.context
    
    let property = PreviewManager.shared.getBasicPropertyWithRooms(context: viewContext)
    
    return AddMoveItemView(passedMoveItem: nil, passedProperty: property)
}
