//
//  PurchaseManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {

    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    let productIDs: [String] = [
        "weekly_ad",
        "monthly_ad",
        "prime_ad"
    ]

    init() {
        Task { await loadProducts() }
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        products = []

        do {
            let loaded = try await Product.products(for: productIDs)

            if loaded.isEmpty {
                errorMessage = "No products returned. Check Product IDs or StoreKit config."
            } else {
                products = loaded
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success:
                break
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase pending"
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
