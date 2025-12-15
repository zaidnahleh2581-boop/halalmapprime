//
//  AddPlaceView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//

import SwiftUI
import MapKit

struct AddPlaceView: View {

    @Environment(\.dismiss) private var dismiss

    let initialCoordinate: CLLocationCoordinate2D
    let onAdd: (Place) -> Void

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var cityState: String = ""
    @State private var category: PlaceCategory = .restaurant

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("City, State", text: $cityState)
                }

                Section("Category") {
                    Picker("Type", selection: $category) {
                        ForEach(PlaceCategory.allCases) { c in
                            Text(c.displayName).tag(c)
                        }
                    }
                }

                Section("Location (auto from map center)") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        Text(String(format: "%.6f", initialCoordinate.latitude))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Longitude")
                        Spacer()
                        Text(String(format: "%.6f", initialCoordinate.longitude))
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedCity = cityState.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !trimmedName.isEmpty else { return }
                        guard !trimmedAddress.isEmpty else { return }
                        guard !trimmedCity.isEmpty else { return }

                        // ✅ Food places start Unverified (isCertified = false)
                        // ✅ Community places are effectively “OK” immediately
                        let newPlace = Place(
                            id: UUID().uuidString,
                            name: trimmedName,
                            address: trimmedAddress,
                            cityState: trimmedCity,
                            latitude: initialCoordinate.latitude,
                            longitude: initialCoordinate.longitude,
                            category: category,
                            rating: 0,
                            reviewCount: 0,
                            deliveryAvailable: false,
                            isCertified: category.requiresVerification ? false : true
                        )

                        onAdd(newPlace)
                        dismiss()
                    } label: {
                        Text("Add to Map")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Add Place")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
