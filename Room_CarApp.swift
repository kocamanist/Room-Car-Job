//
//  Room_CarApp.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 10.10.2024.
//

import SwiftUI
import Firebase

@main
struct Room_CarApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
