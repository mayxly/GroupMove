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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Property.dateCreated, ascending: true)],
        animation: .default)
    private var homes: FetchedResults<Property>
    
    // Room properties
    @ObservedObject var pm: PropertyManager = PropertyManager.shared
    @ObservedObject var participants: ParticipantInfoViewModel = ParticipantInfoViewModel()
    @State private var roomItemMap = [Room: [MoveItem]]()
    @State var itemsToDelete = [MoveItem]()
    
    // Show sheets
    @State private var showHomesSheet = false
    @State private var showAddItemSheet = false
    @State private var showNoItemsView = false
    @State private var showEditPropertySheet = false
    let allViews = ["Overview", "Moving List"]
    @State private var selectedView = "Overview"
    
    // Error
    @State private var failedToDelete = false
    
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
                let totalBudget = pm.activeProperty!.budget
                let budgetPercent = CGFloat((usedBudget / totalBudget) * 100)
                let isOverBudget = usedBudget > totalBudget
                HStack {
                    Text("Budget Tracker")
                        .foregroundStyle(.white)
                        .bold()
                    Spacer()
                    Text("$\(String(format: "%.2f", usedBudget)) / $\(String(format: "%.2f", totalBudget))")
                        .foregroundStyle(isOverBudget ? .red : Color(hex: "C3C3C3"))
                }
                BudgetProgressBar(height: CGFloat(25), percent: budgetPercent, isOverBudget: isOverBudget)
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
    
    var noItemsView: some View {
        VStack {
            Spacer()
            if showAddButton {
                Text("You don't have any items\nin your property yet!")
                    .foregroundStyle(Color.white)
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
        .padding(.horizontal, 10)
        .animation(.easeInOut(duration: 0.3), value: roomItemMap)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex:"292929").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        
                        CustomSegmentedPicker(options: allViews, selectedOption: $selectedView)
                        
                        // No Items
                        if showNoItemsView {
                            noItemsView
                                .opacity(roomItemMap.count < 1 ? 1 : 0)
                                .transition(.opacity)
                        } else {
                            VStack {
                                // Budget
                                if pm.activeProperty!.hasBudget {
                                    budgetSection
                                }
                                // Rooms and Items
                                roomsSection
                            }
                            .transition(.opacity)
                        }
                        Spacer()
                    }
                }
            }
            .alert("Delete Error", isPresented: $failedToDelete) {
            } message: {
                Text("You must have 1 active home.")
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex:"292929"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        showHomesSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Text(pm.activeProperty!.name ?? "My Home")
                                .foregroundStyle(.white)
                                .font(Font.custom("SatoshiVariable-Bold_Bold", size: 18))
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3))
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 15, height: 15)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            addItemButton()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                        }
                        .disabled(!stack.canEdit(object: pm.activeProperty!) || !showAddButton)
                        
                        Menu {
                            Button {
                                showEditPropertySheet.toggle()
                            } label: {
                                Text("Edit")
                            }
                            Button(role: .destructive) {
                                deleteProperty()
                            } label: {
                                Text("Delete Property")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.white)
                        }
                        .colorScheme(.dark)
                    }
                    //                        Button {
                    //                            showShareSheet = true
                    //                        } label: {
                    //                            Image(systemName: "person.badge.plus")
                    //                        }
                    //                        Button {
                    //                            showEditPropertySheet.toggle()
                    //                        } label: {
                    //                            Image(systemName: "pencil.circle.fill")
                    //                                .foregroundStyle(Color(hex: "3D3D3D"))
                    //                        }
                    //                        .disabled(!stack.canEdit(object: property))
                    //                    }
                }
            }
        }
        .sheet(isPresented: $showHomesSheet, onDismiss: {
            generateRoomAndItemMapping()
        }) {
            NewHomeView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showAddItemSheet, onDismiss: {
            generateRoomAndItemMapping()
        }) {
            AddMoveItemView(passedMoveItem: nil, passedProperty: pm.activeProperty!, participants: participants)
        }
        .sheet(isPresented: $showShareSheet) {
            if let share = share {
                CloudSharingView(
                    share: share,
                    container: stack.ckContainer,
                    property: pm.activeProperty!
                )
            }
        }
        .sheet(isPresented: $showEditPropertySheet, onDismiss: {
            generateRoomAndItemMapping()
        }) {
            AddPropertyView(passedProperty: pm.activeProperty)
        }
        .onAppear {
            self.share = stack.getShare(pm.activeProperty!)
            generateRoomAndItemMapping()
            if !stack.isShared(object: pm.activeProperty!) {
                Task {
                    await createShare(pm.activeProperty!)
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
    private func deleteProperty() {
        if homes.count > 1 {
            var newHome: Property?
            for home in homes {
                if home != pm.activeProperty {
                    newHome = home
                    break
                }
            }
            
            if let newHome = newHome {
                pm.deleteActiveProperty(newProperty: newHome)
                generateRoomAndItemMapping()
                return
            }
        }
        failedToDelete = true
    }
    
    private func addItemButton() {
        participants.currUser = getCurrUser()
        participants.allParticipants = getAllParticipants()

        showAddItemSheet.toggle()
    }
    
    private func calculateUsedBudget() -> Float {
        if pm.activeProperty!.hasBudget {
            var spent: Float = 0
            if let items = pm.activeProperty!.items?.allObjects as? [MoveItem] {
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
        if let items = pm.activeProperty!.items?.allObjects as? [MoveItem] {
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
        withAnimation(.easeInOut(duration: 0.3)) {
            showNoItemsView = roomItemMap.isEmpty
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
            pm.activeProperty!.isShared = true
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
                    .frame(maxWidth: .infinity, maxHeight: isCollapsed ? 60 : CGFloat(60 + items.count * 60 + 8))
            }
            VStack(alignment: .leading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hideText.toggle()
                    }
                    withAnimation(.bouncy) {
                        isCollapsed.toggle()
                    }
                } label: {
                    HStack {
                        Text(roomName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                            .foregroundColor(.white)
                    }
                }
                if !isCollapsed {
                    ForEach(items, id: \.self) { item in
                        ItemNavLink(moveItem: item, propertyView: propertyView)
                            .opacity(hideText ? 0 : 100)
                    }
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 10)
    }
}

struct ItemNavLink: View {
    var moveItem: MoveItem
    var propertyView: PropertyView
    
    var body: some View {
        NavigationLink(destination: ItemInfoView(item: moveItem, property: propertyView.pm.activeProperty!, participants: propertyView.participants)) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: "3D3D3D"))
                    .frame(maxWidth: .infinity, minHeight: 35)
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
                if let allItems = propertyView.pm.activeProperty!.items?.allObjects as? [MoveItem] {
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
    static let propertyManager = PropertyManager.shared
    
    static var previews: some View {
        let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
        property.hasBudget = true
        property.budget = 100.0
        
        propertyManager.activeProperty = property
        
        return PropertyView()
    }
}
