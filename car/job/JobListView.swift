//
//  JobList.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 16.10.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth


@MainActor
class JobListViewModel : ObservableObject {
    
    @Published var customers : [Customer]? = nil
    @Published private(set) var jobs : [Job] = []
    
    func getAllJobs() async throws {
        self.jobs = try await JobManager.shared.getAllJobs()
    }
    func getrealtimejobs() async throws {
        self.jobs = try await JobManager.shared.getrealtimeJobs()
    }
}

struct JobListView: View {
    
    @StateObject var viewmodel = JobListViewModel()
   
    @State private var addJob = false
    @State private var showSignUpView = false
    @State private var showAlert = false
    
    @Binding var showProfileButton: Bool
    
    var body: some View {
        NavigationStack {
            
            VStack {
                List {
                   
                    ForEach(viewmodel.jobs) { job in
                        NavigationLink {
                            JobDetailView(job: job)
                        } label: {
                            VStack(spacing: 20) {
                                HStack(spacing: 40) {
                                Text(job.state.description)
                                    .font(.title)
                                    .foregroundStyle(.black.opacity(0.9))
                                Text(job.city)
                                    .font(.title2)
                                    .foregroundStyle(.black.opacity(0.8))
                            }
                                Text(job.position)
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Jobs")
            .task {
                try? await viewmodel.getAllJobs()
            }
            .toolbar {
                Button {
                    let authUser = try? DatabaseManagement.shared.getAuthenticatedUser()
                    if authUser == nil {
                        self.showAlert = true
                    } else {
                        addJob = true
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
            .sheet(isPresented: $addJob, content: {
                AddJob()
            })
            .sheet(isPresented: $showSignUpView, content: {
                LoginSignupView(showSignUpView: $showSignUpView, showProfileButton: $showProfileButton)
            })
            .navigationBarTitleDisplayMode(.inline)
        }
   
    }
}

#Preview {
    JobListView(showProfileButton: .constant(false))
}
