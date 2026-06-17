//
//  SacredGeometryView.swift
//  Twin Flame Union
//
//  Animated sacred geometry patterns for meditative focus.
//

import SwiftUI

// MARK: - Pattern Definition

private enum GeometryPattern: String, CaseIterable, Identifiable {
    case seedOfLife       = "Seed of Life"
    case flowerOfLife     = "Flower of Life"
    case sriYantra        = "Sri Yantra"
    case metatronsCube    = "Metatron's Cube"
    case vesicaPiscis     = "Vesica Piscis"
    case infinityRose     = "Infinity Rose"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .seedOfLife:    return "The seven circles of creation"
        case .flowerOfLife:  return "The pattern underlying all existence"
        case .sriYantra:     return "Union of divine masculine & feminine"
        case .metatronsCube: return "The architecture of the universe"
        case .vesicaPiscis:  return "The intersection of two souls"
        case .infinityRose:  return "Eternal, ever-blooming love"
        }
    }

    var twinFlameMeaning: String {
        switch self {
        case .seedOfLife:
            return "Seven days of creation — your twin flame bond was seeded before time began. Both of your souls are part of one original pattern."
        case .flowerOfLife:
            return "The flower of life contains every possible geometry — including the sacred pattern of your union. You are encoded in creation itself."
        case .sriYantra:
            return "Nine interlocking triangles representing the union of Shiva (masculine) and Shakti (feminine). Meditating here accelerates inner balance between your divine energies."
        case .metatronsCube:
            return "Archangel Metatron's sacred blueprint. All five Platonic solids are hidden within — the geometry of protection, balance, and divine order for your journey."
        case .vesicaPiscis:
            return "The intersection of two perfect circles — the sacred space created when two twin flame souls overlap. The Christ Consciousness symbol."
        case .infinityRose:
            return "Your love is eternal and ever-blooming. Like the rose, it has thorns and perfume — both are sacred. The infinity loop seals the bond across lifetimes."
        }
    }

    var color: Color {
        switch self {
        case .seedOfLife:    return Color(hex: "8B5CF6")
        case .flowerOfLife:  return AppColors.coral
        case .sriYantra:     return Color(hex: "F0C040")
        case .metatronsCube: return Color(hex: "4A90D9")
        case .vesicaPiscis:  return Color(hex: "E74C8B")
        case .infinityRose:  return Color(hex: "D97B4A")
        }
    }
}

// MARK: - View

