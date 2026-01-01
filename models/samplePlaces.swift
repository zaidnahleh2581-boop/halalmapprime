//
//  samplePlaces.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

let samplePlaces: [Place] = [

    Place(
        id: "1",
        name: "Al-Aqsa Halal Grill",
        address: "123 Atlantic Ave",
        cityState: "Brooklyn, NY",
        latitude: 40.6900,
        longitude: -73.9900,
        category: .restaurant,
        rating: 4.2,
        reviewCount: 138,
        deliveryAvailable: true,
        isCertified: true,
        phone: "+1 (347) 825-2032",
        website: "https://alaqsagrill.com",
        adStatus: "paid",
        adPlan: "prime",
        adPriority: 3,
        startAt: Date(),
        endAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
        isAdActive: true
    ),

    Place(
        id: "2",
        name: "Madina Grocery",
        address: "55 Church Ave",
        cityState: "Brooklyn, NY",
        latitude: 40.6500,
        longitude: -73.9800,
        category: .grocery,
        rating: 4.8,
        reviewCount: 62,
        deliveryAvailable: false,
        isCertified: true,
        phone: nil,
        website: nil,
        adStatus: "free",
        adPlan: "none",
        adPriority: 0,
        startAt: nil,
        endAt: nil,
        isAdActive: false
    )
]
