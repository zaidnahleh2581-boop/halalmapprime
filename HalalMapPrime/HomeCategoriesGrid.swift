//
//  HomeCategoriesGrid.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeCategoriesGrid: View {

    @EnvironmentObject var lang: LanguageManager
    let onSelect: (PlaceCategory) -> Void

    @State private var showMore = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var primary: [PlaceCategory] { [.restaurant, .foodTruck, .grocery] }
    private var secondary: [PlaceCategory] {
        [.mosque, .school, .service, .shop, .market, .center]
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(L("التصنيفات", "Categories"))
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation(.easeInOut) { showMore.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(showMore ? L("إخفاء", "Hide") : L("المزيد", "More"))
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: showMore ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(primary, id: \.self) { category in
                    categoryCard(for: category)
                }

                if showMore {
                    ForEach(secondary, id: \.self) { category in
                        categoryCard(for: category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func categoryCard(for category: PlaceCategory) -> some View {
        Button {
            onSelect(category)
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon(for: category))
                    .font(.system(size: 26))
                    .foregroundColor(category.mapColor)

                Text(category.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func icon(for category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return "fork.knife"
        case .foodTruck:  return "truck.box.fill"
        case .grocery:    return "cart.fill"
        case .market:     return "basket.fill"
        case .shop:       return "bag.fill"
        case .mosque:     return "moon.stars.fill"
        case .school:     return "book.fill"
        case .service:    return "wrench.and.screwdriver.fill"
        case .center:
            return "building.2.fill"
        default:
            return "square.grid.2x2.fill"
        }
    }
}
