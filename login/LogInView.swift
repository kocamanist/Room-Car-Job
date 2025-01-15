//
//  LogInView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 4.12.2024.
//

import SwiftUI
import FirebaseAuth

@MainActor
class LogInViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var user : AuthDataResultModel? = nil
    
    func logIn() async throws {
   
        do { 
            self.user = try await  DatabaseManagement.shared.login(email: email, password: password)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct LogInView: View {
    
    @ObservedObject var viewModel = LogInViewModel()
    
    @State var email = ""
    @State var password = ""
    
    @Binding var showsignUpView : Bool
    @Binding var showProfileButton: Bool
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            SecureField("password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            Button {
                Task {
                    try await viewModel.logIn()
                    if viewModel.user != nil {
                        showsignUpView = false
                        self.showProfileButton = true
                    }
                }
                
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(35.0)
            }
        }
    }
}

#Preview {
    LogInView(showsignUpView: .constant(false), showProfileButton: .constant(false))
}
