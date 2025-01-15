//
//  ProfileView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 26.11.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

@MainActor
final class ProfileViewModel : ObservableObject {
    
    @Published private(set) var customer : Customer? = nil
    
    let user = try? DatabaseManagement.shared.getAuthenticatedUser()
    
    func getCustomer() async throws {
        if let id = user?.uid {
            self.customer =  try await CustomerManager.shared.getCustomer(customerId: id)
        }
       
    }

          
    func signOut() throws {
       try DatabaseManagement.shared.signOut()
    }
    
    func resetPassword() async throws {
       
        let user = try DatabaseManagement.shared.getAuthenticatedUser()
           guard let email = user.email else {
               throw URLError(.fileDoesNotExist)
           }
           
        try await DatabaseManagement.shared.resetPassword(email: email)
    }
}

struct ProfileView: View {
   
    @Environment(\.dismiss) var dismiss
    
    @Binding var showProfileButton: Bool
    @Binding var showProfileView: Bool
    
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
     
        NavigationStack {
           
            VStack(spacing: 40) {
                
                VStack(spacing: 15) {
                    Text(viewModel.customer?.name ?? "")
                        .font(.largeTitle)
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(.leading, 10)
                    Text(viewModel.customer?.phoneNumber ?? "")
                        .font(.headline)
                        .foregroundStyle(Color.gray)
                        .padding(.leading, 10)
                }
                
                
                List {
                    Button {
                        Task {
                            do {
                                try viewModel.signOut()
                            } catch {
                                print("error while logging out")
                            }
                        }
                        showProfileButton = false
                        // showProfileView = false
                        dismiss()
                        
                    } label: {
                        Text("Sign Out")
                    }
                    
             /*       Button {
                        Task {
                            do {
                                try await viewModel.resetPassword()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } label: {
                        Text("reset password")
                    }
              */
                }
                
            }
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    try await viewModel.getCustomer()
                }
            }
            .padding(.top, 30)
        }
    }
}

#Preview {
    ProfileView(showProfileButton: .constant(false), showProfileView: .constant(false))
}
