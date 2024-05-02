//
//  PropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI
import CoreData

struct PropertyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var property: Property
    
    @State private var roomItemMap = [String: [MoveItem]]()
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack {
            List {
                ForEach(roomItemMap.sorted(by: { $0.key < $1.key }), id: \.key) { roomName, items in
                    Section(roomName) {
                        ForEach(items.sorted(by: { $0.dateCreated! > $1.dateCreated! }), id: \.self) { item in
                            Text(item.name ?? "Untitled")
                        }
                    }
                }
            }
        }
        .navigationTitle(property.name ?? "Property")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            generateMapping()
        }){
            AddMoveItemView(passedMoveItem: nil, passedProperty: property)
        }
        .onAppear {
            generateMapping()
        }
    }
    
    func generateMapping() {
        roomItemMap = [:]
        if let items = property.items?.allObjects as? [MoveItem] {
            for item in items {
                let roomName = item.room?.name ?? "Untitled"
                if roomItemMap[roomName] == nil {
                    roomItemMap[roomName] = [item]
                } else {
                    roomItemMap[roomName]?.append(item)
                }
            }
        }
    }
}


struct PropertyView_Previews: PreviewProvider {
    static var viewContext = CoreDataStack.shared.context
    
    static var previews: some View {
        let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
        
        return PropertyView(property: property).environment(\.managedObjectContext, viewContext)
    }
}
