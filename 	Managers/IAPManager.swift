//
//  IAPManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class IAPManager: ObservableObject {

    static let shared = IAPManager()

    // Product ID
    let eventPostProductId = "hmp.event_post_499"

    @Published var eventPostProduct: Product? = nil
    @Published var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil

    private init() {}

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [eventPostProductId])
            self.eventPostProduct = products.first
            self.lastErrorMessage = nil
        } catch {
            self.lastErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Purchase (Consumable)
    func purchaseEventPost() async throws -> String {

        if eventPostProduct == nil {
            await loadProducts()
        }

        guard let product = eventPostProduct else {
            throw NSError(
                domain: "IAP",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "In-App Purchase product not found."]
            )
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try verify(verification)
            await transaction.finish()
            return String(transaction.id)

        case .userCancelled:
            throw NSError(
                domain: "IAP",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled."]
            )

        case .pending:
            throw NSError(
                domain: "IAP",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Purchase pending approval."]
            )

        @unknown default:
            throw NSError(
                domain: "IAP",
                code: 999,
                userInfo: [NSLocalizedDescriptionKey: "Unknown purchase state."]
            )
        }
    }

    // MARK: - Verify
    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
