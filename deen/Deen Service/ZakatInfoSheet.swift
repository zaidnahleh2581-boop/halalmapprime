//
//  ZakatInfoSheet.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/10/26.
//

import SwiftUI

struct ZakatInfoSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var cash: String = ""
    @State private var gold: String = ""
    @State private var silver: String = ""
    @State private var investments: String = ""
    @State private var debts: String = ""

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(L("أدخل أموالك", "Enter your assets"))) {
                    moneyField(L("نقد/حسابات", "Cash / Bank"), text: $cash)
                    moneyField(L("ذهب (قيمة بالدولار)", "Gold value"), text: $gold)
                    moneyField(L("فضة (قيمة بالدولار)", "Silver value"), text: $silver)
                    moneyField(L("استثمارات", "Investments"), text: $investments)
                }

                Section(header: Text(L("الديون/الالتزامات", "Debts / liabilities"))) {
                    moneyField(L("الديون المستحقة", "Debts due"), text: $debts)
                }

                Section(header: Text(L("النتيجة", "Result"))) {
                    HStack {
                        Text(L("صافي المبلغ", "Net amount"))
                        Spacer()
                        Text(currency(netAmount))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text(L("الزكاة (2.5%)", "Zakat (2.5%)"))
                        Spacer()
                        Text(currency(zakatAmount))
                            .font(.headline)
                    }

                    Text(L("هذه حاسبة بسيطة (بدون نصاب تلقائي). إذا أردت نضيف النصاب حسب الذهب/الفضة والدولة.",
                           "This is a simple calculator (no Nisab check). If you want, we can add Nisab by gold/silver and country."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle(L("حاسبة الزكاة", "Zakat Calculator"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("مسح", "Reset")) { reset() }
                        .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - UI Helpers

    private func moneyField(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Calculation

    private var netAmount: Double {
        (toDouble(cash) + toDouble(gold) + toDouble(silver) + toDouble(investments)) - toDouble(debts)
    }

    private var zakatAmount: Double {
        max(netAmount, 0) * 0.025
    }

    private func toDouble(_ s: String) -> Double {
        // supports "1,200.50" and "1200.50"
        let cleaned = s
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned) ?? 0
    }

    private func currency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        // لو بدك USD ثابتة:
        f.currencyCode = "USD"
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func reset() {
        cash = ""
        gold = ""
        silver = ""
        investments = ""
        debts = ""
    }
}
