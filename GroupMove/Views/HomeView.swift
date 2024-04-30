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
                                    Text(home.name ?? "Property")
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
                            .listRowInsets(.init(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)))
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
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
