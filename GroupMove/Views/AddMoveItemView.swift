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
    @State private var room: Room?
    @State private var owner: String
    
    var property: Property
    var rooms: [Room]
    
    init(passedMoveItem: MoveItem?, passedProperty: Property) {
        property = passedProperty
        if let allRooms = property.rooms?.allObjects as? [Room] {
            rooms = allRooms
        } else {
            rooms = []
        }
        
        if let moveItem = passedMoveItem {
            _selectedMoveItem = State(initialValue: moveItem)
            _name = State(initialValue: moveItem.name ?? "")
            _price = State(initialValue: Float(moveItem.price))
            _room = State(initialValue: moveItem.room!)
            _owner = State(initialValue: moveItem.owner ?? "")
        } else {
            _name = State(initialValue: "")
            _room = State(initialValue: nil)
            _owner = State(initialValue: "")
            _price = State(initialValue: Float(0))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item Name", text: $name)
                }
                Section("Price") {
                    TextField("Price", value: $price, format: .number)
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
                    }
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
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        done()
    }
}



#Preview {
    AddMoveItemView(passedMoveItem: nil, passedProperty: Property())
}
