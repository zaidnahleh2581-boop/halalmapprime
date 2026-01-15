//
//  AdPreviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-05.
//  Updated by Zaid Nahleh on 2026-01-14.
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
    @EnvironmentObject var adsStore: AdsStore

    @State private var showDeleteConfirm: Bool = false
    @State private var isDeleting: Bool = false

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    // ✅ Prefer Storage URLs (new) then fallback to legacy base64
    private var storageURLs: [URL] {
        ad.imageURLs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { URL(string: $0) }
    }

    private var legacyImages: [UIImage] {
        ad.uiImages() // base64 legacy only
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                // MARK: - Images Carousel
                imagesCarousel

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

                // MARK: - Actions
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

                    // ✅ Delete button (ONLY for owner)
                    if adsStore.isMyAd(ad) {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "trash.fill")
                                Text(L("حذف الإعلان", "Delete Ad"))
                                    .font(.headline)
                                Spacer()
                                if isDeleting {
                                    ProgressView().scaleEffect(0.9)
                                }
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.red.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
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
        .alert(L("حذف الإعلان", "Delete Ad"), isPresented: $showDeleteConfirm) {
            Button(L("إلغاء", "Cancel"), role: .cancel) { }
            Button(L("حذف", "Delete"), role: .destructive) {
                Task {
                    await deleteAdNow()
                }
            }
        } message: {
            Text(L("هل أنت متأكد أنك تريد حذف هذا الإعلان نهائياً؟",
                   "Are you sure you want to permanently delete this ad?"))
        }
    }

    // MARK: - Delete

    private func deleteAdNow() async {
        guard !isDeleting else { return }
        isDeleting = true
        await adsStore.deleteAd(ad)
        isDeleting = false
        dismiss()
    }

    // MARK: - Images

    @ViewBuilder
    private var imagesCarousel: some View {
        // 1) ✅ Storage URLs (new)
        if !storageURLs.isEmpty {
            TabView {
                ForEach(Array(storageURLs.enumerated()), id: \.offset) { _, url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            imagePlaceholder(title: L("تحميل الصورة...", "Loading image..."))
                                .frame(height: 240)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                        case .failure:
                            if let legacy = legacyImages.first {
                                Image(uiImage: legacy)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 240)
                                    .clipped()
                            } else {
                                imagePlaceholder(title: L("فشل تحميل الصورة", "Failed to load"))
                                    .frame(height: 240)
                            }
                        @unknown default:
                            imagePlaceholder(title: L("تحميل الصورة...", "Loading image..."))
                                .frame(height: 240)
                        }
                    }
                }
            }
            .frame(height: 240)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        // 2) ✅ Legacy base64 (old ads)
        else if !legacyImages.isEmpty {
            TabView {
                ForEach(Array(legacyImages.enumerated()), id: \.offset) { _, img in
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
        // 3) ✅ No images
        else {
            imagePlaceholder(title: L("لا توجد صور", "No images"))
                .frame(height: 240)
        }
    }

    private func imagePlaceholder(title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .clipped()
        .padding(.horizontal, 16)
    }

    // MARK: - UI Helpers

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
