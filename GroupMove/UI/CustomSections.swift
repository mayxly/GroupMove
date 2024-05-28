//
//  CustomSections.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-24.
//

import SwiftUI

struct BudgetSection: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.white)
                .frame(maxWidth: .infinity, maxHeight: 100)
            VStack {
                HStack {
                    Text("Budget Tracker")
                        .bold()
                    Spacer()
                    Text("$50/$100")
                        .foregroundStyle(Color(hex: "939393"))
                }
                BudgetProgressBar(height: CGFloat(25))
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 30)
    }
}

struct RoomSection: View {
    var roomName: String
    @State private var isCollapsed = false
    @State private var hideText = false
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(maxWidth: .infinity, maxHeight: isCollapsed ? 60 : 250)
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(roomName)
                        .bold()
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            hideText.toggle()
                        }
                        withAnimation(.bouncy) {
                            isCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                            .foregroundColor(.black)
                    }
                }
                if !isCollapsed {
                    RoomNavLink(itemName: "Microwave")
                        .opacity(hideText ? 0 : 100)
                    RoomNavLink(itemName: "Kitchen Chair")
                        .opacity(hideText ? 0 : 100)
                    RoomNavLink(itemName: "Mini fridge")
                        .opacity(hideText ? 0 : 100)
                    RoomNavLink(itemName: "Mini oven")
                        .opacity(hideText ? 0 : 100)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .padding(.horizontal, 30)
    }
}

struct RoomNavLink: View {
    var itemName: String
    
    var body: some View {
        NavigationLink(destination: HomeView()) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: "F4F4F4"))
                    .frame(maxWidth: .infinity, maxHeight: 35)
                HStack {
                    Text(itemName)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }.padding(.horizontal, 15)
            }
        }
    }
}

struct PropertyNameSection: View {
    private var propertyName: String = ""
    private var selectedColor: String = "00A5E3"
    @State private var name: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(maxWidth: .infinity, maxHeight: 175)
                Spacer()
            }
            VStack(alignment: .leading) {
                ZStack {
                    HStack {
                        Spacer()
                        Circle()
                            .frame(width: 80)
                            .foregroundColor(Color(hex: selectedColor))
                            .padding(.top, 20)
                        Spacer()
                    }
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(.black.opacity(0.05))
                        .frame(height: 40)
                        .padding(.horizontal, 20)
                    TextField("Property Name", text: $name)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 30)
    }
}

struct ToggleSection: View {
    @State private var isToggled = false
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(maxWidth: .infinity, maxHeight: 45)
            }
            VStack {
                Toggle("Add Budget", isOn: $isToggled)
                    .padding()
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    let room = "Kitchen"
    @State var propertyName = ""
    
    return
    NavigationStack {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                BudgetSection()
                RoomSection(roomName: room)
                PropertyNameSection()
                ToggleSection()
                Spacer()
            }
        }
    }
}
