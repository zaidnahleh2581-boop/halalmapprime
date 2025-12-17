//
//  MyAdsView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI

/// صفحة تعرض إعلانات المستخدم + إدارة (حذف) عبر:
/// 1) زر Delete داخل الكرت
/// 2) Swipe to Delete (iOS)
struct MyAdsView: View {

    @EnvironmentObject var lang: LanguageManager
    @ObservedObject private var adsStore = AdsStore.shared

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // مبدئياً: كل الإعلانات (لأنه ما في Auth بعد)
    private var myAds: [Ad] {
        // حدّث حالات الانتهاء قبل العرض
        _ = adsStore.activeAdsSorted() // هذا يفعّل expireAdsIfNeeded()
        return adsStore.ads.sorted(by: { $0.createdAt > $1.createdAt })
    }

    var body: some View {
        NavigationStack {
            Group {
                if myAds.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(myAds) { ad in
                            AdRowCard(
                                ad: ad,
                                isArabic: lang.isArabic,
                                onDelete: {
                                    deleteAd(ad)
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteAd(ad)
                                } label: {
                                    Label(L("حذف", "Delete"), systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteBySwipeIndexSet) // احتياط: لو حبيت تفعل EditButton لاحقاً
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(L("إعلاناتي", "My ads"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(L("لا توجد إعلانات بعد", "No ads yet"))
                .font(.title3.bold())

            Text(
                L(
                    "عند إنشاء إعلان مجاني أو مدفوع سيظهر هنا، وستستطيع حذفه أو إدارته.",
                    "When you create a free or paid ad, it will appear here and you can manage or delete it."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    // MARK: - Delete helpers
    private func deleteAd(_ ad: Ad) {
        // 1) حذف الإعلان من الذاكرة
        adsStore.remove(adId: ad.id)

        // 2) (اختياري) حذف الصور المحلية من Documents
        // إذا بدك نخليها الآن ON: تمام، وإذا بدك نخليها OFF لتفادي مشاكل — احكيلي.
        deleteLocalImagesIfNeeded(paths: ad.imagePaths)
    }

    private func deleteBySwipeIndexSet(_ indexSet: IndexSet) {
        // هذا يعمل إذا فعلت EditButton أو حذف بالـ List مباشرة
        for idx in indexSet {
            guard myAds.indices.contains(idx) else { continue }
            deleteAd(myAds[idx])
        }
    }

    private func deleteLocalImagesIfNeeded(paths: [String]) {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for filename in paths {
            let url = base.appendingPathComponent(filename)
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                print("❌ Failed to delete image \(filename): \(error)")
            }
        }
    }
}

// MARK: - Ad Row Card
private struct AdRowCard: View {

    let ad: Ad
    let isArabic: Bool
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    private func L(_ ar: String, _ en: String) -> String {
        isArabic ? ar : en
    }

    private var statusText: String {
        switch ad.status {
        case .active:
            return ad.isExpired ? L("منتهي", "Expired") : L("نشط", "Active")
        case .pending:
            return L("قيد المراجعة", "Pending")
        case .paused:
            return L("متوقف", "Paused")
        case .expired:
            return L("منتهي", "Expired")
        }
    }

    private var tierText: String {
        switch ad.tier {
        case .free:     return L("مجاني", "Free")
        case .standard: return L("مدفوع", "Paid")
        case .prime:    return L("Prime", "Prime")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Images
            AdImagesCarousel(paths: ad.imagePaths)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(ad.businessName)
                    .font(.headline)
                    .lineLimit(1)

                Text(ad.generatedCopy(isArabic: isArabic))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    pill(text: tierText)
                    pill(text: statusText)

                    Spacer()

                    // ✅ زر حذف داخل الكرت
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Label(L("حذف", "Delete"), systemImage: "trash")
                            .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.top, 2)
            }

        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .confirmationDialog(
            L("تأكيد الحذف", "Confirm delete"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(L("حذف الإعلان", "Delete ad"), role: .destructive) {
                onDelete()
            }
            Button(L("إلغاء", "Cancel"), role: .cancel) { }
        } message: {
            Text(L("هل تريد حذف هذا الإعلان نهائياً؟", "Do you want to permanently delete this ad?"))
        }
    }

    private func pill(text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .foregroundColor(.secondary)
    }
}

// MARK: - Images Carousel (Local)
private struct AdImagesCarousel: View {

    let paths: [String]

    var body: some View {
        Group {
            if paths.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray5))
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Ad image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if paths.count == 1, let img = loadLocalImage(named: paths[0]) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                TabView {
                    ForEach(Array(paths.prefix(3)), id: \.self) { name in
                        if let img = loadLocalImage(named: name) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray5))
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
    }

    private func loadLocalImage(named filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}
