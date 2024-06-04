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
    
    // UI
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
    let horizontalPadding = CGFloat(30)
    
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
    
    var propertyNameSection: some View {
        Section {
            ZStack(alignment: .center) {
                VStack {
                    BackgroundRect(height: 175)
                }
                VStack() {
                    ZStack {
                        HStack {
                            Spacer()
                            Circle()
                                .frame(width: 80)
                                .foregroundColor(Color(hex: selectedColor))
                            Spacer()
                        }
                        Image("HomeIcon")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.white)

                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundStyle(Color(hex: "505050"))
                            .frame(height: 40)
                            .padding(.horizontal, 20)
                        TextField("", text: $name, prompt: Text("Property Name").foregroundColor(Color(hex: "C3C3C3")))
                            .foregroundStyle(.white)
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
                }
            }
        } footer: {
            if hasEditedName && name.isEmpty {
                Text("Property name is required")
                    .font(.caption)
                    .foregroundColor(name.isEmpty ? .red : .clear)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .listRowSeparator(.hidden)
    }
    
    var budgetSection: some View {
        Section { // Budget Section
            VStack {
                HStack {
                    Text("Budget")
                        .padding(.horizontal, horizontalPadding)
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack(alignment: .top) {
                    VStack() {
                        BackgroundRect(height: hasBudget ? 90 : 45)
                    }
                    VStack(spacing: 0) {
                        ZStack {
                            Rectangle() // Invisible rect to center elements
                                .frame(height: 45)
                                .opacity(0)
                            Toggle("Add Budget", isOn: $hasBudget.animation(.bouncy))
                                .foregroundStyle(.white)
                                .onChange(of: hasBudget) { newValue in
                                    budgetAmountText = ""
                                }
                                .padding(.horizontal, 20)
                        }
                        if hasBudget {
                            Divider().background(Color(hex: "505050"))
                            ZStack {
                                Rectangle() // Invisible rect to center elements
                                    .frame(height: 45)
                                    .opacity(0)
                                PriceTextField(priceAmountText: $budgetAmountText, priceKeyboardIsFocused: _priceKeyboardIsFocused)
                                    .padding(.horizontal, 20)
                                    .foregroundStyle(.white)
                            }
                            
                        }
                    }
                    
                }
                .padding(.horizontal, horizontalPadding)
                HStack {
                    Text("A budget allows your group to set the price of each item in the property to maintain your budget goals.")
                        .padding(.horizontal, 40)
                        .font(.caption)
                        .foregroundStyle(Color(hex:"939393"))
                    Spacer()
                }
            }
        }
    }
    
    var roomPickerSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Rooms")
                        .padding(.horizontal, horizontalPadding)
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack {
                    BackgroundRect(height: 45)
                    
                    HStack {
                        NavigationLink(destination: RoomPickerView(selectedRooms: $selectedRooms)) {
                            if selectedRooms.isEmpty {
                                Text("Add rooms...")
                            } else {
                                Text(selectedRooms.joined(separator: ", "))
                            }
                        }
                        .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
    
    var colorPickerSection: some View {
        Section() {
            VStack {
                HStack {
                    Text("Color")
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack {
                    BackgroundRect(height: 135)
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex:"292929").ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    propertyNameSection
                    budgetSection
                    roomPickerSection
                    colorPickerSection
                    Spacer()
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
        }
        .onAppear {
            if shouldAddDefaultRooms {
                addDefaultRooms()
                shouldAddDefaultRooms = false
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
