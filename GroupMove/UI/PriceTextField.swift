//
//  PriceTextField.swift
//  GroupMove
//
//  Created by May Ly on 2024-05-05.
//

import SwiftUI

struct PriceTextField: View {
    @Binding var priceAmountText: String
    @FocusState var priceKeyboardIsFocused: Bool

    var body: some View {
        TextField("$0.00", text: $priceAmountText)
            .keyboardType(.decimalPad)
            .focused($priceKeyboardIsFocused)
            .onChange(of: priceAmountText) { newText in
                if priceAmountText == "." {
                    priceAmountText = "0."
                }
                let components = priceAmountText.components(separatedBy: ".")
                if components.count == 1 && components[0].count > 1 {
                    if let noLeadingZeros = Int(components[0]) {
                        priceAmountText = String(noLeadingZeros)
                    }
                }
                if components.count > 2 || (components.count == 2 && components[1].count > 2) {
                    priceAmountText = String(priceAmountText.dropLast())
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        priceKeyboardIsFocused.toggle()
                        let components = priceAmountText.components(separatedBy: ".")
                        if components.count == 2 && components[1].count < 2 {
                            if components[1] == "" {
                                priceAmountText += "00"
                            } else {
                                priceAmountText += "0"
                            }
                        } else {
                            priceAmountText += ".00"
                        }
                    }
                }
            }
    }
}
