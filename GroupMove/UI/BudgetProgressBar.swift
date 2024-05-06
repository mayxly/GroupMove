//
//  BudgetProgressBar.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-06.
//

import SwiftUI

struct BudgetProgressBar: View {
    var width: CGFloat = 200
    var height: CGFloat = 20
    var percent: CGFloat = 70
    var color1 = Color(hex: "8360c3")
    var color2 = Color(hex: "2ebf91")
    
    var body: some View {
        let multiplier = width / 100
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: width, height: height)
                .foregroundColor(Color.black.opacity(0.1))
            
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: percent * multiplier, height: height)
                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous)))
                .foregroundStyle(.clear)
        }
    }
}

#Preview {
    BudgetProgressBar()
}
