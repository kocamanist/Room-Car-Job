//
//  Models.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 15.10.2024.
//

import Foundation


struct Customer: Codable, Identifiable {
    var id : String
    var name: String
    var email: String
    var phoneNumber: String
    var job : [Job]?
    var car: [Car]?
    var room: [Room]?
    var date_created : Date
}

struct Job : Codable, Identifiable {
    
    var id : String = UUID().uuidString
    var customerId : String
    var position: String
    var salary: String?
    var state: String
    var city: String
    var description: String
    var dateCreated = Date()
}

struct Car: Codable, Identifiable {
    var id: String = UUID().uuidString
    var customerId: String
    var make: String
    var model: String
    var year: String
    var milage: String
    var fuelType: String
    var price: String
    var state: String
    var city : String
    var description: String
    var photoUrls: [String]?
    var dateCreated = Date()
}

struct Room: Codable, Identifiable {
    var id : String = UUID().uuidString
    var customerId: String
    var state: String
    var city: String
    var price: String
    var description: String
    var photoUrls : [String]?
    var dateCreated = Date()
}


enum Eyalet : CaseIterable, Identifiable, CustomStringConvertible, Codable {
   
    case selectState
    case NY
    case NJ
    case PA
    case CT
  
   
    var id: Self { self }
    
    var description: String {
        switch self {
            
        case .selectState:
            return "Select State"
        case .NY :
            return "New York"
        case .NJ :
            return "New Jersey"
        case .PA :
            return "Pensilvanya"
        case .CT :
            return "Connecticut"
        }
    }
}

enum FuelType : CaseIterable, Identifiable, CustomStringConvertible, Codable {
    case selectFuelType
    case gasoline
    case diesel
    case electricity
    
    var id : Self { self }
    
    var description : String {
        switch self {
       
        case .selectFuelType:
            return "Select Fuel Type"
        case .gasoline:
            return "Gasoline"
        case .diesel:
           return "Diesel"
        case .electricity:
           return "Electricity"
        }
    }
}
