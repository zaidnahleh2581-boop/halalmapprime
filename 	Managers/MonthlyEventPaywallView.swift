//
//  MonthlyEventPaywallView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct MonthlyEventPaywallView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var onPaid: (String) -> Void

    @StateObject private var iap = IAPManager.shared

    @State private var isBuying: Bool = false
    @State private var errorMessage: String? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                Image(systemName: "lock.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.orange)

                Text(L("لقد استخدمت الإعلان المجاني لهذا الشهر", "You already used your free monthly post"))
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(L(
                    "يمكنك دفع ثمن هذا الإعلان لنشره الآن.",
                    "You can pay to publish this post now."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

                if let p = iap.eventPostProduct {
                    Text(L("السعر", "Price") + ": " + p.displayPrice)
                        .font(.subheadline.weight(.semibold))
                        .padding(.top, 4)
                } else {
                    ProgressView()
                        .padding(.top, 4)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }

                VStack(spacing: 10) {
                    Button {
                        Task { await buy() }
                    } label: {
                        HStack {
                            if isBuying { ProgressView() }
                            Text(L("ادفع وانشر الآن", "Pay & Publish Now"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBuying)

                    Button(role: .cancel) { dismiss() } label: {
                        Text(L("إلغاء", "Cancel"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isBuying)
                }
                .padding(.top, 6)

                Spacer()
            }
            .padding()
            .navigationTitle(L("ترقية الإعلان", "Upgrade Post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").imageScale(.medium)
                    }
                    .disabled(isBuying)
                }
            }
            .task {
                // تحميل المنتج عند فتح الشاشة
                await iap.loadProducts()
            }
        }
    }

    @MainActor
    private func buy() async {
        isBuying = true
        errorMessage = nil

        do {
            let paymentRef = try await iap.purchaseEventPost()
            onPaid(paymentRef)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isBuying = false
    }
}
