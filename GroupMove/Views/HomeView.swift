//
//  HomeView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct HomeView: View {
    
    let homes: [String] = ["home1", "home2"]
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List {
                        Section() {
                            ForEach(homes, id: \.self) { home in
                                NavigationLink(destination: PropertyView()) {
                                    Text(home)
                                }
                            }
                        } header: {
                            Text("My Properties")
                                .font(.system(size: 16))
                                .bold()
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .navigationTitle("Homes")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
