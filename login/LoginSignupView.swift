//
//  LoginSignupView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 10.10.2024.
//

import SwiftUI

@MainActor
final class SignUpViewModel : ObservableObject {
    
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var phoneNumber = ""
   
    @Published private(set) var customer : Customer? = nil
    
    func signUp() async throws {
       
      let authResult = try await DatabaseManagement.shared.createUserWithEmail(email: email, password: password)
        self.customer = Customer(id: authResult.uid, name: name, email: authResult.email ?? "unknown", phoneNumber: phoneNumber, date_created: Date())
        
    }
    
    func createCustomer(customer: Customer) async throws {
       try await CustomerManager.shared.createCustomer(customer: customer)
    }
}

struct LoginSignupView: View {
    
      
    @Binding var showSignUpView : Bool
    @Binding var showProfileButton: Bool
    
    @State private var showLoginView = false
    
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
       
        NavigationStack {
        
        ZStack {
            
            Color.black.opacity(0.2)
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.gray.opacity(0.4), .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
            
            VStack(spacing: 20) {
                
                Text("Welcome")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(y: -100)
                
                TextField("", text: $viewModel.name)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .bold()
                    .placeholder(when: viewModel.name.isEmpty) {
                        Text("Name")
                            .foregroundColor(.black.opacity(0.5))
                            .bold()
                    }
                    .padding(.leading)
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                TextField("", text: $viewModel.phoneNumber)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .bold()
                    .placeholder(when: viewModel.phoneNumber.isEmpty) {
                        Text("Phone Number")
                            .foregroundColor(.black.opacity(0.5))
                            .bold()
                    }
                    .padding(.leading)
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                TextField("", text: $viewModel.email)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .bold()
                    .placeholder(when: viewModel.email.isEmpty) {
                        Text("Email")
                            .foregroundColor(.black.opacity(0.5))
                            .bold()
                    }
                    .padding(.leading)
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                SecureField("", text: $viewModel.password)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .placeholder(when: viewModel.password.isEmpty) {
                        Text("Password")
                            .foregroundColor(.black.opacity(0.5))
                            .bold()
                    }
                    .padding(.leading)
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                SecureField("", text: $viewModel.confirmPassword)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .placeholder(when: viewModel.confirmPassword.isEmpty) {
                        Text("Confirm Password")
                            .foregroundColor(.black.opacity(0.5))
                            .bold()
                    }
                    .padding(.leading)
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                Button {
                    Task {
                        do {
                            try await viewModel.signUp()
                        } catch {
                            return
                        }
                        do {
                            try await viewModel.createCustomer(customer: viewModel.customer!)
                        } catch {
                            return
                        }
                    }
                    self.showSignUpView = false
                    self.showProfileButton = true
                    
                } label: {
                    Text("Sign Up")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(LinearGradient(colors: [.white, .gray.opacity(0.5)], startPoint: .bottom, endPoint: .top))
                        )
                }
                .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.password != viewModel.confirmPassword)
                .padding(.top)
                .offset(y: 20)
                
                NavigationLink {
                    LogInView(showsignUpView: $showSignUpView, showProfileButton: $showProfileButton)
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundStyle(.blue)
                }
                .padding(.top)
                .offset(y: 50)
            }
            
        }
        .ignoresSafeArea()
     }
   }
}
#Preview {
    LoginSignupView(showSignUpView: .constant(false), showProfileButton: .constant(false))
}

extension View {
  func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
    }
}
