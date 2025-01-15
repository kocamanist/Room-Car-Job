//
//  AddRoom.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 26.11.2024.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@MainActor
class AddRoomViewModel : ObservableObject {
  
    let userId = Auth.auth().currentUser?.uid
    @Published var photoUrls : [String] = []
   
    enum ServiceError : LocalizedError {
        case unabletoGetData
    }
    
    @Published  var selectedState: String = Eyalet.selectState.description
    @Published  var city: String = ""
    @Published  var zipCode: String = ""
    @Published  var price: String = ""
    @Published  var description: String = ""

    
    func uploadImages(images: [Image], customerId: String) async throws -> [String] {
        return try await withThrowingTaskGroup(of: URL.self) { group in
            for image in images {
                group.addTask {
                    return try await self.uploadImage(image: image, customerId: customerId)
                }
            }
            for try await url in group {
                self.photoUrls.append(url.absoluteString)
            }
            return photoUrls
        }
    }
    
    func uploadImage(image: Image, customerId: String) async throws -> URL {
        let storage = Storage.storage()
        let imageRef = storage.reference().child("RoomPhotos").child(customerId).child(UUID().uuidString)
        guard let imageData = image.asUIImage().jpegData(compressionQuality: 0.5) else {
            throw ServiceError.unabletoGetData
        }
        let metaData = try await imageRef.putDataAsync(imageData)
        return try await imageRef.downloadURL()
    }
    
    func addRoom(roomInfo: Room) async throws {
        let db = Firestore.firestore()
        try await db.collection("rooms").document().setData(from: roomInfo)
    }
}

struct AddRoom: View {

    @StateObject var viewmodel = AddRoomViewModel()
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            VStack {
                Picker("State", selection: $viewmodel.selectedState) {
                    ForEach(Eyalet.allCases) { state in
                        Text(state.description).tag(state.description)
                    }
                }
            }
            
            VStack(spacing: 10) {
                
                TextField("City", text: $viewmodel.city)
                    .padding(.horizontal, 10)
                
                TextField("Price", text: $viewmodel.price)
                    .padding(.horizontal, 10)
                
            }
            .textFieldStyle(.roundedBorder)
           
            
            VStack {
                PhotosPicker("Load image", selection: $pickerItems, maxSelectionCount: 6, matching: .images)
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(0..<selectedImages.count, id: \.self) {
                            i in
                            selectedImages[i]
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        }
                    }
                }
                
            }
            
            VStack {
                Text("Description")
                    .foregroundStyle(.gray)
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        Color.gray.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        /*     Text(description)
                         .padding()
                         .opacity(description.isEmpty ? 1 : 0)
                         */
                        TextEditor(text: $viewmodel.description)
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
                        do {
                            try await viewmodel.uploadImages(images: selectedImages, customerId: viewmodel.userId ?? "no id")
                            try await viewmodel.addRoom(roomInfo: Room(customerId: viewmodel.userId ?? " no user Id", state: viewmodel.selectedState, city: viewmodel.city, price: viewmodel.price, description: viewmodel.description, photoUrls: viewmodel.photoUrls))
                            dismiss()
                        } catch {
                              print(error)
                        }
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
         //   .padding(.bottom, 40)
            
        }
        .textFieldStyle(.roundedBorder)
        .onChange(of: pickerItems) {
            Task {
                selectedImages.removeAll()
                for item in pickerItems {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImages.append(loadedImage)
                    }
                }
            }
        }
        .padding(.top, 50)
      }
    }

#Preview {
    AddRoom()
}
