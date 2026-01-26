//
//  AdminPlaceReviewView.swift
//  Halal Map Prime
//
//  FINAL – FIXED Map Annotation (Identifiable)
//  Created by Zaid Nahleh
//

import SwiftUI
import MapKit

struct AdminPlaceReviewView: View {

    let place: AdminPlacesViewModel.AdminPlace
    @ObservedObject var vm: AdminPlacesViewModel

    @Environment(\.dismiss) private var dismiss

    // ✅ Identifiable Pin
    struct PinItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )
    }

    @State private var region: MKCoordinateRegion

    init(place: AdminPlacesViewModel.AdminPlace,
         vm: AdminPlacesViewModel) {
        self.place = place
        self.vm = vm
        _region = State(
            initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private var pins: [PinItem] {
        [PinItem(coordinate: coordinate)]
    }

    var body: some View {
        Form {

            // MARK: - Map
            Section("Location") {
                Map(
                    coordinateRegion: $region,
                    annotationItems: pins
                ) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                    }
                }
                .frame(height: 200)

                Button("Open in Apple Maps") {
                    openInMaps()
                }
            }

            // MARK: - Info
            Section("Place Info") {
                row("Name", place.name)
                row("Owner", place.ownerName)
                row("Category", place.categoryId)
            }

            Section("Address") {
                row("Address", place.address)
                row("City", place.city)
                row("State", place.state)
            }

            Section("Contact") {
                row("Phone", place.phone)
                row("Website", place.website)
            }

            Section("Status") {
                row("Requires Approval", place.approvalRequired ? "Yes" : "No")
                row("Approved", place.isApproved ? "Yes" : "No")
            }

            // MARK: - Actions
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
        .navigationTitle("Review Place")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.isEmpty ? "-" : value)
                .multilineTextAlignment(.trailing)
        }
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = place.name
        item.openInMaps()
    }
}
