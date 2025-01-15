//
//  ErrorView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 17.12.2024.
//

import SwiftUI


class UserViewModel: ObservableObject {
    @Published var userList = [String]()
    @Published var userError : UserError? = nil
    
   @MainActor
    func loadUser(withError: Bool) async {
        if withError {
            userError = UserError.failedLoading
        } else {
            userList = ["m", "k", "l"]
        }
    }
}


enum UserError : Error {
    case failedLoading
    
    var description : String {
        switch self {
        case .failedLoading:
            return "failed to load, try again 😊"
        }
    }
}

struct UserView: View {
    
    @ObservedObject var userViewModel = UserViewModel()
    
    var body: some View {
        ZStack {
            List(userViewModel.userList, id: \.self) { user in
                Text(user)
            }
            
            if let error = userViewModel.userError {
                ErrorView(errorTitle: error.description, viewModel: userViewModel)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            await userViewModel.loadUser(withError: true)
        }
    }
}

struct ErrorView : View {
    let errorTitle: String
    @ObservedObject var viewModel : UserViewModel
   
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.red)
            .overlay {
                VStack {
                    Text(errorTitle)
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    
                    Button {
                        Task {
                            await viewModel.loadUser(withError: false)
                        }
                    } label: {
                        Text("reload users")
                    }
                }
            }
            
    }
}

#Preview {
    UserView()
}
