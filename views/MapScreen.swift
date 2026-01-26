//
//  MapScreen.swift
//  Halal Map Prime
//
//  Clean Firestore Map
//  Created by Zaid Nahleh
//

import SwiftUI
import MapKit

struct MapScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()

    @State private var searchText: String = ""
    @State private var selectedPlace: Place? = nil

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                header
                searchBar
                mapView
                resultsList
            }
            .padding(.bottom, 16)
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place)
                .environmentObject(lang)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            viewModel.startListeningToApprovedPlaces()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L("حلال ماب برايم", "Halal Map Prime"))
                    .font(.title3.bold())
                Text(L("أضف مكانك ليظهر على الخريطة", "Add your place to appear on the map"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack {
            TextField(
                L("ابحث عن مكان", "Search place"),
                text: $searchText
            )
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .onChange(of: searchText) {
                viewModel.filterBySearch(text: $0)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Map
    private var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    selectedPlace = place
                } label: {
                    VStack {
                        Text("📍")
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .frame(height: 280)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - List
    private var resultsList: some View {
        VStack {
            ForEach(viewModel.filteredPlaces) { place in
                Button {
                    selectedPlace = place
                } label: {
                    PlaceRowView(place: place)
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }
}
