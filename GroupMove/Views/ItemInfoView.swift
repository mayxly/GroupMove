//
//  ItemInfoView.swift
//  GroupMove
//
//  Created by May Ly on 2024-05-03.
//

import SwiftUI

struct ItemInfoView: View {
    
    @ObservedObject var item: MoveItem
    @ObservedObject var property: Property
    var userList: [String]
    
    @State private var showEditItemView = false
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        if let imageData = item.image, let image = UIImage(data: imageData) {
                          Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 400)
                        } else {
                            Image("boxItem")
                                .resizable()
                                .frame(height: 400)
                        }
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
                            if property.hasBudget {
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
                    
                    if let itemNotes = item.notes {
                        VStack(alignment: .leading) {
                            Text("Notes")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text(itemNotes)
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showEditItemView) {
            if let owner = item.owner {
                AddMoveItemView(passedMoveItem: item, passedProperty: property, currUser: owner, userList: userList)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditItemView.toggle()
                } label: {
                    Text("Edit")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    var viewContext = CoreDataStack.shared.context
    let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
    return ItemInfoView(item: property.items?.anyObject() as! MoveItem, property: property, userList: ["John Doe"])
}
