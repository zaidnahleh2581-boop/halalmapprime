//
//  EventAdsModels.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import Foundation

/// نموذج إعلان الفعالية الذي نستخدمه داخل التطبيق
struct EventAd: Identifiable {
    let id: String          // documentID من Firestore
    let title: String       // عنوان الفعالية
    let city: String        // المدينة / المنطقة
    let placeName: String   // اسم المكان (مسجد / سنتر / قاعة)
    let eventDate: Date     // تاريخ الفعالية
    let description: String // وصف مختصر
    let contact: String     // وسيلة التواصل
    let createdAt: Date     // تاريخ إنشاء الإعلان
}
