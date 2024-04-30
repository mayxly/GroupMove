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
    @State private var price: Int?
    @State private var room: String
    @State private var owner: String
    
    let rooms = ["Kitchen", "Bedroom", "Living Room"]
    
    init(passedMoveItem: MoveItem?) {
        if let moveItem = passedMoveItem {
            _selectedMoveItem = State(initialValue: moveItem)
            _name = State(initialValue: moveItem.name ?? "")
            _price = State(initialValue: Int(moveItem.price))
            _room = State(initialValue: moveItem.room ?? "")
            _owner = State(initialValue: moveItem.owner ?? "")
        } else {
            _name = State(initialValue: "")
            _room = State(initialValue: "")
            _owner = State(initialValue: "")
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
                        ForEach(rooms, id:\.self) {
                            Text($0)
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
            selectedMoveItem?.price = Int16(price ?? 0)
            selectedMoveItem?.room = name
            selectedMoveItem?.dateCreated = Date()
            selectedMoveItem?.owner = name
            
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
    AddMoveItemView(passedMoveItem: nil)
}
