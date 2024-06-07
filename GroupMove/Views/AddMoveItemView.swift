//
//  AddMoveItemView.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-04-30.
//

import SwiftUI

struct AddMoveItemView: View {
    @Environment(\.dismiss) var done
    @Environment(\.managedObjectContext) var viewContext
    
    // MoveItem Fields
    @State private var selectedMoveItem: MoveItem?
    @State private var name: String
    @State private var hasEditedName: Bool = false
    @State private var notes: String
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingImagePicker = false
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
    @FocusState var notesKeyboardIsFocused: Bool
    
    // UI
    private var stack = CoreDataStack.shared
    let horizontalPadding = CGFloat(30)
    @State private var notesPlaceholder = "Notes"
    
    
    init(passedMoveItem: MoveItem?, passedProperty: Property, participants: ParticipantInfoViewModel) {
        property = passedProperty
        userList = participants.allParticipants
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
            _room = State(initialValue: rooms.first!)
            _owner = State(initialValue: participants.currUser)
        }
    }
    
    var nameAndNotesSection: some View {
        Section {
            ZStack(alignment: .top) {
                VStack() {
                    BackgroundRect(height: 200)
                }
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle() // Invisible rect to center elements
                            .frame(height: 45)
                            .opacity(0)
                        TextField("Item Name", text: $name, prompt: Text("Item Name").foregroundColor(Color(hex: "C3C3C3")))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .disabled(priceKeyboardIsFocused)
                            .onTapGesture {
                                priceKeyboardIsFocused = false
                            }
                            .onChange(of: name) { _ in
                                hasEditedName = true
                            }
                            .alert("Save Error", isPresented: $showingNameError) {
                            } message: {
                                Text("Please enter an item name.")
                            }
                    }
                    Divider().background(Color(hex: "505050"))
                    ZStack {
                        Rectangle() // Invisible rect to center elements
                            .frame(height: 155)
                            .opacity(0)
                        ZStack {
                            if notes.isEmpty { // Used for placeholder text
                                TextEditor(text: $notesPlaceholder)
                                    .scrollContentBackground(.hidden)
                                    .frame(maxWidth: .infinity, maxHeight: 155)
                                    .foregroundColor(Color(hex: "C3C3C3"))
                                    .padding(.horizontal, 15)
                                    .disabled(true)
                            }
                            TextEditor(text: $notes)
                                .scrollContentBackground(.hidden)
                                .frame(maxWidth: .infinity, minHeight: 155, maxHeight: 155)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 15)
                                .focused($notesKeyboardIsFocused)
                                .onTapGesture {
                                    priceKeyboardIsFocused = false
                                }
                                .toolbar {
                                    if notesKeyboardIsFocused {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                notesKeyboardIsFocused.toggle()
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        } footer: {
            if hasEditedName && name.isEmpty {
                HStack {
                    Text("Item name is required")
                        .font(.caption)
                        .foregroundColor(name.isEmpty ? .red : .clear)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    var priceSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Price")
                        .padding(.horizontal, horizontalPadding)
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack {
                    BackgroundRect(height: 45)
                    if hasBudget {
                        PriceTextField(priceAmountText: $priceAmountText, priceKeyboardIsFocused: _priceKeyboardIsFocused)
                            .padding(.horizontal, 20)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
    
    var photoSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Photo")
                        .padding(.horizontal, horizontalPadding)
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack() {
                    BackgroundRect(height: 45)
                    
                    Button {
                        self.showingImagePicker = true
                    } label: {
                        if image == nil {
                            HStack {
                                Text("Add Photo")
                                Spacer()
                                Image(systemName: "camera")
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                        } else {
                            ZStack {
                                image?
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                                if image != nil {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                self.image = nil
                                                self.inputImage = nil
                                            }) {
                                                Image("XMarkCircleIcon")
                                                    .padding(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
    
    var detailsSection: some View {
        Section {
            VStack {
                HStack {
                    Text("Details")
                        .foregroundStyle(Color(hex:"B9B9B9"))
                    Spacer()
                }
                ZStack(alignment: .top) {
                    VStack() {
                        BackgroundRect(height: 90)
                    }
                    VStack(spacing: 0) {
                        ZStack {
                            Rectangle() // Invisible rect to center elements
                                .frame(height: 45)
                                .opacity(0)
                            HStack {
                                Text("Room")
                                    .foregroundStyle(.white)
                                Spacer()
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
                                .tint(Color(hex: "1FB1F0"))
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 10)
                        }
                        Divider().background(Color(hex: "505050"))
                        ZStack {
                            Rectangle() // Invisible rect to center elements
                                .frame(height: 45)
                                .opacity(0)
                            HStack {
                                Text("Owner")
                                    .foregroundStyle(.white)
                                Spacer()
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
                                .tint(Color(hex: "1FB1F0"))
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex:"292929").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        nameAndNotesSection
                        if hasBudget {
                            priceSection
                        }
                        photoSection
                        detailsSection
                        Spacer()
                    }
                }
                .toolbarBackground(Color(hex:"292929"))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", role: .cancel) {
                            done()
                        }.foregroundColor(.red)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            hasEditedName = true
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
                if let selectedMoveItem = selectedMoveItem {
                    selectedMoveItem.id = UUID()
                }
            }
            
            guard let selectedMoveItem else { return }
            
            selectedMoveItem.name = name
            selectedMoveItem.notes = notes
            let imageData = inputImage?.jpegData(compressionQuality: 0.8)
            selectedMoveItem.image = imageData
            selectedMoveItem.price = Float(price ?? 0)
            selectedMoveItem.room = room
            selectedMoveItem.dateCreated = Date()
            selectedMoveItem.owner = owner
            
            property.addToItems(selectedMoveItem)
            
            stack.save()
        }
        done()
    }
}

#Preview {
    let viewContext = CoreDataStack.shared.context
    
    let property = PreviewManager.shared.getBasicPropertyWithRooms(context: viewContext)
    
    let participants = ParticipantInfoViewModel()
    participants.currUser = "Default User"
    participants.allParticipants = ["Default User"]
    
    property.hasBudget = true
    
    return AddMoveItemView(passedMoveItem: nil, passedProperty: property, participants: participants)
}
