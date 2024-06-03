//
//  HomeView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI
import CloudKit

struct NewHomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Property.dateCreated, ascending: true)],
        animation: .default)
    private var homes: FetchedResults<Property>
    
    @State private var showAddPropertySheet = false
    
    private var stack = CoreDataStack.shared
    @ObservedObject private var ckUserData = CloudUserData.shared
    
    var homesList: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "333333").ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("Homes")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    ScrollView {
                        ForEach(homes, id: \.self) { home in
                            HomeNavLink(home: home)
                        }
                        .listRowSpacing(10)
                    }
                    //                .swipeActions(content: delete)
                    
                    Button {
                        showAddPropertySheet.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "1FB1F0"))
                                .frame(width: 75, height: 75)
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.white)
                        }
                        
                    }
                }
                .padding(20)
            }
        }
    }
    
    var body: some View {
        ZStack {
            homesList
        }
        .sheet(isPresented: $showAddPropertySheet) {
            AddPropertyView(passedProperty: nil)
        }
    }
    
    
}

extension NewHomeView {
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

struct HomeNavLink: View {
    var home: Property
    let propertyManager = PropertyManager.shared
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: "3D3D3D"))
                .frame(maxWidth: .infinity, minHeight: 60)
            Button {
                propertyManager.setNewActiveProperty(property: home)
            } label: {
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
                    Text(home.name ?? "My House")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .opacity(propertyManager.activeProperty == home ? 100 : 0)
                }.padding(.horizontal, 15)
            }
        }
    }
}

struct NewHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
    }
}
