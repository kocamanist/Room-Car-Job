//
//  HomeView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 12.10.2024.
//

import SwiftUI
import Firebase

//MARK: check for profile button

struct HomeView: View {
  
    @State private var jobSelected = false
    
    @State private var showProfileView = false
    
    @State private var showProfileButton = false
    
    var body: some View {
        
        NavigationStack {
        
                VStack {
                
                NavigationLink {
                    JobListView(showProfileButton: $showProfileButton)
                } label: {
                    
                    GeometryReader { proxy in
                        Image("job")
                            .resizable()
                            .frame(width: proxy.size.width * 1, height: proxy.size.height * 0.5)
                            .scaledToFill()
                    }
                }
                
                NavigationLink {
                    CarListView(showProfileButton: $showProfileButton)
                } label: {
                    
                    GeometryReader { proxy in
                        Image("car")
                            .resizable()
                            .frame(width: proxy.size.width * 1, height: proxy.size.height * 0.5)
                            .scaledToFill()
                    }
                }
                
                
                NavigationLink {
                    RoomListView(showProfileButton: $showProfileButton)
                } label: {
                    
                    GeometryReader { proxy in
                        Image("room")
                            .resizable()
                            .frame(width: proxy.size.width , height: proxy.size.height * 0.5)
                        
                    }
                }
                
            }
                .toolbar {
                    if showProfileButton {
                        ToolbarItem(placement: .topBarTrailing) {
                         
                            NavigationLink {
                                ProfileView(showProfileButton: $showProfileButton, showProfileView: $showProfileView)
                            } label: {
                                Image(systemName: "person.fill")
                            }
                            
                            /*         Button {
                                            self.showProfileView = true
                                        } label: {
                                            Image(systemName: "person.fill")
                                        }
                                */
                            }

                    }
                }
                .sheet(isPresented: $showProfileView, content: {
                    ProfileView(showProfileButton: $showProfileButton, showProfileView: $showProfileView)
                })
                
                .padding(.top, 50)
         }
        .onAppear {
          let user = try? DatabaseManagement.shared.getAuthenticatedUser()
            if user != nil {
                showProfileButton = true
            }
        }
 
       }
    }

#Preview {
    HomeView()
}
