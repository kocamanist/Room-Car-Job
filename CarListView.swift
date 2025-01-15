//
//  CarView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 15.10.2024.
//

import SwiftUI
import FirebaseFirestore
import Firebase

@MainActor
class CarListViewModel : ObservableObject {
    
    @Published var cars : [Car] = []
    let db = Firestore.firestore()
    
    
    func getCars()  async throws -> [Car] {
        var cars : [Car] = []
        let snapshot = try await db.collection("cars").getDocuments()
        for document in snapshot.documents {
            let car = try document.data(as: Car.self)
            cars.append(car)
            
        }
         return cars
    }
}

struct CarListView: View {
    
    @StateObject var viewModel = CarListViewModel()
    @State private var addCar = false
    @State private var showAlert = false
    @State private var showSignUpView = false
    
    @Binding var showProfileButton: Bool
    
    let backgroundGradient = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.gray.opacity(0.8)],
        startPoint: .leading, endPoint: .trailing)

    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                List {
                    ForEach(viewModel.cars) {
                        car in
                        NavigationLink {
                            CarDetailView()
                        } label: {
                            VStack(alignment: .leading) {
                                Section(
                                    header: HStack(spacing: 20) {
                                        Text(!car.make.isEmpty ? car.make : "not specified").font(.headline)
                                            .foregroundStyle(.white)
                                            .bold()
                                        Text(!car.model.isEmpty ? car.model : "unknown").font(.subheadline)
                                            .foregroundStyle(.white)
                                            .bold()
                                    }
                                        .frame(alignment: .leading)
                                        .background(backgroundGradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                     ) {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(car.photoUrls ?? [], id: \.self) { imageUrl in
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
                        viewModel.cars = try await viewModel.getCars()
                        
                    }
                }
                .navigationTitle("Cars")
                .toolbar {
                    Button {
                        let authUser = try? DatabaseManagement.shared.getAuthenticatedUser()
                        if authUser == nil {
                            self.showAlert = true
                        } else {
                            addCar = true
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
                .sheet(isPresented: $addCar) {
                    AddCarView()
                }
                .sheet(isPresented: $showSignUpView, content: {
                    LoginSignupView(showSignUpView: $showSignUpView, showProfileButton: $showProfileButton)
                })
        }
        
    }
}
#Preview {
    CarListView(showProfileButton: .constant(false))
}
