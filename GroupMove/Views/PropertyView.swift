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
    
    @State private var roomItemMap = [Room: [MoveItem]]()
    
    @State private var showAddItemSheet = false
    @State private var showEditPropertySheet = false
    
    // CloudKit Sharing
    @State private var share: CKShare?
    @State private var showShareSheet = false
    private let stack = CoreDataStack.shared
    
    var body: some View {
        VStack {
            ZStack {
                List {
                    ForEach(roomItemMap.sorted(by: { $0.key.orderIndex < $1.key.orderIndex }), id: \.key.orderIndex) { room, items in
                        if let roomName = room.name, items.count > 0, let _ = items[0].name {
                            Section(roomName) {
                                ForEach(items.sorted(by: { $0.dateCreated! > $1.dateCreated! }), id: \.self) { item in
                                    if let itemName = item.name {
                                        NavigationLink(destination: ItemInfoView(item: item, propertyHasBudget: property.hasBudget)) {
                                            Text(itemName)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if roomItemMap.count > 0 {
                        if let share = share {
                            if share.participants.count > 1 {
                                Section("Participants") {
                                    ForEach(share.participants, id: \.self) { participant in
                                        VStack(alignment: .leading) {
                                            Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                                                .font(.headline)
                                            Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
                                                .font(.subheadline)
                                            Text("Role: \(string(for: participant.role))")
                                                .font(.subheadline)
                                            Text("Permissions: \(string(for: participant.permission))")
                                                .font(.subheadline)
                                        }
                                        .padding(.bottom, 8)
                                    }
                                }
                            }
                        }
                    }
                }
                if roomItemMap.count < 1 {
                    VStack {
                        Spacer()
                        Text("You don't have any items\nin your property yet!")
                            .foregroundStyle(.black.opacity(0.6))
                            .padding(.vertical, 10)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            showAddItemSheet.toggle()
                        }) {
                            Text("Add Item")
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(30)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.3), radius: 3, x: 3, y: 3)
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(property.name ?? "Property")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddItemSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                  showShareSheet = true
              } label: {
                Image(systemName: "square.and.arrow.up")
              }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditPropertySheet.toggle()
                } label: {
                    Text("Edit")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showAddItemSheet, onDismiss: {
            generateRoomAndItemMapping()
        }){
            AddMoveItemView(passedMoveItem: nil, passedProperty: property, currUser: getCurrUser(), userList: getAllParticipants())
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
        .sheet(isPresented: $showEditPropertySheet, onDismiss: {
            generateRoomAndItemMapping()
        }) {
            AddPropertyView(passedProperty: property)
        }
        .onAppear {
            generateRoomAndItemMapping()
            self.share = stack.getShare(property)
            if !stack.isShared(object: property) {
                Task {
                    await createShare(property)
                }
            }
        }
    }
    
    private func generateRoomAndItemMapping() {
        print("Updating map")
        roomItemMap = [:]
        if let items = property.items?.allObjects as? [MoveItem] {
            for item in items {
                if let room = item.room {
                    if roomItemMap[room] == nil {
                        roomItemMap[room] = [item]
                    } else {
                        roomItemMap[room]?.append(item)
                    }
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
    
    private func getCurrUser() -> String {
        var user = ""
        if let ownerName = share?.currentUserParticipant?.userIdentity.nameComponents?.formatted(.name(style: .long)) {
            user = ownerName
        }
        return user
    }
    
    private func getAllParticipants() -> [String] {
        var users = [String]()
        
        for participant in share?.participants ?? [] {
            if let participantName = participant.userIdentity.nameComponents?.formatted(.name(style: .long)) {
                users.append(participantName)
            }
        }
        return users
    }
}


struct PropertyView_Previews: PreviewProvider {
    static var viewContext = CoreDataStack.shared.context
    
    static var previews: some View {
        let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
        
        return PropertyView(property: property)
    }
}

extension PropertyView {
  private func string(for permission: CKShare.ParticipantPermission) -> String {
    switch permission {
    case .unknown:
      return "Unknown"
    case .none:
      return "None"
    case .readOnly:
      return "Read-Only"
    case .readWrite:
      return "Read-Write"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Permission")
    }
  }

  private func string(for role: CKShare.ParticipantRole) -> String {
    switch role {
    case .owner:
      return "Owner"
    case .privateUser:
      return "Private User"
    case .publicUser:
      return "Public User"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Role")
    }
  }

  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
    switch acceptanceStatus {
    case .accepted:
      return "Accepted"
    case .removed:
      return "Removed"
    case .pending:
      return "Invited"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
    }
  }
}

