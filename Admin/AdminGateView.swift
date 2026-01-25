//
//  AdminGateView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-25.
//

import SwiftUI

struct AdminGateView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {

                Section("Admin") {

                    NavigationLink("📢 Ads Dashboard") {
                        AdminAdsDashboardView()
                    }

                    NavigationLink("💼 Jobs") {
                        Text("Jobs admin coming soon")
                            .navigationTitle("Jobs")
                    }

                    NavigationLink("📅 Events") {
                        Text("Events admin coming soon")
                            .navigationTitle("Events")
                    }

                    NavigationLink("📍 Places") {
                        AdminPlacesListView()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text("Close Admin")
                    }
                }
            }
            .navigationTitle("Admin Panel")
        }
    }
}
