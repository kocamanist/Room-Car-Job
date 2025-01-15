//
//  AddJob.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 12.11.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Firebase

@MainActor
class AddJobViewModel : ObservableObject {
    
    
    @Published var state = Eyalet.selectState.description
    @Published var city = ""
    @Published var position = ""
    @Published var salary = ""
    @Published var decription = ""
    
    
    
    
    let user = try? DatabaseManagement.shared.getAuthenticatedUser()
   
    let db = Firestore.firestore()
    
    
    func addJob(id: String, jobinfo: Job) async throws {
       try await db.collection("jobs").document(id).setData(from: jobinfo)
      }
}



struct AddJob: View {
  
    @Environment(\.dismiss) var dissmis
   
    
    @StateObject var viewModel = AddJobViewModel()
    
    init() {
            UITextView.appearance().backgroundColor = .clear
        }
    
    var body: some View {
       
        NavigationStack {
            VStack(spacing: 40) {
                
                VStack {
                    
                    Picker("State", selection: $viewModel.state) {
                        ForEach(Eyalet.allCases) { state in
                            Text(state.description).tag(state.description)
                        }
                    }
                }
                   
                    VStack(spacing: 10) {
                       
                        TextField("Position", text: $viewModel.position)
                            .padding(.horizontal, 10)
                            
                        TextField("City", text: $viewModel.city)
                            .padding(.horizontal, 10)
                            
                        TextField("Salary", text: $viewModel.salary)
                            .padding(.horizontal, 10)
                            
                    }
                    .textFieldStyle(.roundedBorder)
                   
                
                VStack {
                        Text("Description")
                            .foregroundStyle(.gray)
                        ScrollView {
                            ZStack(alignment: .topLeading) {
                                Color.gray.opacity(0.2)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                TextEditor(text: $viewModel.decription)
                                   .frame(minHeight: 100, alignment: .leading)
                                   .cornerRadius(6.0)
                                   .multilineTextAlignment(.leading)
                                   .padding(9)
                            }
                        }
                    }
                    
                
                VStack {
                    
                    Button {
                        Task {

                            try await viewModel.addJob(id: viewModel.user?.uid ?? "", jobinfo: Job(customerId: viewModel.user?.uid ?? "", position: viewModel.position, salary: viewModel.salary, state: viewModel.state.description, city: viewModel.city, description: viewModel.decription))
                              dissmis()
                        }
                       
                
                    } label: {
                         Text("Post")
                            .bold()
                            .frame(width: 70)
                            .font(.headline)
                    }
            
                    .buttonBorderShape(.roundedRectangle(radius: 15))
                    .buttonStyle(.borderedProminent)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dissmis()
                    }
                }
            }
            .padding(.top, 80)
        }
     
    }
}

#Preview {
    AddJob()
}

public extension Binding where Value: Equatable {
    
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                } else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}
