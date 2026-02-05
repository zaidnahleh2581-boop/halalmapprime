//
//  ZakatCalculatorModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation

struct ZakatBreakdown {
    let zakatableTotal: Double
    let zakatDue: Double
}

enum ZakatCalculatorModel {

    /// Nisab based on gold (grams) * price per gram
    static func nisab(goldPricePerGram: Double, nisabGrams: Double = 85.0) -> Double {
        max(0, goldPricePerGram) * nisabGrams
    }

    /// Zakat due = 2.5% of zakatable amount if above nisab
    static func calculate(
        cash: Double,
        goldValue: Double,
        silverValue: Double,
        investments: Double,
        businessInventory: Double,
        debtsDueSoon: Double,
        goldPricePerGram: Double,
        nisabGrams: Double = 85.0
    ) -> ZakatBreakdown {

        let positive = max(0, cash)
            + max(0, goldValue)
            + max(0, silverValue)
            + max(0, investments)
            + max(0, businessInventory)

        let debts = max(0, debtsDueSoon)

        let zakatable = max(0, positive - debts)
        let nisabValue = nisab(goldPricePerGram: goldPricePerGram, nisabGrams: nisabGrams)

        let due = (zakatable >= nisabValue) ? (zakatable * 0.025) : 0.0

        return ZakatBreakdown(zakatableTotal: zakatable, zakatDue: due)
    }

    static func formatMoney(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
    }
}
