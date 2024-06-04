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
        TextField("$", text: $priceAmountText, prompt: Text("$0.00").foregroundColor(Color(hex: "C3C3C3")))
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
            if priceKeyboardIsFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        priceKeyboardIsFocused.toggle()
                        priceAmountText = makePricePretty(for: priceAmountText)
                    }
                }
            }
        }
    }
}
    
extension PriceTextField {
    func makePricePretty(for priceText: String) -> String {
        var res = priceText
        let components = priceText.components(separatedBy: ".")
        if components.count == 2 && components[1].count < 2 {
            if components[1] == "" {
                res += "00"
            } else {
                res += "0"
            }
        } else {
            res += ".00"
        }
        return res
    }
}

