//
//  CustomSections.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-24.
//

import SwiftUI

struct BackgroundRect: View {
    var height: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color(hex: "333333"))
            .frame(maxWidth: .infinity, maxHeight: CGFloat(height))
    }
}



#Preview {
    let room = "Kitchen"
    @State var propertyName = ""
    
    return
    NavigationStack {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                Spacer()
//                BackgroundRect(height: 120)
//                    .padding(.horizontal, 20)
            }
        }
    }
}
