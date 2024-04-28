//
//  PropertyView.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-28.
//

import SwiftUI

struct PropertyView: View {
    var body: some View {
        VStack {
            List {
                Text("Temp")
            }
        }
        .navigationTitle("My Property")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView()
    }
}
