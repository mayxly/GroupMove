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
                            Spacer()
                        }
                        TextField("Property Name", text: $name).multilineTextAlignment(.center)
                    }
                    Section {
                        Toggle("Add Budget", isOn: $addBudget)
                        if addBudget {
                            TextField("$0.00", value: $budgetAmount, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                    Section {
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
                        saveProperty()
                    }
                }
            }
        }
    }
    
    func saveProperty() {
        withAnimation {
            if selectedProperty == nil {
                selectedProperty = Property(context: viewContext)
            }
            
            selectedProperty?.name = name
            selectedProperty?.budget = budgetAmount ?? 0
//            selectedProperty?.rooms = "kitchen;bedroom;livingroom" // TODO: add rooms
            selectedProperty?.dateCreated = Date()
            selectedProperty?.color = selectedColor
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        done()
    }
}

struct AddPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        AddPropertyView()
    }
}
