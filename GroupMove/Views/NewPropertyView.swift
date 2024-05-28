//
//  NewPropertyView.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-24.
//

import SwiftUI

struct NewPropertyView: View {
    @State private var mode = 0
    let propertyColor = "1FB1F0"
    
    let views = ["Overview", "Moving List"]
    @State private var selectedView = "Overview"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F5F5F5").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Blair House")
                    CustomSegmentedPicker(options: views, selectedOption: $selectedView)
                    BudgetSection()
                    RoomSection(roomName: "Kitchen")
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NewPropertyView()
}
