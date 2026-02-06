//
//  AdminEventsDashboardView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import SwiftUI

struct AdminEventsDashboardView: View {
    @StateObject private var vm = AdminEventsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if vm.isLoading && vm.items.isEmpty {
                    ProgressView().frame(maxWidth: .infinity)
                }

                ForEach(vm.items) { e in
                    VStack(alignment: .leading, spacing: 6) {

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(e.title.isEmpty ? "Event" : e.title)
                                    .font(.headline)

                                if !e.category.isEmpty {
                                    Text("Category: \(e.category)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                if !e.city.isEmpty {
                                    Text("City: \(e.city)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text("Source: \(e.source.rawValue)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                Text("ID: \(e.id)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                if let owner = e.ownerKey, !owner.isEmpty {
                                    Text("Owner: \(owner)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 6) {
                                if e.adminHidden == true {
                                    Label("HIDDEN", systemImage: "eye.slash.fill")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.red)
                                } else {
                                    Label("VISIBLE", systemImage: "eye.fill")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.green)
                                }

                                if let createdAt = e.createdAt {
                                    Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        HStack(spacing: 10) {
                            Button { vm.toggleHidden(e) } label: {
                                Label(e.adminHidden == true ? "Unhide" : "Hide",
                                      systemImage: e.adminHidden == true ? "eye" : "eye.slash")
                            }
                            .buttonStyle(.bordered)

                            Button(role: .destructive) { vm.askDelete(e) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)

                            Spacer()
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Admin • Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { vm.refresh() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .alert("Delete Event?", isPresented: $vm.showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { vm.confirmDelete() }
            } message: {
                Text(vm.deleteMessage)
            }
            .onAppear { vm.refresh() }
        }
    }
}
