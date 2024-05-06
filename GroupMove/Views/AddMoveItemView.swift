//
//  AddMoveItemView.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-04-30.
//

import SwiftUI

struct AddMoveItemView: View {
    @Environment(\.dismiss) var done
    @Environment(\.managedObjectContext) private var viewContext
    
    // MoveItem Fields
    @State private var selectedMoveItem: MoveItem?
    @State private var name: String
    @State private var notes: String
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var hasEditedName: Bool = false
    private let hasBudget: Bool
    private var price: Float? {
        try? FloatingPointFormatStyle.number.parseStrategy.parse(priceAmountText)
    }
    @State var priceAmountText: String
    @State private var room: Room
    private let rooms: [Room]
    @State private var owner: String
    var userList: [String]
    
    var property: Property
    
    // Alerts
    @State private var showingNameError = false
    
    // Keyboard
    @FocusState var priceKeyboardIsFocused: Bool
    
    // UI
    private var stack = CoreDataStack.shared
    
    
    init(passedMoveItem: MoveItem?, passedProperty: Property, currUser: String, userList: [String]) {
        property = passedProperty
        if let allRooms = property.rooms?.allObjects as? [Room] {
            rooms = allRooms.sorted(by: { $0.orderIndex < $1.orderIndex })
        } else {
            rooms = []
        }
        hasBudget = property.hasBudget
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let moveItem = passedMoveItem {
            _selectedMoveItem = State(initialValue: moveItem)
            _name = State(initialValue: moveItem.name ?? "")
            _notes = State(initialValue: moveItem.notes ?? "")
            if let imageData = moveItem.image, let uiImage = UIImage(data: imageData) {
                _inputImage = State(initialValue: uiImage)
                _image = State(initialValue: Image(uiImage: uiImage))
            }
            _priceAmountText = State(initialValue: formatter.string(for: moveItem.price) ?? "0.00")
            _room = State(initialValue: moveItem.room!)
            _owner = State(initialValue: moveItem.owner ?? "")
        } else {
            _name = State(initialValue: "")
            _notes = State(initialValue: "")
            _priceAmountText = State(initialValue: "")
            _room = State(initialValue: rooms[0])
            _owner = State(initialValue: currUser)
        }
        
        self.userList = userList
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item Name", text: $name)
                        .disabled(priceKeyboardIsFocused)
                        .onTapGesture {
                            priceKeyboardIsFocused = false
                        }
                        .onSubmit {
                            hasEditedName = true
                        }
                        .alert("Save Error", isPresented: $showingNameError) {
                        } message: {
                            Text("Please enter an item name.")
                        }
                } footer: {
                    if hasEditedName {
                        Text("Item name is required")
                            .font(.caption)
                            .foregroundColor(name.isEmpty ? .red : .clear)
                    }
                }
                Section ("Notes") {
                    TextEditor(text: $notes)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                    
                }
                Section {
                    if image == nil {
                        Button {
                            self.showingImagePicker = true
                        } label: {
                            Text("Add a photo")
                        }
                    } else {
                        Button {
                            self.showingImagePicker = true
                        } label: {image?
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                if hasBudget {
                    Section("Price") {
                        PriceTextField(priceAmountText: $priceAmountText, priceKeyboardIsFocused: _priceKeyboardIsFocused)
                    }
                }
                Section("Details") {
                    Picker("Room", selection: $room) {
                        if !rooms.isEmpty {
                            ForEach(rooms, id:\.self) {
                                Text($0.name ?? "Untitled")
                            }
                        } else {
                            Text("Untitled").tag(Room())
                        }
                    }
                    .pickerStyle(.menu)
                    Picker("Owner", selection: $owner) {
                        if !userList.isEmpty {
                            ForEach(userList, id:\.self) {
                                Text($0)
                            }
                        } else {
                            Text("Untitled").tag(Room())
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        done()
                    }.foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if name == "" {
                            showingNameError.toggle()
                        } else {
                            saveItem()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
              ImagePicker(image: $inputImage)
            }
        }
        .interactiveDismissDisabled()
    }
}

// MARK: Loading image and creating a new destination
extension AddMoveItemView {
    private func loadImage() {
      guard let inputImage = inputImage else { return }
      image = Image(uiImage: inputImage)
    }
    
    private func saveItem() {
        withAnimation {
            if selectedMoveItem == nil {
                selectedMoveItem = MoveItem(context: viewContext)
            }
            
            selectedMoveItem?.name = name
            selectedMoveItem?.notes = notes
            let imageData = inputImage?.jpegData(compressionQuality: 0.8)
            selectedMoveItem?.image = imageData
            selectedMoveItem?.price = Float(price ?? 0)
            selectedMoveItem?.room = room
            selectedMoveItem?.dateCreated = Date()
            selectedMoveItem?.owner = owner
            
            property.addToItems(selectedMoveItem!)
            
            stack.save()
        }
        done()
    }
}

#Preview {
    var viewContext = CoreDataStack.shared.context
    
    let property = PreviewManager.shared.getBasicPropertyWithRooms(context: viewContext)
    
    return AddMoveItemView(passedMoveItem: nil, passedProperty: property, currUser: "Default User", userList: ["Default User"])
}
