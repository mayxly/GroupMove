//
//  PropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI
import CoreData
import CloudKit

class ParticipantInfoViewModel: ObservableObject {
    @Published var currUser = ""
    @Published var allParticipants = [String]()
}

struct PropertyView: View {
    // Room properties
    @ObservedObject var property: Property
    @ObservedObject var participants: ParticipantInfoViewModel = ParticipantInfoViewModel()
    @State private var roomItemMap = [Room: [MoveItem]]()
    @State var itemsToDelete = [MoveItem]()
    
    // Show sheets
    @State private var showAddItemSheet = false
    @State private var showEditPropertySheet = false
    let allViews = ["Overview", "Moving List"]
    @State private var selectedView = "Overview"
    
    // CloudKit Sharing
    @State private var share: CKShare?
    @State private var showShareSheet = false
    private let stack = CoreDataStack.shared
    @State private var showAddButton = false
    
    // Calculate budget
    private var usedBudget: Float {
        return calculateUsedBudget()
    }
    
    var budgetSection: some View {
        ZStack {
            BackgroundRect(height: 100)
            VStack {
                HStack {
                    Text("Budget Tracker")
                        .foregroundStyle(.white)
                        .bold()
                    Spacer()
                    Text("$50/$100")
                        .foregroundStyle(Color(hex: "C3C3C3"))
                }
                BudgetProgressBar(height: CGFloat(25))
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 30)
    }
    
    var noItemsView: some View {
        VStack {
            Spacer()
            if showAddButton {
                Text("You don't have any items\nin your property yet!")
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .padding(.vertical, 10)
                    .multilineTextAlignment(.center)
                Button("Add Item") {
                    addItemButton()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .foregroundColor(Color(UIColor.white))
                .background(Color(hex: "00A5E3"))
                .cornerRadius(30)
                .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.3), radius: 3, x: 3, y: 3)
                .transition(.opacity)
                Spacer()
                Spacer()
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    var roomsSection: some View {
        VStack {
            HStack {
                Text("Rooms")
                    .padding(.horizontal, 20)
                    .foregroundStyle(Color(hex:"C3C3C3"))
                Spacer()
            }
            ForEach(roomItemMap.sorted(by: { $0.key.orderIndex < $1.key.orderIndex }), id: \.key.orderIndex) { room, items in // Sort by room order
                if let roomName = room.name, items.count > 0, let _ = items[0].name {
                    RoomSection(roomName: roomName, items: items, propertyView: self)
                }
            }
            
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(property.name ?? "My Home")
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .font(.system(size: 18))
            CustomSegmentedPicker(options: allViews, selectedOption: $selectedView)
            
            // No Items
            if roomItemMap.count < 1 {
                noItemsView
            } else {
                // Budget
                if property.hasBudget {
                    budgetSection
                }
                // Rooms and Items
                roomsSection
            }
            Spacer()
        }
        .background(Color(hex:"292929"))
        .navigationTitle(property.name ?? "Property")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addItemButton()
                } label: {
                    Image(systemName: "plus.circle")
                }
                .disabled(!stack.canEdit(object: property) || !showAddButton)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditPropertySheet.toggle()
                } label: {
                    Text("Edit")
                }
                .disabled(!stack.canEdit(object: property))
            }
        }
        .sheet(isPresented: $showAddItemSheet, onDismiss: {
            generateRoomAndItemMapping()
        }){
            AddMoveItemView(passedMoveItem: nil, passedProperty: property, participants: participants)
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
            self.share = stack.getShare(property)
            generateRoomAndItemMapping()
            if !stack.isShared(object: property) {
                Task {
                    await createShare(property)
                }
            } else {
                participants.currUser = getCurrUser()
                participants.allParticipants = getAllParticipants()
                showAddButton = true
            }
        }
        .onDisappear() {
            if !(itemsToDelete.isEmpty) {
                deleteItems()
            }
        }
    }
}

extension PropertyView {
    private func addItemButton() {
        participants.currUser = getCurrUser()
        participants.allParticipants = getAllParticipants()
        showAddItemSheet.toggle()
    }
    
    private func calculateUsedBudget() -> Float {
        if property.hasBudget {
            var spent: Float = 0
            if let items = property.items?.allObjects as? [MoveItem] {
                for item in items {
                    spent += item.price
                }
            }
            for deletedItem in itemsToDelete {
                spent -= deletedItem.price
            }
            return spent
        }
        return 0
    }
    
    private func deleteItems() {
        for item in itemsToDelete {
            stack.deleteMoveItem(item)
        }
    }
    
    private func generateRoomAndItemMapping() {
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
            withAnimation {
                self.showAddButton = true
            }
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
        if users.count > 1 {
            property.isShared = true
        }
        return users
    }
    
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

struct RoomSection: View {
    var roomName: String
    var items: [MoveItem]
    var propertyView: PropertyView
    
    @State private var isCollapsed = false
    @State private var hideText = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(hex: "333333"))
                    .frame(maxWidth: .infinity, maxHeight: isCollapsed ? 60 : CGFloat(60 + items.count * 52 + 8))
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(roomName)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            hideText.toggle()
                        }
                        withAnimation(.bouncy) {
                            isCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 10)
                if !isCollapsed {
                    ForEach(items, id: \.self) { item in
                        ItemNavLink(moveItem: item, propertyView: propertyView)
                            .opacity(hideText ? 0 : 100)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
}

struct ItemNavLink: View {
    var moveItem: MoveItem
    var propertyView: PropertyView
    
    var body: some View {
        NavigationLink(destination: ItemInfoView(item: moveItem, property: propertyView.property, participants: propertyView.participants)) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: "3D3D3D"))
                    .frame(maxWidth: .infinity, maxHeight: 42)
                HStack {
                    Text(moveItem.name ?? "Item")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }.padding(.horizontal, 15)
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                if let allItems = propertyView.property.items?.allObjects as? [MoveItem] {
                    if let itemToDelete = allItems.first(where: {$0.id == moveItem.id }) {
                        propertyView.itemsToDelete.append(itemToDelete)
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}

struct PropertyView_Previews: PreviewProvider {
    static let viewContext = CoreDataStack.shared.context
    
    static var previews: some View {
        let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
        property.hasBudget = true
        property.budget = 100.0
        
        return PropertyView(property: property)
    }
}
