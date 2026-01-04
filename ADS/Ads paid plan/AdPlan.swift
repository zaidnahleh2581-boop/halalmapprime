//
//  AdPlan.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

/// أنواع خطط الإعلانات المدفوعة (مبدئياً UI فقط)
enum AdPlanType: String, CaseIterable, Identifiable, Codable {
    case weekly
    case monthly
    case prime

    var id: String { rawValue }

    /// عنوان الخطة
    func title(isArabic: Bool) -> String {
        switch self {
        case .weekly:  return isArabic ? "إعلان أسبوعي" : "Weekly Ad"
        case .monthly: return isArabic ? "إعلان شهري"  : "Monthly Ad"
        case .prime:   return isArabic ? "إعلان مميز (Prime)" : "Prime Ad"
        }
    }

    /// وصف قصير يظهر في شاشة الباقات
    func subtitle(isArabic: Bool) -> String {
        switch self {
        case .weekly:
            return isArabic ? "ظهور أعلى لمدة 7 أيام" : "Higher visibility for 7 days"
        case .monthly:
            return isArabic ? "ظهور أعلى لمدة 30 يوم" : "Higher visibility for 30 days"
        case .prime:
            return isArabic ? "أفضل ظهور + أولوية قصوى" : "Top visibility + highest priority"
        }
    }

    /// أين يظهر الإعلان (نص توضحي)
    func placementSummary(isArabic: Bool) -> String {
        switch self {
        case .weekly:
            return isArabic
            ? "يظهر إعلانك أعلى من النتائج العادية في الخريطة وداخل قائمة الأماكن (حسب الأولوية)."
            : "Your ad appears above normal results on the map and inside the places list (by priority)."
        case .monthly:
            return isArabic
            ? "يظهر إعلانك بترتيب أعلى بشكل ثابت خلال الشهر مع أولوية أقوى من الأسبوعي."
            : "Your ad stays in a higher rank throughout the month with stronger priority than weekly."
        case .prime:
            return isArabic
            ? "يظهر إعلانك في أعلى النتائج + يمكن ظهوره كبانر مميز داخل التطبيق."
            : "Your ad shows at the very top and may appear as a featured banner inside the app."
        }
    }

    /// أولوية داخل التطبيق (لترتيب النتائج لاحقاً)
    var priority: Int {
        switch self {
        case .weekly:  return 1
        case .monthly: return 2
        case .prime:   return 3
        }
    }

    /// مدة الخطة بالأيام (معلومة UI)
    var durationDays: Int {
        switch self {
        case .weekly:  return 7
        case .monthly: return 30
        case .prime:   return 30
        }
    }

    /// حد أحرف وصف الإعلان
    var maxTextLength: Int { 150 }

    /// منتج StoreKit (إذا لاحقاً بدك تربطه)
    /// ملاحظة: لا يغيّر أي شيء حالياً—مجرد mapping نظيف
    var storeProductId: String {
        switch self {
        case .weekly:  return "weekly_ad"
        case .monthly: return "monthly_ad"
        case .prime:   return "prime_ad"
        }
    }
}
