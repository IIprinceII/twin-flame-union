//
//  CosmicBackground.swift
//  Twin Flame Union
//
//  Shared cosmic gradient background with star particles.
//

import SwiftUI

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppGradients.cosmic
                .ignoresSafeArea()
            StarField()
        }
    }
}

struct StarField: View {
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.12, 0.08, 2, 0.6), (0.85, 0.05, 3, 0.8), (0.45, 0.12, 1.5, 0.5),
        (0.72, 0.18, 2.5, 0.7), (0.28, 0.22, 1, 0.4), (0.92, 0.28, 2, 0.6),
        (0.08, 0.35, 1.5, 0.5), (0.55, 0.32, 2, 0.3), (0.78, 0.42, 3, 0.7),
        (0.18, 0.48, 1, 0.4), (0.65, 0.55, 2, 0.5), (0.35, 0.62, 1.5, 0.6),
        (0.88, 0.65, 2.5, 0.4), (0.05, 0.72, 2, 0.5), (0.48, 0.78, 1, 0.3),
        (0.75, 0.82, 3, 0.6), (0.22, 0.88, 2, 0.4), (0.58, 0.92, 1.5, 0.5),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                let star = stars[i]
                Circle()
                    .fill(Color.white)
                    .frame(width: star.size, height: star.size)
                    .opacity(star.opacity)
                    .position(
                        x: geo.size.width * star.x,
                        y: geo.size.height * star.y
                    )
            }
        }
    }
}
