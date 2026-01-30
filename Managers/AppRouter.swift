//
//  AppRouter.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {

    @Published var selectedTab: Int = 0

    // ✅ Faith tab tag عندك = 4
    private let faithTabIndex: Int = 4

    // Jobs DeepLink (existing)
    struct JobsDeepLink: Equatable {
        var category: String? = nil
        var filter: JobAdFilter = .all
    }
    @Published var pendingJobsDeepLink: JobsDeepLink? = nil

    func openJobs(category: String?, filter: JobAdFilter = .all) {
        pendingJobsDeepLink = JobsDeepLink(category: category, filter: filter)
        selectedTab = 1
    }

    // ✅ Ads DeepLink (existing)
    enum AdsEntry: Equatable {
        case home
        case freeAd
        case paidPlans
        case jobsBoard
    }

    // ✅ Map DeepLink (existing)
    @Published var pendingMapCategory: PlaceCategory? = nil

    func openMap(category: PlaceCategory?) {
        pendingMapCategory = category
        selectedTab = 0
    }

    @Published var pendingAdsEntry: AdsEntry? = nil

    func openAds(_ entry: AdsEntry = .home) {
        pendingAdsEntry = entry
        selectedTab = 2
    }

    // MARK: - ✅ Faith DeepLink (NEW)

    enum FaithEntry: Equatable {
        case hadith(id: String?)
        case imsakiyah
        case prayer(prayer: String?)
    }

    @Published var pendingFaithEntry: FaithEntry? = nil

    func openFaith(_ entry: FaithEntry) {
        pendingFaithEntry = entry
        selectedTab = faithTabIndex
    }

    // MARK: - ✅ Notification handler (NEW)

    func handleNotification(userInfo: [AnyHashable: Any]) {
        let route = (userInfo["route"] as? String)?.lowercased() ?? ""

        switch route {
        case "hadith":
            let hid = userInfo["hid"] as? String
            openFaith(.hadith(id: hid))

        case "imsakiyah", "ramadan":
            openFaith(.imsakiyah)

        case "prayer":
            let prayer = userInfo["prayer"] as? String
            openFaith(.prayer(prayer: prayer))

        default:
            break
        }
    }
}
