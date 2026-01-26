//
//  AdminPlacesListView.swift
//  Halal Map Prime
//
//  FINAL – Works with AdminPlacesViewModel(loadAll)
//  Created by Zaid Nahleh
//

import SwiftUI

struct AdminPlacesListView: View {

    @StateObject private var vm = AdminPlacesViewModel()

    enum Tab: String, CaseIterable, Identifiable {
        case pending = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .pending

    var body: some View {
        NavigationStack {
            List {

                // Loading
                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }

                // Error
                if let err = vm.lastError, !err.isEmpty {
                    Text(err).foregroundStyle(.red)
                }

                // Content
                let items = currentItems()

                if !vm.isLoading && items.isEmpty {
                    Text(emptyText())
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { place in
                        NavigationLink {
                            AdminPlaceReviewView(place: place, vm: vm)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(place.name.isEmpty ? "Unnamed" : place.name)
                                    .font(.headline)

                                if !place.categoryId.isEmpty {
                                    Text(place.categoryId)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text("\(place.address), \(place.city), \(place.state)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Admin • Places")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("", selection: $tab) {
                        ForEach(Tab.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.loadAll()   // ✅ الصحيح
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                vm.loadAll()       // ✅ الصحيح
            }
        }
    }

    private func currentItems() -> [AdminPlacesViewModel.AdminPlace] {
        switch tab {
        case .pending:  return vm.pending
        case .approved: return vm.approved
        case .rejected: return vm.rejected
        }
    }

    private func emptyText() -> String {
        switch tab {
        case .pending:  return "No pending places"
        case .approved: return "No approved places"
        case .rejected: return "No rejected places"
        }
    }
}
