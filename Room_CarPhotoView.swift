//
//  Room_CarPhotoView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 10.10.2024.
//

import SwiftUI
import PhotosUI

struct Room_CarPhotoView: View {
    
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    var body: some View {
        
        NavigationStack {
         
            VStack(spacing: 20) {
            
                PhotosPicker("Select Images", selection: $selectedItems, maxSelectionCount: 8, matching: .images)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(0..<selectedImages.count, id: \.self) { i in
                        selectedImages[i]
                            .resizable()
                            .frame(width: 160, height: 120)
                    }
                }
            }
        }
            .buttonStyle(.bordered)
            
            .onChange(of: selectedItems) {
                Task {
                    selectedImages.removeAll()
                    for item in selectedItems {
                        if let image =  try? await item.loadTransferable(type: Image.self) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Room_CarPhotoView()
}
