//
//  EventAdsBoardView.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import SwiftUI

struct EventAdsBoardView: View {

    @EnvironmentObject var lang: LanguageManager
    @ObservedObject private var service = EventAdsService.shared

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    var body: some View {
        NavigationStack {
            Group {
                if service.isLoading && service.events.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if service.events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)

                        Text(lang.isArabic ? "لا توجد فعاليات حالياً" : "No events yet")
                            .font(.title3.bold())

                        Text(lang.isArabic ?
                             "عندما يقوم المجتمع بنشر فعاليات (بازار، محاضرات، أنشطة)، ستظهر هنا." :
                             "When the community starts posting events (bazaars, lectures, activities), they will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(service.events) { event in
                        eventRow(event)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(lang.isArabic ? "فعاليات المجتمع" : "Community events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: EventAdComposerView().environmentObject(lang)
                    ) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .onAppear { service.startListening() }
            .onDisappear { service.stopListening() }
        }
    }

    @ViewBuilder
    private func eventRow(_ event: EventAd) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(dateFormatter.string(from: event.eventDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack(spacing: 12) {
                Label(event.city, systemImage: "mappin.and.ellipse")
                Label(event.placeName, systemImage: "building.2")
                Label(event.contact, systemImage: "phone.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}
