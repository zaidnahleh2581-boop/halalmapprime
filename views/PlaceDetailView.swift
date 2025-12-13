//
//  PlaceDetailView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//

import SwiftUI
import MapKit
import UIKit

struct PlaceDetailView: View {

    let place: Place

    // ✅ ضع رقمك هنا (مع كود الدولة بدون +)
    // مثال أمريكا: 1718xxxxxxx
    private let whatsappPhoneE164NoPlus: String = "6319475782"

    // ✅ قواعد التوثيق: فقط الأكل/اللحوم
    private var placeNeedsVerification: Bool {
        switch place.category {
        case .restaurant, .foodTruck, .grocery, .market:
            return true
        default:
            return false
        }
    }

    // ✅ لون البادج: Food = Green / Non-food = Orange
    private var placeBadgeColor: Color {
        placeNeedsVerification ? .green : .orange
    }

    private var statusText: String {
        place.isCertified ? "Verified" : "Unverified"
    }

    private var statusIcon: String {
        place.isCertified ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
    }

    private var statusColor: Color {
        place.isCertified ? .green : .orange
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(place.name)
                    .font(.title2.bold())

                // Category badge
                HStack(spacing: 8) {
                    Text(place.category.emoji)
                    Text(place.category.displayName)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(placeBadgeColor.opacity(0.18))
                .foregroundColor(placeBadgeColor)
                .cornerRadius(10)

                // Address
                VStack(alignment: .leading, spacing: 6) {
                    Text("Address").font(.headline)
                    Text("\(place.address), \(place.cityState)")
                        .foregroundColor(.secondary)
                }

                // Rating
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rating").font(.headline)
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", place.rating))
                        Text("(\(place.reviewCount) reviews)")
                            .foregroundColor(.secondary)
                    }
                }

                // ✅ فقط للأكل/اللحوم يظهر Status + زر الواتساب
                if placeNeedsVerification {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status").font(.headline)

                        HStack(spacing: 8) {
                            Image(systemName: statusIcon).foregroundColor(statusColor)
                            Text(statusText).foregroundColor(.secondary)
                        }

                        Button {
                            openWhatsAppVerification()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "message.fill")
                                Text("Verify via WhatsApp").font(.headline)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.top, 6)

                        Text("Send a photo/invoice to verify halal meat/food.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                } else {
                    // ✅ مسجد/مدرسة/خدمات… بدون توثيق وبدون زر
                    Text("No halal meat verification is required for this category.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 10)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - WhatsApp

    private func openWhatsAppVerification() {
        let msg = """
        Hi, I want to verify a place on Halal Map Prime.
        Name: \(place.name)
        Category: \(place.category.rawValue)
        Address: \(place.address), \(place.cityState)
        """

        let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // 1) WhatsApp app
        if let appURL = URL(string: "whatsapp://send?phone=\(whatsappPhoneE164NoPlus)&text=\(encoded)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }

        // 2) wa.me fallback
        if let webURL = URL(string: "https://wa.me/\(whatsappPhoneE164NoPlus)?text=\(encoded)") {
            UIApplication.shared.open(webURL)
        }
    }
}
