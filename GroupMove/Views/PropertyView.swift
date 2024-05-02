//
//  PropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI
import CoreData
import CloudKit

struct PropertyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var property: Property
    
    @State private var roomItemMap = [String: [MoveItem]]()
    
    @State private var showingSheet = false
    
    // CloudKit Sharing
    @State private var share: CKShare?
    @State private var showShareSheet = false
    private let stack = CoreDataStack.shared
    
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
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                  if !stack.isShared(object: property) {
                    Task {
                      await createShare(property)
                    }
                  }
                  showShareSheet = true
              } label: {
                Image(systemName: "square.and.arrow.up")
              }
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            generateRoomAndItemMapping()
        }){
            AddMoveItemView(passedMoveItem: nil, passedProperty: property)
        }
        .sheet(isPresented: $showShareSheet) {
            if let share = share {
              CloudSharingView(
                share: share,
                container: stack.ckContainer,
                property: property
              )
            }
        }
        .onAppear {
            generateRoomAndItemMapping()
        }
    }
    
    private func generateRoomAndItemMapping() {
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
    
    private func createShare(_ property: Property) async {
      do {
        let (_, share, _) =
        try await stack.persistentContainer.share([property], to: nil)
        share[CKShare.SystemFieldKey.title] = property.name
        self.share = share
      } catch {
        print("Failed to create share")
      }
    }
}


struct PropertyView_Previews: PreviewProvider {
    static var viewContext = CoreDataStack.shared.context
    
    static var previews: some View {
        let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
        
        return PropertyView(property: property)
    }
}
