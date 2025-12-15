//
//  JobAdsBoardView.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import SwiftUI

struct JobAdsBoardView: View {
    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        JobAdsScreen()
            .environmentObject(lang)
    }
}
