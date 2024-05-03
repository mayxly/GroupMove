//
//  AddPropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) var done
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedProperty: Property?
    @State private var name = ""
    @State private var addBudget = false
    @State private var budgetAmount: Float?
    @State private var selectedColor = "00A5E3"
    @State private var selectedRooms: [String] = ["Kitchen", "Living Room"]
    
    @State private var showingNameError = false
    
    private var stack = CoreDataStack.shared
    
    let colors = [
        "00A5E3",
        "8DD7BF",
        "FF96C5",
        "FFBF65",
        "FF5768",
        "5C62D6",
        "4F3F3E",
        "FFA23A",
        "FF828B",
        "4DD091",
        "00B0BA",
        "0065A2",
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    var body: some View {
        NavigationView {
            VStack() {
                Form {
                    Section() {
                        HStack {
                            Spacer()
                            Circle()
                                .frame(width: 100)
                                .foregroundColor(Color(hex: selectedColor))
                                .padding(.top, 10)
                            Spacer()
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black.opacity(0.05))
                                .frame(height: 40)
                            TextField("Property Name", text: $name)
                                .multilineTextAlignment(.center)
                                .alert("Save Error", isPresented: $showingNameError) {
                                } message: {
                                    Text("Please enter a property name.")
                                }
                        }
                    }.listRowSeparator(.hidden)
                    Section(header: Text("Budget"),
                            footer: Text("A budget allows your group to set the price of each item in the property to maintain your budget goals.")) {
                        Toggle("Add Budget", isOn: $addBudget)
                        if addBudget {
                            TextField("$0.00", value: $budgetAmount, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                    Section("Rooms") {
                        NavigationLink(destination: RoomPickerView(selectedRooms: $selectedRooms)) {
                            if selectedRooms.isEmpty {
                                Text("Add rooms...")
                            } else {
                                Text(selectedRooms.joined(separator: ", "))
                            }
                        }
                    }
                    Section("Color") {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                            .padding(2)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(.gray.opacity(0.5), lineWidth: selectedColor == color ? 4 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        done()
                    }.foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !isValidPropertyName(for: name) {
                            showingNameError.toggle()
                        } else {
                            saveProperty()
                        }
                    }
                }
            }
        }
    }
    
    private func saveProperty() {
        withAnimation {
            if selectedProperty == nil {
                selectedProperty = Property(context: viewContext)
            }
            
            guard let selectedProperty else { return }
            
            selectedProperty.name = name
            selectedProperty.budget = budgetAmount ?? 0
            
            // Create Rooms
            for roomName in selectedRooms {
                let newRoom = Room(context: viewContext)
                newRoom.name = roomName
                selectedProperty.addToRooms(newRoom)
            }
            
            selectedProperty.dateCreated = Date()
            selectedProperty.color = selectedColor
            
            stack.save()
        }
        done()
    }
    
    private func isValidPropertyName(for name: String) -> Bool {
        if name == "" {
            return false
        }
        return true
    }
}

struct AddPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        AddPropertyView()
    }
}
