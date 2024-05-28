//
//  BudgetProgressBar.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-06.
//

import SwiftUI

struct BudgetProgressBar: View {
    var width: CGFloat = UIScreen.main.bounds.width - 80
    var height: CGFloat = 20
    var percent: CGFloat = 70
    var color1 = Color(hex: "74E9B1")
    var color2 = Color(hex: "6ED7FF")
    var isOverBudget: Bool = false
    
    var body: some View {
        let multiplier = width / 100
        let progressWidth = min(width, percent * multiplier)
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: width, height: height)
                .foregroundColor(Color.gray.opacity(0.2))
            
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: progressWidth, height: height)
                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous)))
                .foregroundStyle(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: height)
                        .stroke(isOverBudget ? .red : .clear, lineWidth: 1)
                        .blur(radius: 1.5)
                )
        }
    }
}

#Preview {
    BudgetProgressBar()
}
