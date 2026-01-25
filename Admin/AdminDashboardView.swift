//
//  AdminDashboardView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-25.
//  Copyright © 2026 Zaid Nahleh.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminAdsDashboardView: View {
    @StateObject private var vm = AdminAdsViewModel()

    var body: some View {
        NavigationStack {
            List {

                // ✅ NEW: Management section (top)
                Section("Management") {

                    // ✅ Places (admin approval / control)
                    NavigationLink {
                        AdminPlacesListView()
                    } label: {
                        Label("Manage Places", systemImage: "mappin.and.ellipse")
                    }

                    // placeholders الآن (ما بتكسر شي)
                    NavigationLink {
                        Text("Jobs admin coming soon")
                            .navigationTitle("Admin • Jobs")
                    } label: {
                        Label("Manage Jobs", systemImage: "briefcase.fill")
                    }

                    NavigationLink {
                        Text("Community admin coming soon")
                            .navigationTitle("Admin • Community")
                    } label: {
                        Label("Manage Community", systemImage: "person.3.fill")
                    }
                }

                // ✅ Existing Ads section (your original code untouched)
                Section("Ads") {

                    if vm.isLoading && vm.items.isEmpty {
                        ProgressView().frame(maxWidth: .infinity)
                    }

                    ForEach(vm.items) { ad in
                        VStack(alignment: .leading, spacing: 6) {

                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ad.businessName.isEmpty ? "Unnamed Business" : ad.businessName)
                                        .font(.headline)

                                    if !ad.headline.isEmpty {
                                        Text(ad.headline)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    Text("ID: \(ad.id)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)

                                    if let owner = ad.ownerKey, !owner.isEmpty {
                                        Text("Owner: \(owner)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 6) {
                                    if ad.adminHidden == true {
                                        Label("HIDDEN", systemImage: "eye.slash.fill")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.red)
                                    } else {
                                        Label("VISIBLE", systemImage: "eye.fill")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.green)
                                    }

                                    if let createdAt = ad.createdAt {
                                        Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }

                            HStack(spacing: 10) {

                                Button {
                                    vm.toggleHidden(ad)
                                } label: {
                                    Label(ad.adminHidden == true ? "Unhide" : "Hide",
                                          systemImage: ad.adminHidden == true ? "eye" : "eye.slash")
                                }
                                .buttonStyle(.bordered)

                                Button(role: .destructive) {
                                    vm.askDelete(ad)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .buttonStyle(.bordered)

                                Spacer()
                            }

                            if let note = ad.adminNote, !note.isEmpty {
                                Text("Note: \(note)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                        .onAppear {
                            vm.loadMoreIfNeeded(current: ad)
                        }
                    }

                    if vm.isLoadingMore {
                        ProgressView().frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Admin • Ads")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Delete Ad?", isPresented: $vm.showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    vm.confirmDelete()
                }
            } message: {
                Text(vm.deleteMessage)
            }
            .onAppear { vm.refresh() }
        }
    }
}
