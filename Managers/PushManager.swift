//
//  PushManager.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-02-06.
//

import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import Combine

@MainActor
final class PushManager: ObservableObject {
    

    static let shared = PushManager()
    private init() {}

    @Published var permissionGranted: Bool = false

    private let db = Firestore.firestore()

    // MARK: - Public entry point (🔥 هذا اللي تستدعيه من أي View / VM)
    func requestPermissionAndRegister() async {
        do {
            try await ensureAnonAuth()

            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )

            permissionGranted = granted
            guard granted else {
                print("🔕 Notifications not granted")
                return
            }

            // 🔔 Register APNs
            UIApplication.shared.registerForRemoteNotifications()

            // 🔑 Sync FCM token
            await syncFCMTokenToFirestore()

        } catch {
            permissionGranted = false
            print("❌ Push permission error:", error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func ensureAnonAuth() async throws {
        if Auth.auth().currentUser != nil { return }
        _ = try await Auth.auth().signInAnonymously()
    }

    private func syncFCMTokenToFirestore() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }

            let token = try await Messaging.messaging().token()
            guard !token.isEmpty else { return }

            let ref = db
                .collection("jobAlertSubs")
                .document(uid)
                .collection("tokens")
                .document(token)

            try await ref.setData([
                "token": token,
                "platform": "ios",
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            print("✅ FCM token synced")

        } catch {
            print("❌ FCM sync failed:", error.localizedDescription)
        }
    }
}

