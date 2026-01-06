//
//  AdPreviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import UIKit

struct AdPreviewScreen: View {

    let langIsArabic: Bool
    let ad: HMPAd

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                // Images carousel
                let imgs = ad.uiImages()
                if !imgs.isEmpty {
                    TabView {
                        ForEach(Array(imgs.enumerated()), id: \.offset) { _, img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                        }
                    }
                    .frame(height: 240)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ad.businessName)
                                .font(.title3.weight(.bold))
                            Text(ad.headline)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        Spacer()

                        if ad.plan == .prime {
                            Text(L("مميز", "PRIME"))
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.95))
                                .clipShape(Capsule())
                        }
                    }

                    Text(ad.remainingText(langIsArabic: langIsArabic))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    Divider()

                    Text(ad.adText)
                        .font(.body)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemBackground)))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Actions
                VStack(spacing: 10) {

                    if !ad.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            let digits = ad.phone.filter { "0123456789+".contains($0) }
                            if let url = URL(string: "tel://\(digits)") { openURL(url) }
                        } label: {
                            actionButton(title: L("اتصال", "Call"), systemImage: "phone.fill")
                        }
                    }

                    if !ad.website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            var w = ad.website.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !w.lowercased().hasPrefix("http") { w = "https://\(w)" }
                            if let url = URL(string: w) { openURL(url) }
                        } label: {
                            actionButton(title: L("زيارة الموقع", "Open website"), systemImage: "safari.fill")
                        }
                    }

                    Button {
                        if let url = googleMapsURLForAd(ad) { openURL(url) }
                    } label: {
                        actionButton(title: L("الذهاب إلى Google Maps", "Open in Google Maps"), systemImage: "map.fill")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle(L("صفحة الإعلان", "Ad Preview"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
    }

    private func actionButton(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(title).font(.headline)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private func googleMapsURLForAd(_ ad: HMPAd) -> URL? {
        let hint = ad.addressHint.trimmingCharacters(in: .whitespacesAndNewlines)
        let qRaw = hint.isEmpty ? ad.businessName : "\(ad.businessName) \(hint)"
        let q = qRaw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard !q.isEmpty else { return nil }
        return URL(string: "https://www.google.com/maps/search/?api=1&query=\(q)")
    }
}
