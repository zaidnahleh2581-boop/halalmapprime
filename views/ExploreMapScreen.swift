//
//  ExploreMapScreen.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/20/25.
//

import SwiftUI
import MapKit

struct ExploreMapScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()
    @State private var selectedPlace: Place? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            Map(
                coordinateRegion: $viewModel.region,
                annotationItems: viewModel.places
            ) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    Button {
                        selectedPlace = place
                        viewModel.focus(on: place)
                    } label: {
                        Text("📍")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .ignoresSafeArea()
            .navigationTitle(L("الخريطة", "Map"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
        }
    }
}
