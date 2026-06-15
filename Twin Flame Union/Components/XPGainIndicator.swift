//
//  XPGainIndicator.swift
//  Twin Flame Union
//
//  Floating "+XP" label that appears after earning XP.
//

import SwiftUI

struct XPGainIndicator: View {
    let amount: Int
    @State private var visible = true
    @State private var offset: CGFloat = 0

    var body: some View {
        if visible && amount > 0 {
            Text("+\(amount) XP")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.gold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.gold.opacity(0.15), in: Capsule())
                .overlay(Capsule().strokeBorder(AppColors.gold.opacity(0.35), lineWidth: 1))
                .offset(y: offset)
                .opacity(visible ? 1 : 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.5)) {
                        offset = -40
                    }
                    withAnimation(.easeOut(duration: 1.5).delay(1.0)) {
                        visible = false
                    }
                }
        }
    }
}
