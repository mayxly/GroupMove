//
//  CustomSegmentedPicker.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-24.
//

import SwiftUI

struct CustomSegmentedPicker: View {
    var options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        ZStack {
            Capsule()
                    .fill(Color.white)
                    .frame(width: 300, height: 40)
            HStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: "1FB1F0"))
                    .frame(width: 150, height: 40)
                    .offset(x: selectedOption == options[0] ? 0 : 150)
                // Invisible capsule
                Capsule()
                    .fill(Color.white.opacity(0))
                    .frame(width: 150, height: 40)
            }
            
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    if(selectedOption == option) {
                        PickerSegmentView(text: option)
                            .clipShape(Capsule())
                    } else {
                        PickerSegmentView(text: option, textColor: Color(hex: "5B5B5B"))
                            .background(Color.white.opacity(0))
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedOption = option
                                }
                            }
                    }
                }
            }
        }
        .background(.white)
        .clipShape(Capsule())
    }
}

struct PickerSegmentView: View { 
    var text: String
    var textColor = Color.white
    var width = CGFloat(150)
    var height = CGFloat(20)
    
    var body: some View {
        HStack {
            Text(text)
                .font(Font.custom("Satoshi-Variable", size: 16))
                .foregroundColor(textColor)
        }
        .frame(width: width, height: height)
        .padding(.vertical, 10)
        
    }
}

#Preview {
    let options = ["Option 1", "Option 2"]
    @State var selectedOption = "Option 1"
    
    return ZStack {
        Color.gray.ignoresSafeArea()
        CustomSegmentedPicker(options: options, selectedOption: $selectedOption)
    }
}