struct SacredGeometryView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPattern = GeometryPattern.flowerOfLife
    @State private var isAnimating = false
    @State private var animationStartDate: Date? = nil
    @State private var pausedRotation: Double = 0
    @State private var pulse = false

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                // Pattern canvas
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(selectedPattern.color.opacity(0.1), lineWidth: 1)
                        .frame(width: 280, height: 280)
                        .scaleEffect(pulse ? 1.15 : 1.0)
                        .animation(.calm(reduceMotion, .easeInOut(duration: 3).repeatForever(autoreverses: true)), value: pulse)
                        .accessibilityHidden(true)

                    TimelineView(.animation) { timeline in
                        GeometryCanvas(pattern: selectedPattern, rotation: rotationAngle(at: timeline.date))
                            .frame(width: 260, height: 260)
                            .accessibilityHidden(true)
                    }
                }
                .frame(height: 300)
                .padding(.top, 20)

                // Controls
                HStack(spacing: 16) {
                    Button {
                        HapticManager.impact(.light)
                        if isAnimating {
                            // Capture current rotation before pausing
                            if let start = animationStartDate {
                                let elapsed = Date().timeIntervalSince(start)
                                pausedRotation = (pausedRotation + elapsed * 18.0).truncatingRemainder(dividingBy: 360)
                            }
                            animationStartDate = nil
                            isAnimating = false
                        } else {
                            animationStartDate = Date()
                            isAnimating = true
                        }
                    } label: {
                        Label(isAnimating ? "Pause" : "Animate", systemImage: isAnimating ? "pause.fill" : "play.fill")
                            .font(AppFont.body(14, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(AppColors.deepViolet.opacity(0.7), in: Capsule())
                            .overlay(Capsule().strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)

                // Pattern picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(GeometryPattern.allCases) { pattern in
                            Button {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.4)) {
                                    selectedPattern = pattern
                                    animationStartDate = nil
                                    isAnimating = false
                                    pausedRotation = 0
                                }
                            } label: {
                                Text(pattern.rawValue)
                                    .font(AppFont.caption(12, weight: .semibold))
                                    .foregroundStyle(selectedPattern == pattern ? .white : AppColors.lavender)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedPattern == pattern ? pattern.color : AppColors.deepViolet.opacity(0.6),
                                        in: Capsule()
                                    )
                                    .overlay(Capsule().strokeBorder(pattern.color.opacity(selectedPattern == pattern ? 0 : 0.4), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Info card
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedPattern.rawValue)
                            .font(AppFont.serifHeadline(22))
                            .foregroundStyle(AppColors.cream)
                        Text(selectedPattern.subtitle)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                        Divider().background(selectedPattern.color.opacity(0.3))
                        Text(selectedPattern.twinFlameMeaning)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.cream.opacity(0.85))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(selectedPattern.color.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("Sacred Geometry")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { pulse = true }
        .onDisappear {
            isAnimating = false
            animationStartDate = nil
        }
    }

    private func rotationAngle(at date: Date) -> Double {
        guard isAnimating, let start = animationStartDate else { return pausedRotation }
        let elapsed = date.timeIntervalSince(start)
        return (pausedRotation + elapsed * 18.0).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - Geometry Canvas

private struct GeometryCanvas: View {
    let pattern: GeometryPattern
    let rotation: Double

    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) * 0.38
            let color = pattern.color

            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: .degrees(rotation))

            switch pattern {
            case .seedOfLife:    drawSeedOfLife(ctx: ctx, r: r, color: color)
            case .flowerOfLife:  drawFlowerOfLife(ctx: ctx, r: r, color: color)
            case .sriYantra:     drawSriYantra(ctx: ctx, r: r, color: color)
            case .metatronsCube: drawMetatronsCube(ctx: ctx, r: r, color: color)
            case .vesicaPiscis:  drawVesicaPiscis(ctx: ctx, r: r, color: color)
            case .infinityRose:  drawInfinityRose(ctx: ctx, r: r, color: color)
            }
        }
    }

    // MARK: Seed of Life — 7 circles

    private func drawSeedOfLife(ctx: GraphicsContext, r: CGFloat, color: Color) {
        let cr = r * 0.5
        drawCircle(ctx: ctx, center: .zero, radius: cr, color: color, fill: false)
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            let c = CGPoint(x: cr * cos(angle), y: cr * sin(angle))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.8), fill: false)
        }
        // Outer boundary
        drawCircle(ctx: ctx, center: .zero, radius: r, color: color.opacity(0.3), fill: false)
    }

    // MARK: Flower of Life — 19 circles

    private func drawFlowerOfLife(ctx: GraphicsContext, r: CGFloat, color: Color) {
        let cr = r * 0.33
        // Center
        drawCircle(ctx: ctx, center: .zero, radius: cr, color: color, fill: false)
        // Ring 1
        for i in 0..<6 {
            let a = Double(i) * .pi / 3
            let c = CGPoint(x: cr * cos(a), y: cr * sin(a))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.85), fill: false)
        }
        // Ring 2
        for i in 0..<6 {
            let a = Double(i) * .pi / 3 + .pi / 6
            let c = CGPoint(x: cr * 2 * cos(a), y: cr * 2 * sin(a))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.55), fill: false)
        }
        for i in 0..<6 {
            let a = Double(i) * .pi / 3
            let c = CGPoint(x: cr * 2 * cos(a), y: cr * 2 * sin(a))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.45), fill: false)
        }
        // Outer ring
        drawCircle(ctx: ctx, center: .zero, radius: r, color: color.opacity(0.25), fill: false)
    }

    // MARK: Sri Yantra — concentric triangles

    private func drawSriYantra(ctx: GraphicsContext, r: CGFloat, color: Color) {
        // 4 upward triangles (masculine/Shiva)
        let scales: [CGFloat] = [1.0, 0.72, 0.52, 0.36]
        for s in scales {
            drawTriangle(ctx: ctx, r: r * s, pointingUp: true, color: color)
        }
        // 5 downward triangles (feminine/Shakti)
        let scales2: [CGFloat] = [0.88, 0.64, 0.46, 0.32, 0.20]
        for s in scales2 {
            drawTriangle(ctx: ctx, r: r * s, pointingUp: false, color: color.opacity(0.8))
        }
        // Central dot (bindu)
        let dotPath = Path(ellipseIn: CGRect(x: -4, y: -4, width: 8, height: 8))
        ctx.fill(dotPath, with: .color(color))
        // Outer circle
        drawCircle(ctx: ctx, center: .zero, radius: r * 1.05, color: color.opacity(0.3), fill: false)
    }

    // MARK: Metatron's Cube

    private func drawMetatronsCube(ctx: GraphicsContext, r: CGFloat, color: Color) {
        // Fruit of Life — 13 circles
        let cr = r * 0.25
        drawCircle(ctx: ctx, center: .zero, radius: cr, color: color.opacity(0.4), fill: false)
        for i in 0..<6 {
            let a = Double(i) * .pi / 3
            let c = CGPoint(x: r * 0.5 * cos(a), y: r * 0.5 * sin(a))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.4), fill: false)
        }
        for i in 0..<6 {
            let a = Double(i) * .pi / 3 + .pi / 6
            let c = CGPoint(x: r * cos(a), y: r * sin(a))
            drawCircle(ctx: ctx, center: c, radius: cr, color: color.opacity(0.3), fill: false)
        }
        // Lines connecting all 13 centers
        let centers: [CGPoint] = {
            var pts: [CGPoint] = [.zero]
            for i in 0..<6 {
                let a = Double(i) * .pi / 3
                pts.append(CGPoint(x: r * 0.5 * cos(a), y: r * 0.5 * sin(a)))
            }
            for i in 0..<6 {
                let a = Double(i) * .pi / 3 + .pi / 6
                pts.append(CGPoint(x: r * cos(a), y: r * sin(a)))
            }
            return pts
        }()
        for i in 0..<centers.count {
            for j in (i+1)..<centers.count {
                var line = Path()
                line.move(to: centers[i])
                line.addLine(to: centers[j])
                ctx.stroke(line, with: .color(color.opacity(0.18)), lineWidth: 0.8)
            }
        }
    }

    // MARK: Vesica Piscis

    private func drawVesicaPiscis(ctx: GraphicsContext, r: CGFloat, color: Color) {
        let offset = r * 0.5
        drawCircle(ctx: ctx, center: CGPoint(x: -offset, y: 0), radius: r, color: color, fill: false)
        drawCircle(ctx: ctx, center: CGPoint(x:  offset, y: 0), radius: r, color: color, fill: false)
        // Intersection highlight
        var vp = Path()
        vp.move(to: CGPoint(x: 0, y: -r * sqrt(3) / 2 * 0.5))
        vp.addArc(center: CGPoint(x: offset, y: 0), radius: r,
                  startAngle: .degrees(120), endAngle: .degrees(240), clockwise: false)
        vp.addArc(center: CGPoint(x: -offset, y: 0), radius: r,
                  startAngle: .degrees(300), endAngle: .degrees(60), clockwise: false)
        vp.closeSubpath()
        ctx.fill(vp, with: .color(color.opacity(0.15)))
        ctx.stroke(vp, with: .color(color.opacity(0.7)), lineWidth: 1.2)
    }

    // MARK: Infinity Rose

    private func drawInfinityRose(ctx: GraphicsContext, r: CGFloat, color: Color) {
        // 12-petal rose using polar parametric curve r = cos(6θ) scaled
        let petals = 12
        var path = Path()
        let steps = 720
        for i in 0...steps {
            let theta = Double(i) * 2 * .pi / Double(steps)
            let k = Double(petals) / 2
            let rr = r * abs(cos(k * theta))
            let x = rr * cos(theta)
            let y = rr * sin(theta)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        ctx.fill(path, with: .color(color.opacity(0.12)))
        ctx.stroke(path, with: .color(color.opacity(0.85)), lineWidth: 1.2)
        // Center circle
        drawCircle(ctx: ctx, center: .zero, radius: r * 0.12, color: color, fill: true)
        drawCircle(ctx: ctx, center: .zero, radius: r * 1.02, color: color.opacity(0.2), fill: false)
    }

    // MARK: Helpers

    private func drawCircle(ctx: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color, fill: Bool) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let p = Path(ellipseIn: rect)
        if fill { ctx.fill(p, with: .color(color)) }
        else     { ctx.stroke(p, with: .color(color), lineWidth: 1.0) }
    }

    private func drawTriangle(ctx: GraphicsContext, r: CGFloat, pointingUp: Bool, color: Color) {
        let offset: Double = pointingUp ? -.pi / 2 : .pi / 2
        var p = Path()
        for i in 0..<3 {
            let a = Double(i) * 2 * .pi / 3 + offset
            let pt = CGPoint(x: r * cos(a), y: r * sin(a))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        ctx.stroke(p, with: .color(color), lineWidth: 1.2)
    }
}
