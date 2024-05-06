//
//  ItemInfoView.swift
//  GroupMove
//
//  Created by May Ly on 2024-05-03.
//

import SwiftUI

struct ItemInfoView: View {
    
    var item: MoveItem
    var propertyHasBudget: Bool
    
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
                            Text(item.name ?? "Name")
                                .font(.title)
                                .bold()
                            Spacer()
                            if propertyHasBudget {
                                if item.price == 0 {
                                    Text("Free")
                                } else {
                                    Text("$"+String(format: "%.2f", item.price))
                                }
                            }
                        }
                        Text("Added by \(item.owner ?? "Owner")")
                            .foregroundColor(.gray)
                        Text(item.room?.name ?? "Room")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                            .foregroundColor(.white)
                            .background(.gray.opacity(0.5))
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
    var viewContext = CoreDataStack.shared.context
    let item = PreviewManager.shared.getMoveItem(context: viewContext)
    return ItemInfoView(item: item, propertyHasBudget: true)
}
