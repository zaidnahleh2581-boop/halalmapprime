//
//  HadithListScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2026-01-26.
//

import SwiftUI

struct HadithListScreen: View {

    let items: [HadithItem]
    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        List(items, id: \.id) { h in
            VStack(alignment: .leading, spacing: 8) {

                // نص الحديث
                Text(h.text)
                    .font(.body)

                // المرجع (إن وجد)
                if let ref = h.reference, !ref.isEmpty {
                    Text(ref)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
        .navigationTitle(lang.isArabic ? "الأحاديث" : "Hadiths")
    }
}
