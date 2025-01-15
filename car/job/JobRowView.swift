//
//  JobRowView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 13.12.2024.
//

import SwiftUI

struct JobRowView: View {
    
    var job : Job
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    JobRowView(job: Job(customerId: "", position: "", state: "", city: "", description: ""))
}
