//
//  AdminPlaceReviewView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//

import SwiftUI
import FirebaseFirestore

struct AdminPlaceReviewView: View {

    let place: PlaceSubmission
    @ObservedObject var vm: AdminPlacesViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {

            Section("Place") {
                row("Name", place.placeName)
                row("Type", place.placeType)
                row("Address", place.addressLine)
                row("City", place.city)
                row("State", place.state)
            }

            Section("Contact") {
                row("Phone", place.phone ?? "")
                row("Website", place.website ?? "")
                if let stop = place.foodTruckStop, !stop.isEmpty {
                    row("Food Truck Stop", stop)
                }
            }

            Section("Meta") {
                row("OwnerId", place.ownerId ?? "")
                row("Free Ad", (place.isFreeAd ?? false) ? "true" : "false")
                if let ts = place.createdAt?.dateValue() {
                    row("Created", ts.formatted(date: .abbreviated, time: .shortened))
                }
                row("Status", place.status ?? "pending")
            }

            Section {
                Button {
                    vm.approve(place)
                    dismiss()
                } label: {
                    Label("Approve", systemImage: "checkmark.seal.fill")
                }

                Button(role: .destructive) {
                    vm.reject(place)
                    dismiss()
                } label: {
                    Label("Reject", systemImage: "xmark.seal.fill")
                }

                Button(role: .destructive) {
                    vm.delete(place)
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.isEmpty ? "-" : value)
                .multilineTextAlignment(.trailing)
        }
    }
}
