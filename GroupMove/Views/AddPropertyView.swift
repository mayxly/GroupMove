//
//  AddPropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) var done
    @State private var name = ""
    @State private var addBudget = false
    @State private var budgetAmount: Double?
    
    @State var colorSelection: String = "🍎"
    let emojis = [
      "🍎", "🍌", "🍇", "🍐", "🍒", "🍑",
      "😀", "🥶", "🥺", "🤥", "🤢", "🤤",
      "🐶", "🐭", "🐣", "🙉", "🐸", "🦄",
      "⚽️", "🏀", "⚾️", "🥎", "🏐", "🎱",
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Property Name", text: $name)
                    }
                    Section {
                        Toggle("Add Budget", isOn: $addBudget)
                        if addBudget {
                            TextField("$0.00", value: $budgetAmount, format: .number)
                                .keyboardType(.decimalPad)
                        }
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
                        done()
                    }
                }
            }
        }
    }
}

struct AddPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        AddPropertyView()
    }
}
