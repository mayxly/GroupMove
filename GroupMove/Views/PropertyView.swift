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
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack {
            List {
                if let items = property.items?.allObjects as? [MoveItem] {
                    ForEach(items.sorted(by: { $0.dateCreated! > $1.dateCreated! })) {item in
                      Text(item.name!)
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
        .sheet(isPresented: $showingSheet) {
            AddMoveItemView(passedMoveItem: nil, passedProperty: property)
        }
    }
}


struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView(property: Property()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
