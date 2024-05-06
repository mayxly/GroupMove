//
//  RoomPickerView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-30.
//

import SwiftUI



struct RoomPickerView: View {
    let defaultRooms: [String] = [
        "Kitchen",
        "Living Room",
        "Bathroom",
        "Dining Room",
        "Bedroom 1",
        "Bedroom 2",
    ]
    
    @State private var customRoom: String = ""

    @State private var isEditingList = false
    @Binding var selectedRooms: [Room]
    @State private var showingCustomRoomError = false
    @State private var showingNoRoomError = false
    
    // Room deletion
    @State private var roomWithItemsAlert = false
    @State private var pendingDeleteRoomIndex = 0
    
    private let stack = CoreDataStack.shared

    // Custom back button
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var backButton : some View { Button(action: {
        if selectedRooms.count < 1 {
            showingNoRoomError = true
            return
        }
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("New Property")
        }
    }

    var body: some View {
        List() {
            Section("Your Rooms") {
                ForEach(selectedRooms, id: \.self) { room in
                    HStack {
                        Text(room.name!)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                    .onTapGesture {
                        toggleSelection(for: room.name!)
                    }
                    .onLongPressGesture() {
                        withAnimation {
                            isEditingList = true
                        }
                    }
                }
                .onMove(perform: move)
                TextField("Custom Room", text: $customRoom)
                    .onSubmit {
                        if !isValidRoom(for: customRoom) {
                            customRoom = ""
                            showingCustomRoomError.toggle()
                        } else {
                            selectedRooms.append(CreateRoom(customRoom))
                            customRoom = ""
                        }
                        
                    }
                    .alert("Custom Room Error", isPresented: $showingCustomRoomError) {
                    } message: {
                        Text("The room you are trying to add already exists.")
                    }
            }
            .environment(\.editMode, isEditingList ? .constant(.active) : .constant(.inactive))
            Section("Default Rooms") {
                ForEach(defaultRooms, id: \.self) { room in
                    if !selectedRooms.contains(room) {
                        HStack {
                            Text(room)
                        }
                        .onTapGesture {
                            toggleSelection(for: room)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .alert("Save Error", isPresented: $showingNoRoomError) {
        } message: {
            Text("There must be at least 1 room in the property.")
        }
        .alert("Delete Room", isPresented: $roomWithItemsAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                deleteRoomWithItems(pendingDeleteRoomIndex)
            }
        } message: {
            Text("Are you sure you want to delete a room with items in it?")
        }
    }
    
    private func toggleSelection(for room: String) {
        if let index = selectedRooms.firstIndex(where: { $0.name == room }) {
            if selectedRooms[index].moveItem?.count ?? 0 > 0 {
                pendingDeleteRoomIndex = index
                roomWithItemsAlert.toggle()
            } else {
                selectedRooms.remove(at: index)
            }
        } else {
            selectedRooms.append(CreateRoom(room))
        }
    }
    
    private func deleteRoomWithItems(_ index: Int) {
        let pendingRoom = selectedRooms[index]
        if let moveItems = pendingRoom.moveItem?.allObjects as? [MoveItem] {
            for item in moveItems {
                stack.deleteMoveItem(item)
            }
        }
        selectedRooms.remove(at: index)
    }
    
    private func isValidRoom(for room: String) -> Bool {
        if selectedRooms.contains(room) || defaultRooms.contains(room) {
            return false
        }
        return true
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        selectedRooms.move(fromOffsets: source, toOffset: destination)
        withAnimation {
            isEditingList = false
        }
    }
    
    private func CreateRoom(_ roomName: String) -> Room {
        let newRoom = Room(context: stack.context)
        newRoom.name = roomName
        return newRoom
    }
}

extension Array where Element == Room {
    func contains(_ roomName: String) -> Bool {
        return self.contains { $0.name == roomName }
    }
}

#Preview {
    @State var myRooms: [Room] = []
    return RoomPickerView(selectedRooms: $myRooms)
}
