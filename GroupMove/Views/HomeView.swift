//
//  HomeView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Property.dateCreated, ascending: true)],
        animation: .default)
    private var homes: FetchedResults<Property>
    
    @State private var showAddPropertySheet = false
    
    private var stack = CoreDataStack.shared
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    ZStack {
                        List {
                            Section() {
                                ForEach(homes, id: \.self) { home in
                                    NavigationLink(destination: PropertyView(property: home)) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 32)
                                                    .padding(.vertical, 4)
                                                    .foregroundStyle(Color(hex: home.color ?? "#00A5E3"))
                                                Image(systemName: "house.fill")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .padding(.vertical, 4)
                                                    .foregroundColor(.white)
                                            }
                                            Text(home.name ?? "Property")
                                                .bold()
                                                .padding(.horizontal, 8)
                                            if home.isShared {
                                                Spacer()
                                                Image(systemName: "person.2.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20)
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.trailing, 12)
                                            }
                                        }
                                    }
                                    .deleteDisabled(!stack.canDelete(object: home))
                                }
                                .onDelete(perform: delete)
                            } header: {
                                HStack {
                                    Text("My Properties")
                                        .font(.system(size: 16))
                                        .bold()
                                    Spacer()
                                    Button(action: {
                                        showAddPropertySheet.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                }
                                .listRowInsets(.init(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)))
                            }
                        }
                        .listRowSpacing(10)
                        if homes.count < 1 {
                            VStack {
                                Spacer()
                                Text("You don't have any properties yet!")
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .padding(.vertical, 10)
                                    .multilineTextAlignment(.center)
                                Button(action: {
                                    showAddPropertySheet.toggle()
                                }) {
                                    Text("Add Property")
                                }
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .foregroundColor(.white)
                                .background(Color(hex: "00A5E3"))
                                .cornerRadius(30)
                                .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.3), radius: 3, x: 3, y: 3)
                                Spacer()
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Homes")
                .toolbar {
                    if homes.count > 0 {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(passedProperty: nil)
            }
        }
    }
}

extension HomeView {
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let property = homes[index]
            
            if let items = property.items?.allObjects as? [MoveItem] {
                for item in items {
                    stack.deleteMoveItem(item)
                }
            }
            if let rooms = property.rooms?.allObjects as? [Room] {
                for room in rooms {
                    stack.deleteRoom(room)
                }
            }
            stack.deleteProperty(property)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
