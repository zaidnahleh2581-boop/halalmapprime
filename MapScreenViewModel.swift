import Foundation
import MapKit
import SwiftUI
import Combine
final class MapScreenViewModel: ObservableObject {

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []

    init() {
        loadInitialData()
    }

    func loadInitialData() {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                    print("[MapScreenViewModel] Loaded \(loaded.count) places")
                case .failure(let error):
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    func searchNearby(category: PlaceCategory?) {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    print("❌ Category search error: \(error)")
                }
            }
        }
    }

    func filterBySearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            filteredPlaces = places
            return
        }

        filteredPlaces = places.filter {
            $0.name.localizedCaseInsensitiveContains(q)
        }
    }

    func focus(on place: Place) {
        withAnimation(.easeInOut(duration: 0.25)) {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}
