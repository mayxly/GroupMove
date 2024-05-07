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
    @State private var name: String
    @State private var hasEditedName: Bool = false
    @State private var hasBudget: Bool
    private var budgetAmount: Float? {
        try? FloatingPointFormatStyle.number.parseStrategy.parse(budgetAmountText)
    }
    @State private var budgetAmountText: String
    @State private var selectedColor: String
    @State private var selectedRooms: [Room]
    
    @State private var shouldAddDefaultRooms: Bool
    
    @FocusState var priceKeyboardIsFocused: Bool
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
    
    init(passedProperty: Property?) {
        if let property = passedProperty {
            _selectedProperty = State(initialValue: property)
            _name = State(initialValue: property.name ?? "")
            _hasBudget = State(initialValue: property.hasBudget)
            
            // Budget
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            _budgetAmountText = State(initialValue: formatter.string(for: property.budget) ?? "0.00")
            _selectedColor = State(initialValue: property.color!)
            
            // Init rooms and store existing rooms
            _selectedRooms = State(initialValue: (passedProperty?.rooms?.allObjects as? [Room] ?? []).sorted(by: { $0.orderIndex < $1.orderIndex }))
            _shouldAddDefaultRooms = State(initialValue: false)
        } else {
            _name = State(initialValue: "")
            _hasBudget = State(initialValue: false)
            _budgetAmountText = State(initialValue: "")
            _selectedColor = State(initialValue: "00A5E3")
            _selectedRooms = State(initialValue: [])
            _shouldAddDefaultRooms = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                Form {
                    Section() {
                        ZStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .frame(width: 100)
                                    .foregroundColor(Color(hex: selectedColor))
                                    .padding(.top, 10)
                                Spacer()
                            }
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            
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
                                .onChange(of: name) { _ in
                                    hasEditedName = true
                                }
                                .disabled(priceKeyboardIsFocused)
                                .onTapGesture {
                                    priceKeyboardIsFocused = false
                                }
                        }
                    } footer: {
                        if hasEditedName {
                            Text("Property name is required")
                                .font(.caption)
                                .foregroundColor(name.isEmpty ? .red : .clear)
                        }
                    }
                    .listRowSeparator(.hidden)
                    
                    Section(header: Text("Budget"),
                            footer: Text("A budget allows your group to set the price of each item in the property to maintain your budget goals.")) {
                        Toggle("Add Budget", isOn: $hasBudget)
                            .onChange(of: hasBudget) { newValue in
                                budgetAmountText = ""
                            }
                        if hasBudget {
                            PriceTextField(priceAmountText: $budgetAmountText, priceKeyboardIsFocused: _priceKeyboardIsFocused)
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
                        hasEditedName = true
                        if !isValidPropertyName(for: name) {
                            showingNameError.toggle()
                        } else {
                            saveProperty()
                        }
                    }
                }
            }
            .onAppear {
                if shouldAddDefaultRooms {
                    addDefaultRooms()
                    shouldAddDefaultRooms = false
                }
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func saveProperty() {
        withAnimation {
            if selectedProperty == nil {
                selectedProperty = Property(context: viewContext)
                selectedProperty?.isShared = false
            }
            
            guard let selectedProperty else { return }
            
            selectedProperty.name = name
            
            selectedProperty.budget = budgetAmount ?? 0
            selectedProperty.hasBudget = hasBudget
            
            selectedProperty.rooms = []
            
            var index = 0
            for room in selectedRooms {
                room.orderIndex = Int16(index)
                selectedProperty.addToRooms(room)
                index += 1
            }
            
            selectedProperty.dateCreated = Date()
            selectedProperty.color = selectedColor
            
            stack.save()
        }
        done()
    }
    
    private func addDefaultRooms() {
        let kitchen = Room(context: stack.context)
        kitchen.name = "Kitchen"
        let livingRoom = Room(context: stack.context)
        livingRoom.name = "Living Room"
        
        selectedRooms.append(kitchen)
        selectedRooms.append(livingRoom)
    }
    
    private func isValidPropertyName(for name: String) -> Bool {
        if name == "" {
            return false
        }
        return true
    }
}

extension Array where Element == Room {
    func joined(separator: String) -> String {
        return self.map { $0.name! }.joined(separator: separator)
    }
}

struct AddPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        AddPropertyView(passedProperty: nil)
    }
}
