//
//  ZakatCalculatorScreen.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import SwiftUI

struct ZakatCalculatorScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // Inputs
    @State private var cash: String = ""
    @State private var goldValue: String = ""
    @State private var silverValue: String = ""
    @State private var investments: String = ""
    @State private var businessInventory: String = ""
    @State private var debtsDueSoon: String = ""

    // Nisab source
    @State private var goldPricePerGram: String = "75" // default example
    @State private var useGoldNisab: Bool = true // for future expansion

    private func toDouble(_ s: String) -> Double {
        let cleaned = s.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned) ?? 0
    }

    private var breakdown: ZakatBreakdown {
        ZakatCalculatorModel.calculate(
            cash: toDouble(cash),
            goldValue: toDouble(goldValue),
            silverValue: toDouble(silverValue),
            investments: toDouble(investments),
            businessInventory: toDouble(businessInventory),
            debtsDueSoon: toDouble(debtsDueSoon),
            goldPricePerGram: toDouble(goldPricePerGram),
            nisabGrams: 85.0
        )
    }

    private var nisabValue: Double {
        ZakatCalculatorModel.nisab(goldPricePerGram: toDouble(goldPricePerGram), nisabGrams: 85.0)
    }

    var body: some View {
        Form {

            Section(header: Text(L("المدخلات", "Inputs"))) {

                moneyField(title: L("النقد (كاش/حساب)", "Cash (bank + on hand)"), text: $cash)
                moneyField(title: L("قيمة الذهب", "Gold value"), text: $goldValue)
                moneyField(title: L("قيمة الفضة", "Silver value"), text: $silverValue)
                moneyField(title: L("استثمارات / أسهم", "Investments / stocks"), text: $investments)
                moneyField(title: L("بضاعة التجارة", "Business inventory"), text: $businessInventory)
                moneyField(title: L("ديون واجبة قريباً", "Debts due soon"), text: $debtsDueSoon)
            }

            Section(header: Text(L("النصاب", "Nisab"))) {
                Toggle(L("اعتماد نصاب الذهب", "Use gold nisab"), isOn: $useGoldNisab)
                    .disabled(true) // حالياً فقط gold nisab

                HStack {
                    Text(L("سعر غرام الذهب (USD)", "Gold price per gram (USD)"))
                    Spacer()
                    TextField("75", text: $goldPricePerGram)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                HStack {
                    Text(L("قيمة النصاب التقريبية", "Approx. nisab value"))
                    Spacer()
                    Text(ZakatCalculatorModel.formatMoney(nisabValue))
                        .foregroundColor(.secondary)
                }

                Text(L("ملاحظة: النصاب هنا = 85 غرام ذهب × سعر الغرام.",
                       "Note: Nisab here = 85g gold × price per gram."))
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Section(header: Text(L("النتيجة", "Result"))) {

                HStack {
                    Text(L("المبلغ الخاضع للزكاة", "Zakatable total"))
                    Spacer()
                    Text(ZakatCalculatorModel.formatMoney(breakdown.zakatableTotal))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(L("الزكاة الواجبة (2.5%)", "Zakat due (2.5%)"))
                        .font(.headline)
                    Spacer()
                    Text(ZakatCalculatorModel.formatMoney(breakdown.zakatDue))
                        .font(.headline)
                }

                if breakdown.zakatDue == 0 {
                    Text(L("إذا مجموعك أقل من النصاب، الزكاة غير واجبة.",
                           "If your total is below nisab, zakat is not due."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(L("حاسبة الزكاة", "Zakat calculator"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func moneyField(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }
}
