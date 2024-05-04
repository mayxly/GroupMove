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
    
    @Binding var selectedRooms: [String]
    @State private var customRoom: String = ""

    @State private var isEditingList = false
    @State private var showingRoomError = false
    
    var body: some View {
        List() {
            Section("Your Rooms") {
                ForEach(selectedRooms, id: \.self) { room in
                    HStack {
                        Text(room)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                    .onTapGesture {
                        toggleSelection(for: room)
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
                            showingRoomError.toggle()
                        } else {
                            selectedRooms.append(customRoom)
                            customRoom = ""
                        }
                        
                    }
                    .alert("Save Error", isPresented: $showingRoomError) {
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
    }
    
    private func toggleSelection(for room: String) {
        if let index = selectedRooms.firstIndex(where: { $0 == room }) {
            selectedRooms.remove(at: index)
        } else {
            selectedRooms.append(room)
        }
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
}

#Preview {
    @State var myRooms: [String] = ["Kitchen", "Living Room"]
    return RoomPickerView(selectedRooms: $myRooms)
}
