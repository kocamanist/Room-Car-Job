//
//  AddCarView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 17.10.2024.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore


@MainActor class AddCarViewModel: ObservableObject {
   
    let user = try? DatabaseManagement.shared.getAuthenticatedUser()
    
    @Published var photoUrls : [String] = []
    @Published var make = ""
    @Published var model = ""
    @Published var year = ""
    @Published var milage = ""
    @Published var fuelType = FuelType.selectFuelType.description
    @Published var price = ""
    @Published var state = Eyalet.selectState.description
    @Published var city = ""
    @Published var description = ""
    
    enum ServiceError : LocalizedError {
        case unabletoGetData
    }
    
    func uploadImages(images: [Image], customerId: String) async throws -> [String] {
        return try await withThrowingTaskGroup(of: URL.self, body: { group in
            for image in images {
                group.addTask {
                    return try await self.uploadImage(image: image, customerId: customerId)
                }
            }
           // var urls: [URL] = []
            for try await url in group {
                self.photoUrls.append(url.absoluteString)
                    }
          //  print(photoUrls)
            return photoUrls
        })
    }
    
    func uploadImage(image: Image, customerId: String) async throws -> URL {
        let storageRef = Storage.storage()
        let imageRef = storageRef.reference().child("CarPhotos").child(customerId).child(UUID().uuidString)
        guard let imageData = image.asUIImage().jpegData(compressionQuality: 0.5) else {
            throw ServiceError.unabletoGetData
        }
        let metadata = try await imageRef.putDataAsync(imageData)
        return try await imageRef.downloadURL()
    }
    
    func addCar(carInfo: Car) async throws {
       try await Firestore.firestore().collection("cars").document().setData(from: carInfo)
    }
}

struct AddCarView: View {
 
    @StateObject var viewModel = AddCarViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    var body: some View {
        
        VStack(spacing: 20) {
           
            VStack {
                Picker("State", selection: $viewModel.state) {
                    ForEach(Eyalet.allCases) { state in
                        Text(state.description).tag(state.description)
                  }
                }
            }
               
            
            VStack(spacing: 10) {
               
                TextField("make", text: $viewModel.make)
                
                TextField("model", text: $viewModel.model)
                
                TextField("year", text: $viewModel.year)
                
                TextField("milage", text: $viewModel.milage)
                
                TextField("price", text: $viewModel.price)
                
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 10)
            
            VStack {
                Picker("Select Fuel Type", selection: $viewModel.fuelType) {
                    ForEach(FuelType.allCases) { fuel in
                        Text(fuel.description).tag(fuel.description)
                    }
                }
            }
            
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
            .foregroundStyle(.blue.opacity(0.7))
            
            VStack {
                Text("Description")
                    .foregroundStyle(.gray)
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        Color.gray.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        TextEditor(text: $viewModel.description)
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
                           try await viewModel.uploadImages(images: selectedImages, customerId: viewModel.user!.uid)
                           try await   viewModel.addCar(carInfo: Car(customerId: viewModel.user?.uid ?? "no id found", make: viewModel.make, model: viewModel.model, year: viewModel.year, milage: viewModel.milage, fuelType: viewModel.fuelType, price: viewModel.price, state: viewModel.state, city: viewModel.city, description: viewModel.description, photoUrls: viewModel.photoUrls))
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

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

#Preview {
    AddCarView()
}
