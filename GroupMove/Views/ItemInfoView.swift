//
//  ItemInfoView.swift
//  GroupMove
//
//  Created by May Ly on 2024-05-03.
//

import SwiftUI

struct ItemInfoView: View {
    
    var item: MoveItem = MoveItem()
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        Image("boxItem")
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 400)
                    }
                }
            }
            ZStack(alignment: .top) {
                Color(UIColor.systemBackground)
                    .cornerRadius(30)
                    .frame(height: 100)
                    .offset(y: -30)
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Lamp")
                                .font(.title)
                                .bold()
                            Spacer()
                            Text("$14.99")
                        }
                        Text("Added by May Ly")
                            .foregroundColor(.gray)
                        Text("Bedroom")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                            .foregroundColor(.white)
                            .background(.black.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s")
                    }
                    .padding()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    ItemInfoView()
}
