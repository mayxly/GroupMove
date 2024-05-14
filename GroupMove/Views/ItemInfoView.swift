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
    @ObservedObject var participants: ParticipantInfoViewModel
    
    @State private var showEditItemView = false
    
    private let stack = CoreDataStack.shared
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        if let imageData = item.image, let image = UIImage(data: imageData) {
                          Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                        } else {
                            Image("boxItem")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                }
            }
            ZStack(alignment: .top) {
                Color(UIColor.systemBackground)
                    .cornerRadius(20)
                    .frame(height: 100)
                    .offset(y: -35)
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
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showEditItemView) {
            AddMoveItemView(passedMoveItem: item, passedProperty: property, participants: participants)
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditItemView.toggle()
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4)
                }
                .disabled(!stack.canEdit(object: property))
            }
        }
    }
    
    // Custom back button
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.8), radius: 4)
            Text("Back")
                .foregroundStyle(.white)
                .bold()
                .shadow(color: .black.opacity(0.8), radius: 4)
        }
    }
}

#Preview {
    let viewContext = CoreDataStack.shared.context
    let property = PreviewManager.shared.getPropertyWithItemsAndRooms(context: viewContext)
    let participants = ParticipantInfoViewModel()
    participants.currUser = "Default User"
    participants.allParticipants = ["Default User"]
    
    return ItemInfoView(item: property.items?.anyObject() as! MoveItem, property: property, participants: participants)
}
