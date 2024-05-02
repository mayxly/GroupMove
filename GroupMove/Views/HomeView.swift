//
//  HomeView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Property.dateCreated, ascending: true)],
        animation: .default)
    private var homes: FetchedResults<Property>
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List {
                        Section() {
                            ForEach(homes, id: \.self) { home in
                                NavigationLink(destination: PropertyView(property: home)) {
                                    Circle()
                                        .frame(width: 32)
                                        .padding(.vertical, 4)
                                        .foregroundStyle(Color(hex: home.color ?? "#00A5E3"))
                                    Text(home.name ?? "Property")
                                        .bold()
                                        .padding(.horizontal, 8)
                                }
                            }
                        } header: {
                            HStack {
                                Text("My Properties")
                                    .font(.system(size: 16))
                                    .bold()
                                Spacer()
                                Button(action: {
                                    showingSheet.toggle()
                                }) {
                                    Image(systemName: "plus")
                                }
                            }
                            .listRowInsets(.init(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)))
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .navigationTitle("Homes")
            }
            .sheet(isPresented: $showingSheet) {
                AddPropertyView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
