//
//  AdsHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//

import SwiftUI

struct AdsHomeScreen: View {

    @ObservedObject private var adsStore = AdsStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    ForEach(adsStore.activeAdsSorted()) { ad in
                        AdCard(ad: ad)
                    }

                    if adsStore.activeAdsSorted().isEmpty {
                        Text("No ads available")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Ads")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Ad Card (CLEAN)

private struct AdCard: View {

    let ad: Ad

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            AdImagesCarousel(paths: ad.imagePaths)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 4) {

                Text("Sponsored")
                    .font(.subheadline.bold())

                Text(badgeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        )
    }

    private var badgeText: String {
        switch ad.tier {
        case .prime:
            return "⭐ Prime Ad"
        case .standard:
            return "💼 Paid Ad"
        case .free:
            return "🆓 Free Ad"
        }
    }
}

// MARK: - Images Carousel

private struct AdImagesCarousel: View {

    let paths: [String]

    var body: some View {
        TabView {
            ForEach(paths, id: \.self) { filename in
                if let image = loadLocalImage(named: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                }
            }
        }
        .tabViewStyle(.page)
    }

    private func loadLocalImage(named filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }
}
