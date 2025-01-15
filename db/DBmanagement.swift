//
//  DBmanagement.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 24.11.2024.
//

import Foundation
import FirebaseAuth
import Firebase

struct AuthDataResultModel {
    var uid: String
    var email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class DatabaseManagement {
    
    static let shared = DatabaseManagement()
    private init() {  }
  
    @discardableResult
    func createUserWithEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let authSignUpResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let authDataResultModel = AuthDataResultModel(user: authSignUpResult.user)
        return authDataResultModel
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func login(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult 
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func resetPassword(email: String) async throws {
       
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

class FirestoreManager : ObservableObject {
    
    
    func creatingPost(postType: String, id: String, data: Dictionary<String, Any>) {
        let db = Firestore.firestore()
        let docRef = db.collection(postType).document(id)
        docRef.setData(data)
    }
    
    func signIn(email: String, password: String) async throws {
       try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
}

class CustomerManager {
   
   static let shared = CustomerManager()
    init() { }
  
    let customerCollection = Firestore.firestore().collection("customers")
    
    func createCustomer(customer: Customer) async throws {
        
        try await customerCollection.document(customer.id).setData(from: customer)
    }
    
  
    func getCustomer(customerId: String) async throws -> Customer {
        
        let snapshot = try await customerCollection.document(customerId).getDocument()
               
                guard let data = snapshot.data() else {
                    throw FirebaseError.failedtoCreateCustomer
                }
                return Customer(
                    id: data["id"] as! String,
                    name: data["name"] as! String,
                    email: data["email"] as! String,
                    phoneNumber: data["phoneNumber"] as! String,
                    date_created: Date())
    }
}

class JobManager {
  
    static let shared = JobManager()
    
    func getAllJobs() async throws -> [Job] {
        
        let snapshot = try await Firestore.firestore().collection("jobs").getDocuments()
        var jobs : [Job] = []
        for document in snapshot.documents {
            let job =  try document.data(as: Job.self)
            jobs.append(job)
        }
        return jobs
    }
   
    // check here
    func getrealtimeJobs() async throws -> [Job] {
      
        var jobs : [Job] = []
        Firestore.firestore().collection("jobs").addSnapshotListener { (querySnapShot, error) in
            guard let documents = querySnapShot?.documents else {
                print("no document")
                return
            }
           
            jobs = documents.map { (queryDocumentSnapshot) -> Job in
                let data = queryDocumentSnapshot.data()
                return  Job(id: data["id"] as! String, customerId: data["customerId"] as! String, position: data["position"] as! String, state: data["state"] as! String, city: data["city"] as! String, description: data["description"] as! String, dateCreated: data["dateCreated"] as? Date ?? Date() )
            }
        }
        return jobs
    }
}

enum FirebaseError : Error {
    case failedtoCreateCustomer
    case wrongEmail
    
    var description : String {
        switch self {
        case .failedtoCreateCustomer:
            "failed to create customer"
        case .wrongEmail:
            "it is wrong email"
        }
    }
}
