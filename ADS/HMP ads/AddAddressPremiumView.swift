//
//  AddAddressPremiumView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-05.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AddAddressPremiumView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var addressText: String = ""

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemGroupedBackground).opacity(0.92),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    headerCard

                    VStack(alignment: .leading, spacing: 10) {
                        Text(L("عنوانك", "Your Address"))
                            .font(.headline)

                        TextField(L("اكتب العنوان (اختياري)", "Enter address (optional)"), text: $addressText)
                            .textFieldStyle(.roundedBorder)

                        Text(L(
                            "نستخدم العنوان لتحسين النتائج القريبة والإعلانات في منطقتك.",
                            "We use your address to improve nearby results and local ads."
                        ))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(cardBG)
                    .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        Button {
                            // الآن فقط حفظ محلي (مرحلة أولى)
                            dismiss()
                        } label: {
                            primaryButton(L("حفظ", "Save"), systemImage: "checkmark.circle.fill")
                        }

                        Button {
                            dismiss()
                        } label: {
                            secondaryButton(L("إغلاق", "Close"), systemImage: "xmark.circle.fill")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    Spacer(minLength: 18)
                }
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle(L("أضف عنوانك", "Add Address"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(L("اجعل التجربة أدق", "Make your experience accurate"))
                    .font(.headline)
                Text(L("أضف عنوانك لتحسين النتائج القريبة.", "Add your address to improve nearby results."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(cardBG)
        .padding(.horizontal, 16)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private func primaryButton(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(title).font(.headline)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.9))
        }
        .padding(14)
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.blue.opacity(0.95)))
    }

    private func secondaryButton(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(title).font(.headline)
            Spacer()
        }
        .padding(14)
        .foregroundColor(.primary)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}
