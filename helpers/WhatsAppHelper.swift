//
//  WhatsAppHelper.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//  Updated by Zaid Nahleh on 2026-01-10.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import UIKit

enum WhatsAppHelper {

    // MARK: - Admin WhatsApp Number
    /// ضع رقم واتساب الخاص بك بصيغة دولية بدون + وبدون مسافات
    /// مثال: 12125551234
    static let adminPhoneNumber: String = "6319475782"

    // MARK: - Open Verify Chat
    static func openVerifyChat(
        langIsArabic: Bool,
        placeName: String,
        categoryName: String,
        addressLine: String
    ) {

        // تنظيف رقم الهاتف
        let phone = sanitizePhone(adminPhoneNumber)
        guard !phone.isEmpty else {
            print("❌ WhatsAppHelper: Invalid admin phone number")
            return
        }

        // رسالة التحقق (عربي / إنجليزي)
        let message: String

        if langIsArabic {
            message = """
            مرحباً، أود توثيق نشاط تجاري على تطبيق Halal Map Prime.

            الاسم: \(placeName)
            التصنيف: \(categoryName)
            العنوان: \(addressLine)

            سأقوم بإرسال المستندات المطلوبة للتوثيق.
            """
        } else {
            message = """
            Hi, I would like to verify a business on Halal Map Prime.

            Name: \(placeName)
            Category: \(categoryName)
            Address: \(addressLine)

            I will send the required verification documents.
            """
        }

        // Encoding آمن للنص
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ WhatsAppHelper: Failed to encode message")
            return
        }

        // رابط WhatsApp الرسمي
        let urlString = "https://wa.me/\(phone)?text=\(encodedMessage)"
        guard let url = URL(string: urlString) else {
            print("❌ WhatsAppHelper: Invalid WhatsApp URL")
            return
        }

        // فتح WhatsApp
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Helpers
    private static func sanitizePhone(_ number: String) -> String {
        return number.filter { $0.isNumber }
    }
}
