//
//  AdminJobsDashboardView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import SwiftUI

struct AdminJobsDashboardView: View {
    @StateObject private var vm = AdminJobsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if vm.isLoading && vm.items.isEmpty {
                    ProgressView().frame(maxWidth: .infinity)
                }

                ForEach(vm.items) { ad in
                    VStack(alignment: .leading, spacing: 6) {

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ad.type.isEmpty ? "Job" : ad.type)
                                    .font(.headline)

                                if !ad.category.isEmpty {
                                    Text("Category: \(ad.category)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                if !ad.city.isEmpty {
                                    Text("City: \(ad.city)")
                                        .font(.caption)
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

                        if !ad.text.isEmpty {
                            Text(ad.text)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(6)
                                .padding(.top, 2)
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
                    }
                    .padding(.vertical, 6)
                    .onAppear { vm.loadMoreIfNeeded(current: ad) }
                }

                if vm.isLoadingMore {
                    ProgressView().frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Admin • Jobs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { vm.refresh() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .alert("Delete Job?", isPresented: $vm.showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { vm.confirmDelete() }
            } message: {
                Text(vm.deleteMessage)
            }
            .onAppear { vm.refresh() }
        }
    }
}
