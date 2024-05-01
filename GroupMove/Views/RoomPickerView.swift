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

    @State private var selectedRooms: [String] = []
    
    var body: some View {
        List {
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
            ForEach(customRooms, id: \.self) { room in
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
            TextField("Custom Room", text: $customRoom)
                .foregroundStyle(.blue)
        }
    }
    
    private func toggleSelection(for room: String) {
            if let index = selectedRooms.firstIndex(where: { $0 == room }) {
                selectedRooms.remove(at: index)
            } else {
                selectedRooms.append(room)
            }
        }
}

#Preview {
    RoomPickerView()
}
