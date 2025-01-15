//
//  RoomListView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 26.11.2024.
//

import SwiftUI
import Firebase

@MainActor
class RoomlistViewModel : ObservableObject {
    @Published var rooms : [Room] = []
    
    let db = Firestore.firestore()
    func getRooms() async throws -> [Room] {
        var rooms : [Room] = []
       let snapshots = try await db.collection("rooms").getDocuments()
        for document in snapshots.documents {
            let room = try document.data(as: Room.self)
            rooms.append(room)
        }
        return rooms
    }
}

struct RoomListView: View {
   
    @StateObject var viewModel = RoomlistViewModel()
    @Binding var showProfileButton: Bool
    
    @State private var addRoom = false
    @State private var showAlert = false
    @State private var showSignUpView = false
    
    let backgroundGradient = LinearGradient(
        colors: [Color.blue.opacity(0.8), Color.gray.opacity(0.8)],
        startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.rooms) {
                        room in
                        NavigationLink {
                            RoomDetailView()
                        } label: {
                            VStack(alignment: .leading) {
                                Section(
                                    header: HStack(spacing: 20) {
                                        Text(!room.city.isEmpty ? room.city : "not specified").font(.headline)
                                            .foregroundStyle(.white)
                                            .bold()
                                        Text(!room.price.isEmpty ? room.price : "unknown").font(.subheadline)
                                            .foregroundStyle(.white)
                                            .bold()
                                    }
                                        .frame(alignment: .leading)
                                        .background(backgroundGradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                     ) {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(room.photoUrls ?? [], id: \.self) { imageUrl in
                                               let url = URL(string: imageUrl)
                                              AsyncImage(url: url) { image in
                                                      image
                                                      .resizable()
                                                      .scaledToFill()
                                                      .frame(width: 80, height: 80)
                                                      .clipped()
                                                      .clipShape(RoundedRectangle(cornerRadius: 10))
                                              } placeholder: {
                                                  ProgressView()
                                              }
                                          }
                                        }
                                        .padding(2)
                                    }
                                    
                                }

                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    viewModel.rooms = try await viewModel.getRooms()
                }
            }
            .navigationTitle("Rooms")
            .toolbar {
                Button {
                    let authUser = try? DatabaseManagement.shared.getAuthenticatedUser()
                    if authUser == nil {
                        self.showAlert = true
                    } else {
                        addRoom = true
                    }
                    
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Uyelik"),
                      message: Text("ilan vermek icin lutfen uye olunuz"),
                      primaryButton: .destructive(Text("Ok")) {
                      self.showSignUpView = true
                },
                      secondaryButton: .cancel())
            }
            .sheet(isPresented: $addRoom, content: {
                AddRoom()
            })
            .sheet(isPresented: $showSignUpView, content: {
                LoginSignupView(showSignUpView: $showSignUpView, showProfileButton: $showProfileButton)
            })

        }
    }
}

#Preview {
    RoomListView(showProfileButton: .constant(false))
}
