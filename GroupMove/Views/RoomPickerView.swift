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
    
    @State private var customRooms: [String] = []
    @State private var customRoom: String = ""

    @Binding var selectedRooms: [String]
    
    @State private var showingRoomError = false
    
    var body: some View {
        List {
            Section("Default Rooms") {
                ForEach(defaultRooms, id: \.self) { room in
                    HStack {
                        Text(room)
                        if selectedRooms.contains(room) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .onTapGesture {
                        toggleSelection(for: room)
                    }
                }
            }
            Section("Custom Rooms") {
                ForEach(customRooms, id: \.self) { room in
                    HStack {
                        if selectedRooms.contains(room) {
                            Text(room)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .onTapGesture {
                        toggleSelection(for: room)
                    }
                }
                TextField("Custom Room", text: $customRoom)
                    .onSubmit {
                        if !isValidRoom(for: customRoom) {
                            customRoom = ""
                            showingRoomError.toggle()
                        } else {
                            customRooms.append(customRoom)
                            selectedRooms.append(customRoom)
                            customRoom = ""
                        }
                        
                    }
                    .alert("Error", isPresented: $showingRoomError) {
                    } message: {
                        Text("The room you are trying to add already exists.")
                    }
            }
        }
        .onAppear {
            makeCustomRooms()
        }
    }
    
    private func makeCustomRooms() {
        for room in selectedRooms {
            if !defaultRooms.contains(room) {
                customRooms.append(room)
            }
        }
    }
    
    private func toggleSelection(for room: String) {
        if let index = selectedRooms.firstIndex(where: { $0 == room }) {
            selectedRooms.remove(at: index)
            if let index = customRooms.firstIndex(where: { $0 == room }) {
                customRooms.remove(at: index)
            }
        } else {
            selectedRooms.append(room)
        }
    }
    
    private func isValidRoom(for room: String) -> Bool {
        if customRooms.contains(room) || defaultRooms.contains(room) {
            return false
        }
        return true
    }
}

#Preview {
    @State var myRooms: [String] = []
    return RoomPickerView(selectedRooms: $myRooms)
}
