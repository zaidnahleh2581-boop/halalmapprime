//
//  NotificationsBellView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/9/26.
//

import SwiftUI

struct NotificationsBellView: View {

    @State private var showCenter = false

    // UI فقط (مؤقت)
    let unreadCount: Int

    var body: some View {
        Button {
            showCenter = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(Circle())

                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showCenter) {
            Text("Notifications")
                .font(.title3.weight(.semibold))
                .padding()
        }
    }
}
