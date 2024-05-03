//
//  FloatingButton.swift
//  GroupMove
//
//  Created by May Ly on 2024-05-03.
//

import SwiftUI

struct FloatingButton<Destination: View>: View {
    
    let destination: Destination
    let text: String
    
    var body: some View {
        HStack {
            NavigationLink(destination: destination) {
                Text(text)
                    .font(.headline)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(30)
            .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.3), radius: 3, x: 3, y: 3)
        }
    }
}

#Preview {
    FloatingButton(destination: AddPropertyView(passedProperty: nil), text: "Add Property")
}
