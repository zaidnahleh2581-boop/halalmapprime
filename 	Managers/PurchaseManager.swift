//
//  PurchaseManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Fixed by ChatGPT on 2026-01-01.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {

    // MARK: - Published
    @Published var products: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var lastError: String? = nil
    @Published var lastSuccessMessage: String? = nil

    // MARK: - Product IDs
    private let productIDs: [String] = [
        "weekly_ad",
        "monthly_ad",
        "prime_ad"
    ]

    // MARK: - Init
    init() {
        Task {
            await loadProducts()
            await listenForTransactions()
        }
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: productIDs)
            self.products = loaded.sorted {
                priority(for: $0.id) > priority(for: $1.id)
            }
        } catch {
            self.products = []
            self.lastError = error.localizedDescription
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async {
        isPurchasing = true
        lastError = nil
        lastSuccessMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                lastSuccessMessage = "✅ Purchase successful: \(product.id)"

            case .userCancelled:
                lastError = "Purchase cancelled."

            case .pending:
                lastError = "⏳ Purchase pending."

            @unknown default:
                lastError = "Unknown purchase result."
            }

        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: - Restore
    func restorePurchases() async {
        lastError = nil
        lastSuccessMessage = nil

        do {
            try await AppStore.sync()
            lastSuccessMessage = "✅ Restore completed."
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: - Transaction Updates (FIXED)
    private func listenForTransactions() async {
        for await update in Transaction.updates {
            do {
                let transaction = try checkVerified(update)
                await transaction.finish()
                lastSuccessMessage = "✅ Updated: \(transaction.productID)"
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    // MARK: - Verification
    private enum VerificationError: Error {
        case failed
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw VerificationError.failed
        }
    }

    // MARK: - Priority
    private func priority(for productID: String) -> Int {
        switch productID {
        case "prime_ad":   return 3
        case "monthly_ad": return 2
        case "weekly_ad":  return 1
        default:           return 0
        }
    }

    // MARK: - Labels
    func titleForProduct(_ id: String) -> String {
        switch id {
        case "weekly_ad":  return "Weekly"
        case "monthly_ad": return "Monthly"
        case "prime_ad":   return "Prime"
        default:           return id
        }
    }

    func subtitleForProduct(_ id: String) -> String {
        switch id {
        case "weekly_ad":  return "7 days"
        case "monthly_ad": return "30 days"
        case "prime_ad":   return "Top priority"
        default:           return ""
        }
    }
}
