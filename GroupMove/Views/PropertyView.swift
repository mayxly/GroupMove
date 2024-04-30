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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoveItem.dateCreated, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MoveItem>
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: AddMoveItemView(passedMoveItem: nil)) {
                        Text(item.name!)
                    }
                }
            }
        }
        .navigationTitle("My Property")
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
            AddMoveItemView(passedMoveItem: nil)
        }
    }
}

struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
