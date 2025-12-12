//
//  PlaceDetailView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct PlaceDetailView: View {

    @EnvironmentObject var lang: LanguageManager
    let place: Place

    // ✅ عدّل رقمك هنا (E.164) مثال: +1718XXXXXXX
    private let whatsAppNumberE164: String = "+10000000000"

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    // ✅ فقط هذه الأنواع تحتاج توثيق (أكل / لحوم)
    private var needsVerification: Bool {
        switch place.category {
        case .restaurant, .foodTruck, .grocery, .market:
            return true
        default:
            return false
        }
    }

    // ✅ لون/نوع الشارة حسب الفئة
    private var badge: (title: String, color: Color, icon: String) {
        // فئات “الأكل” (توثيق)
        if needsVerification {
            if place.isCertified {
                return (L("حلال موثّق", "Halal Verified"), .green, "checkmark.seal.fill")
            } else {
                return (L("غير موثّق", "Unverified"), .gray, "exclamationmark.triangle.fill")
            }
        }

        // مساجد/مدارس/مراكز (بدون توثيق)
        if place.category == .mosque || place.category == .school || place.category == .center {
            return (L("مجتمع", "Community"), .orange, "person.3.fill")
        }

        // باقي الأنواع (بدون توثيق)
        return (L("عمل / خدمة", "Business / Service"), .blue, "briefcase.fill")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // عنوان + إيموجي + شارة
                HStack(alignment: .top, spacing: 10) {
                    Text(place.category.emoji)
                        .font(.system(size: 34))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(place.name)
                            .font(.title2.bold())

                        HStack(spacing: 8) {
                            Label(badge.title, systemImage: badge.icon)
                                .font(.caption.weight(.semibold))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(badge.color.opacity(0.18))
                                .foregroundColor(badge.color)
                                .clipShape(Capsule())

                            Text(place.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }

                // معلومات المكان
                VStack(alignment: .leading, spacing: 8) {
                    Label(place.address, systemImage: "mappin.and.ellipse")
                        .foregroundColor(.primary)
                    Text(place.cityState)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // تقييم (إذا موجود)
                    HStack(spacing: 10) {
                        Label(String(format: "%.1f", place.rating), systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        Text("(\(place.reviewCount))")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.top, 4)

                // خريطة صغيرة
                Map(
                    initialPosition: .region(
                        MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                ) {
                    Annotation(place.name, coordinate: place.coordinate) {
                        VStack(spacing: 2) {
                            Text(place.category.emoji).font(.system(size: 18))
                            Circle()
                                .fill(place.category.mapColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // ✅ زر واتساب يظهر فقط لو (أكل) و (غير موثّق)
                if needsVerification && !place.isCertified {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L("للحصول على علامة التوثيق:", "To get the verification badge:"))
                            .font(.subheadline.weight(.semibold))

                        Text(L(
                            "أرسل وثيقة/فاتورة/صورة تثبت الحلال عبر واتساب وسيتم مراجعتها.",
                            "Send an invoice/certificate/photo via WhatsApp and it will be reviewed."
                        ))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                        Button {
                            openWhatsAppVerification()
                        } label: {
                            HStack {
                                Image(systemName: "message.fill")
                                Text(L("توثيق عبر WhatsApp", "Verify via WhatsApp"))
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.green.opacity(0.18))
                            .foregroundColor(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.top, 6)
                } else if needsVerification && place.isCertified {
                    Text(L(
                        "✅ هذا المكان موثّق (حلال).",
                        "✅ This place is verified (Halal)."
                    ))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.green)
                    .padding(.top, 6)
                }

                Spacer(minLength: 18)
            }
            .padding()
        }
        .navigationTitle(L("تفاصيل المكان", "Place Details"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - WhatsApp
    private func openWhatsAppVerification() {
        let msgAR = "مرحباً، أريد توثيق مكان في Halal Map Prime.\nالاسم: \(place.name)\nالعنوان: \(place.address), \(place.cityState)\nالنوع: \(place.category.rawValue)\n(أرفق الوثيقة/الفاتورة هنا)"
        let msgEN = "Hi, I want to verify a place on Halal Map Prime.\nName: \(place.name)\nAddress: \(place.address), \(place.cityState)\nCategory: \(place.category.rawValue)\n(Please attach the proof here)"

        let message = L(msgAR, msgEN)
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // WhatsApp URL (يفتح الدردشة مباشرة)
        if let url = URL(string: "https://wa.me/\(whatsAppNumberE164.replacingOccurrences(of: "+", with: ""))?text=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}
