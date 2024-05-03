//
//  ContentView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-27.
//

import SwiftUI
import CoreData

struct MoveItemView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoveItem.dateCreated, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MoveItem>

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items) { item in
                        NavigationLink(destination: AddMoveItemView(passedMoveItem: nil)) {
                            Text(item.name!)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MoveItemView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
