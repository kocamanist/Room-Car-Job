//
//  JobDetailView.swift
//  Room&Car
//
//  Created by Muhammed Kocaman on 15.12.2024.
//

import SwiftUI

struct JobDetailView: View {
    var job : Job
   
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                Text(job.dateCreated.formatted(date: .numeric, time: .omitted))
                
                Text(job.state)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                Text(job.city)
                    .font(.title)
                    .foregroundStyle(.blue.opacity(0.8))
                Text(job.position)
                    .font(.title2)
                    .foregroundStyle(.red)
                if !job.salary!.isEmpty {
                    Text("\(job.salary ?? "")$")
                        .font(.title3)
                        .foregroundStyle(.red.opacity(0.8))
                } else {
                    Text("salary is unknown")
                        .foregroundStyle(.secondary)
                }
                Text(job.description)
                    .font(.headline)
           }
        }
    }
}

#Preview {
    JobDetailView(job: Job(customerId: "", position: "", state: "", city: "", description: ""))
}
