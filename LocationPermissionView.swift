//
//  LocationPermissionView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/24/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Allow Location Access")
                .font(.title2.bold())

            Text("We use your location to show nearby halal places.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
