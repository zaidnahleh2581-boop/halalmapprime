//
//  AdminPlacesListView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//

import SwiftUI

struct AdminPlacesListView: View {

    @StateObject private var vm = AdminPlacesViewModel()

    var body: some View {
        NavigationStack {
            List {

                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                if let err = vm.lastError, !err.isEmpty {
                    Text(err)
                        .foregroundStyle(.red)
                }

                if !vm.isLoading && vm.pendingPlaces.isEmpty {
                    Text("No pending places")
                        .foregroundStyle(.secondary)
                }

                ForEach(vm.pendingPlaces, id: \.id) { place in
                    NavigationLink {
                        AdminPlaceReviewView(place: place, vm: vm)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.displayTitle)
                                .font(.headline)

                            Text(place.placeType)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(place.displayAddress)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Admin • Places")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.loadPending()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                vm.loadPending()
            }
        }
    }
}
