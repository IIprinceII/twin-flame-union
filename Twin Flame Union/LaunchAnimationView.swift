//
//  LaunchAnimationView.swift
//  Twin Flame Union
//
//  Sacred geometry · liquid mercury · Marvel-level cinematic intro.
//  6-second sequence — 7 phases.
//

import SwiftUI

// MARK: - Particle Spec

private struct SplashParticle {
    let id: Int
    let x: CGFloat       // normalised 0-1
    let y: CGFloat
    let angle: CGFloat   // radians
    let speed: CGFloat
    let size: CGFloat
    let hue: CGFloat     // 0=gold, 1=lavender
}

// MARK: - Infinity Path

private struct InfinityPath: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let w = rect.width * 0.48, h = rect.height * 0.48
        var p = Path()
        p.move(to: CGPoint(x: cx, y: cy))
        p.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: cx - w * 0.1, y: cy - h * 2.0),
            control2: CGPoint(x: cx - w * 2.2, y: cy - h * 2.0)
        )
        p.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: cx - w * 2.2, y: cy + h * 2.0),
            control2: CGPoint(x: cx - w * 0.1, y: cy + h * 2.0)
        )
        p.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: cx + w * 0.1, y: cy + h * 2.0),
            control2: CGPoint(x: cx + w * 2.2, y: cy + h * 2.0)
        )
        p.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: cx + w * 2.2, y: cy - h * 2.0),
            control2: CGPoint(x: cx + w * 0.1, y: cy - h * 2.0)
        )
        return p
    }
}

// MARK: - Sacred Geometry Helpers

private func makeStarOfDavid(center: CGPoint, radius: CGFloat) -> Path {
    func tri(_ r: CGFloat, _ rot: CGFloat) -> [CGPoint] {
        (0..<3).map { i in
            let a = rot + CGFloat(i) * .pi * 2 / 3
            return CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
        }
    }
    var path = Path()
    for pts in [tri(radius, -.pi / 2), tri(radius, .pi / 2)] {
        path.move(to: pts[0])
        path.addLine(to: pts[1])
        path.addLine(to: pts[2])
        path.closeSubpath()
    }
    return path
}

private func makeFlowerOfLife(center: CGPoint, radius: CGFloat) -> Path {
    let offsets: [(CGFloat, CGFloat)] = [
        (0, 0),
        (radius, 0), (-radius, 0),
        (radius * 0.5, radius * 0.866),
        (-radius * 0.5, radius * 0.866),
        (radius * 0.5, -radius * 0.866),
        (-radius * 0.5, -radius * 0.866)
    ]
    var path = Path()
    for (dx, dy) in offsets {
        let c = CGPoint(x: center.x + dx, y: center.y + dy)
        path.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
    }
    return path
}

// MARK: - Pre-seeded Particles

private let kSplashParticles: [SplashParticle] = {
    var arr = [SplashParticle]()
    arr.reserveCapacity(120)
    for i in 0..<120 {
        let fi = CGFloat(i)
        arr.append(SplashParticle(
            id: i,
            x: 0.5, y: 0.5,
            angle: fi * 2.399963,
            speed: 0.18 + fi.truncatingRemainder(dividingBy: 7) * 0.042,
            size: 2.0 + fi.truncatingRemainder(dividingBy: 5) * 1.1,
            hue: fi.truncatingRemainder(dividingBy: 3) < 1.5 ? 0 : 1
        ))
    }
    return arr
}()

// MARK: - Main View

struct LaunchAnimationView: View {
    let onComplete: () -> Void

    // Phase 1 & 2 — geometry
    @State private var circleProgress: CGFloat = 0
    @State private var starProgress: CGFloat   = 0
    @State private var flowerProgress: CGFloat = 0
    @State private var geoScale: CGFloat = 1.0
    @State private var geoAngle: Double  = 0
    @State private var starsAlpha: CGFloat = 0

    // Phase 3 — portal
    @State private var portalAlpha: CGFloat = 0
    @State private var ringsAlpha: CGFloat  = 0
    @State private var arcFlicker: CGFloat  = 1
    @State private var flickerTimer: Timer?

    // Phase 4 — twin orbs
    @State private var orbsAlpha: CGFloat = 0
    @State private var orbGoldX: CGFloat  = -180
    @State private var orbLavX: CGFloat   =  180
    @State private var orbGoldY: CGFloat  =  0
    @State private var orbLavY: CGFloat   =  0
    @State private var tetherVisible: Bool = false

    // Phase 5 — collision
    @State private var flashAlpha: CGFloat    = 0
    @State private var shockScale: CGFloat    = 0
    @State private var shockAlpha: CGFloat    = 0
    @State private var particlesLive: Bool    = false
    @State private var particleAge: CGFloat   = 0
    @State private var cardAlpha: CGFloat     = 0
    @State private var infTrim: CGFloat       = 0
    @State private var infAlpha: CGFloat      = 0
    @State private var chromaX: CGFloat       = 0

    // Phase 6 — title
    @State private var titleAlpha: CGFloat     = 0
    @State private var titleSlide: CGFloat     = 32
    @State private var subtitleAlpha: CGFloat  = 0
    @State private var subtitleSlide: CGFloat  = 20
    @State private var lineProgress: CGFloat   = 0

    // Phase 7 — dissolve
    @State private var dissolve: CGFloat = 0

    // Continuous
    @State private var pulse: Bool = false
    @State private var shakeX: CGFloat = 0
    @State private var shakeY: CGFloat = 0

    private let gold  = Color(hex: "F4C261")
    private let lav   = Color(hex: "B57BFF")
    private let cream = Color(hex: "F5EFE0")
    private let deep  = Color(hex: "0D0418")
    private let ink   = Color(hex: "0D0D1A")

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Background
                deep.ignoresSafeArea()

                RadialGradient(
                    colors: [lav.opacity(0.20), Color.clear],
                    center: .center, startRadius: 0, endRadius: h * 0.65
                )
                .ignoresSafeArea()
                .opacity(Double(starsAlpha))

                // Stars
                starField(w: w, h: h)
                    .opacity(Double(starsAlpha))

                // ─── Sacred Geometry ──────────────────────────────────
                ZStack {
                    // Flower of Life
                    Canvas { ctx, size in
                        let c = CGPoint(x: size.width / 2, y: size.height / 2)
                        let path = makeFlowerOfLife(center: c, radius: 50)
                        ctx.stroke(path, with: .color(lav.opacity(0.13 * Double(flowerProgress))), lineWidth: 0.55)
                    }
                    .frame(width: w, height: h)

                    // Outer ring
                    Circle()
                        .trim(from: 0, to: circleProgress)
                        .stroke(
                            AngularGradient(colors: [gold, lav, gold], center: .center),
                            style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    // Star of David
                    Canvas { ctx, size in
                        let c = CGPoint(x: size.width / 2, y: size.height / 2)
                        let path = makeStarOfDavid(center: c, radius: 58 * starProgress)
                        ctx.stroke(path, with: .color(gold.opacity(0.88)), lineWidth: 1.0)
                    }
                    .frame(width: 160, height: 160)
                }
                .scaleEffect(geoScale)
                .rotationEffect(.degrees(geoAngle))
                .offset(x: shakeX, y: shakeY)

                // ─── Portal ───────────────────────────────────────────
                if portalAlpha > 0 {
                    TimelineView(.animation) { tl in
                        portalCanvas(w: w, h: h, t: CGFloat(tl.date.timeIntervalSinceReferenceDate))
                    }
                    .opacity(Double(portalAlpha))
                    .offset(x: shakeX, y: shakeY)
                }

                // Concentric rings
                if ringsAlpha > 0 {
                    ringStack()
                        .opacity(Double(ringsAlpha))
                        .offset(x: shakeX, y: shakeY)
                }

                // ─── Twin Orbs ────────────────────────────────────────
                if orbsAlpha > 0 {
                    TimelineView(.animation) { tl in
                        let t = CGFloat(tl.date.timeIntervalSinceReferenceDate)
                        ZStack {
                            if tetherVisible {
                                tether(
                                    from: CGPoint(x: w/2 + orbGoldX, y: h/2 + orbGoldY),
                                    to:   CGPoint(x: w/2 + orbLavX,  y: h/2 + orbLavY),
                                    w: w, h: h, t: t
                                )
                            }
                            orbView(color: gold, t: t, phase: 0)
                                .frame(width: 72, height: 72)
                                .offset(x: orbGoldX, y: orbGoldY)
                            orbView(color: lav, t: t, phase: .pi)
                                .frame(width: 72, height: 72)
                                .offset(x: orbLavX, y: orbLavY)
                        }
                    }
                    .opacity(Double(orbsAlpha))
                    .offset(x: shakeX, y: shakeY)
                }

                // ─── Collision ────────────────────────────────────────
                Color.white
                    .ignoresSafeArea()
                    .opacity(Double(flashAlpha))
                    .allowsHitTesting(false)

                if shockAlpha > 0 {
                    ZStack {
                        ForEach(0..<4, id: \.self) { i in
                            let fi = CGFloat(i)
                            let sc = max(0, shockScale - fi * 0.18)
                            Circle()
                                .stroke(i % 2 == 0 ? gold : lav, lineWidth: 1.8)
                                .frame(width: 40, height: 40)
                                .scaleEffect(sc * 9)
                                .opacity(Double(max(0, 1 - sc)))
                        }
                    }
                    .opacity(Double(shockAlpha))
                    .offset(x: shakeX, y: shakeY)
                }

                if particlesLive && particleAge > 0 {
                    Canvas { ctx, size in
                        let c = CGPoint(x: size.width / 2, y: size.height / 2)
                        let age = Double(particleAge)
                        for p in kSplashParticles {
                            let dist = p.speed * age * size.width * 0.85
                            let px = c.x + cos(p.angle) * dist
                            let py = c.y + sin(p.angle) * dist
                            let fade = max(0, 1 - age * 1.65)
                            let sz = p.size * CGFloat(1.0 + age * 2.5)
                            let col: Color = p.hue < 0.5 ? gold.opacity(fade) : lav.opacity(fade)
                            ctx.fill(
                                Path(ellipseIn: CGRect(x: px - sz/2, y: py - sz/2, width: sz, height: sz)),
                                with: .color(col)
                            )
                        }
                    }
                    .allowsHitTesting(false)
                    .offset(x: shakeX, y: shakeY)
                }

                // ─── Infinity + Card ──────────────────────────────────
                if cardAlpha > 0 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [gold.opacity(0.5), lav.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .frame(width: 200, height: 112)

                        // Chromatic aberration layers
                        Group {
                            InfinityPath()
                                .trim(from: 0, to: infTrim)
                                .stroke(Color.red.opacity(0.30),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .offset(x: -chromaX)

                            InfinityPath()
                                .trim(from: 0, to: infTrim)
                                .stroke(Color.blue.opacity(0.30),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .offset(x: chromaX)

                            InfinityPath()
                                .trim(from: 0, to: infTrim)
                                .stroke(
                                    LinearGradient(colors: [gold, lav, gold],
                                                   startPoint: .leading, endPoint: .trailing),
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                )
                        }
                        .frame(width: 156, height: 60)
                        .opacity(Double(infAlpha))
                    }
                    .opacity(Double(cardAlpha))
                    .offset(x: shakeX, y: shakeY)
                }

                // ─── Title ────────────────────────────────────────────
                if titleAlpha > 0 {
                    VStack(spacing: 6) {
                        Text("TWIN FLAME")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .tracking(8)
                            .foregroundStyle(
                                LinearGradient(colors: [cream, gold],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .offset(y: -titleSlide)
                            .opacity(Double(titleAlpha))

                        Text("UNION")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .tracking(8)
                            .foregroundStyle(lav)
                            .offset(y: -titleSlide * 0.55)
                            .opacity(Double(titleAlpha))

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, lav, Color.clear],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: 180 * lineProgress, height: 1.5)
                            .opacity(Double(lineProgress))
                            .padding(.top, 4)

                        Text("Your Sacred Journey")
                            .font(.system(size: 13, weight: .light, design: .rounded))
                            .tracking(3)
                            .foregroundStyle(cream.opacity(0.7))
                            .offset(y: subtitleSlide)
                            .opacity(Double(subtitleAlpha))
                    }
                    .offset(y: 108)
                    .offset(x: shakeX, y: shakeY)
                }

                // ─── Dissolve ─────────────────────────────────────────
                ink.ignoresSafeArea()
                    .opacity(Double(dissolve))
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear { runSequence() }
        .onDisappear { flickerTimer?.invalidate(); flickerTimer = nil }
    }

    // MARK: - Sub-views

    private func starField(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, size in
            for i in 0..<55 {
                let fi = Double(i)
                let x = (fi * 137.508 + 23).truncatingRemainder(dividingBy: Double(size.width))
                let y = (fi * 89.31 + 11).truncatingRemainder(dividingBy: Double(size.height))
                let r = 0.45 + (fi.truncatingRemainder(dividingBy: 3)) * 0.4
                let op = 0.12 + (fi.truncatingRemainder(dividingBy: 5)) * 0.055
                ctx.fill(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(.white.opacity(op))
                )
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func portalCanvas(w: CGFloat, h: CGFloat, t: CGFloat) -> some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            // Spiral lines
            for i in 0..<36 {
                let fi = CGFloat(i)
                let base = fi * (.pi * 2 / 36)
                let angle = base + t * 0.8
                let sAngle = angle + fi * 0.12
                var line = Path()
                line.move(to: CGPoint(x: c.x + cos(sAngle) * 10, y: c.y + sin(sAngle) * 10))
                line.addLine(to: CGPoint(x: c.x + cos(angle) * 90, y: c.y + sin(angle) * 90))
                let op = 0.10 + 0.08 * abs(sin(t + fi))
                ctx.stroke(line, with: .color(lav.opacity(op)), lineWidth: 0.65)
            }
            // Electric arcs
            for j in 0..<6 {
                let fj = CGFloat(j)
                let a = fj * (.pi / 3) + t * 2.2
                let r1 = 38 + sin(t * 3 + fj) * 12
                let r2 = 72 + cos(t * 2 + fj) * 14
                var arc = Path()
                arc.move(to: CGPoint(x: c.x + cos(a) * r1, y: c.y + sin(a) * r1))
                arc.addLine(to: CGPoint(x: c.x + cos(a + 0.4) * r2, y: c.y + sin(a + 0.4) * r2))
                let flicker = 0.35 + 0.65 * abs(sin(t * 11 + fj * 1.7))
                ctx.stroke(arc, with: .color(lav.opacity(flicker * Double(arcFlicker))), lineWidth: 1.1)
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func ringStack() -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                let fi = Double(i)
                let sz = CGFloat(40 + i * 28)
                Circle()
                    .stroke(
                        i % 2 == 0 ? gold.opacity(0.18 - fi * 0.02) : lav.opacity(0.15 - fi * 0.02),
                        lineWidth: 0.9
                    )
                    .frame(width: sz, height: sz)
                    .scaleEffect(pulse ? 1.04 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.2 + fi * 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(fi * 0.15),
                        value: pulse
                    )
            }
        }
    }

    private func orbView(color: Color, t: CGFloat, phase: CGFloat) -> some View {
        let gx = 0.5 + 0.28 * sin(t * 1.3 + phase)
        let gy = 0.5 + 0.28 * cos(t * 0.9 + phase)
        return ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [color, color.opacity(0.25), Color.clear],
                    center: UnitPoint(x: gx, y: gy),
                    startRadius: 0, endRadius: 36
                ))
            Circle()
                .stroke(color.opacity(0.45), lineWidth: 1)
                .scaleEffect(1.0 + 0.04 * sin(t * 3))
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 10, height: 10)
                .offset(x: (gx - 0.5) * 20, y: (gy - 0.5) * 20)
                .blur(radius: 3)
        }
    }

    private func tether(from: CGPoint, to: CGPoint, w: CGFloat, h: CGFloat, t: CGFloat) -> some View {
        Canvas { ctx, size in
            let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2 + sin(t * 3) * 14)
            var path = Path()
            path.move(to: from)
            path.addQuadCurve(to: to, control: mid)
            ctx.stroke(path, with: .color(lav.opacity(0.4)), lineWidth: 1.1)
            for k in 0..<4 {
                let pr = (t * 0.4 + CGFloat(k) * 0.25).truncatingRemainder(dividingBy: 1.0)
                let bx = from.x + (to.x - from.x) * pr
                let by = from.y + (to.y - from.y) * pr
                ctx.fill(
                    Path(ellipseIn: CGRect(x: bx - 2.5, y: by - 2.5, width: 5, height: 5)),
                    with: .color(.white.opacity(0.65))
                )
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    // MARK: - Sequence

    private func runSequence() {
        pulse = true

        // Phase 1: Void 0–0.7s
        withAnimation(.easeOut(duration: 0.62)) { circleProgress = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            withAnimation(.easeOut(duration: 0.48)) { starProgress = 1 }
        }

        // Phase 2: Bloom 0.7–1.6s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) { geoScale = 3.0 }
            withAnimation(.easeInOut(duration: 0.85)) {
                flowerProgress = 1
                starsAlpha = 1
            }
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                geoAngle = 360
            }
        }

        // Phase 3: Portal 1.6–2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.60) {
            withAnimation(.easeIn(duration: 0.38)) {
                geoScale = 0.35
                circleProgress = 0
                starProgress = 0
                flowerProgress = 0
            }
            withAnimation(.easeOut(duration: 0.65)) {
                portalAlpha = 1
                ringsAlpha  = 1
            }
            // Flicker timer for arcs
            var flickerTick = 0
            flickerTimer?.invalidate()
            flickerTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
                flickerTick += 1
                withAnimation(.easeInOut(duration: 0.06)) {
                    arcFlicker = CGFloat.random(in: 0.38...1.0)
                }
                if flickerTick > 13 { timer.invalidate() }
            }
        }

        // Phase 4: Twin Flames 2.5–3.8s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.50) {
            withAnimation(.easeOut(duration: 0.38)) {
                portalAlpha = 0
                ringsAlpha  = 0.3
                orbsAlpha   = 1
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.72)) {
                orbGoldX = -85
                orbLavX  =  85
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                tetherVisible = true
                withAnimation(.easeInOut(duration: 0.55)) { orbGoldY = -24; orbLavY = 24 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.00) {
                withAnimation(.easeInOut(duration: 0.55)) { orbGoldY = 24; orbLavY = -24 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) {
                withAnimation(.easeInOut(duration: 0.85)) {
                    orbGoldX = -28; orbLavX = 28
                    orbGoldY = 0;   orbLavY = 0
                }
            }
        }

        // Phase 5: Collision 3.8–4.6s
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.80) {
            // Shake
            let delays: [Double] = [0, 0.04, 0.08, 0.12, 0.16, 0.21, 0.26]
            let vals: [(CGFloat, CGFloat)] = [(9,0),(-8,4),(7,-3),(-6,3),(4,-2),(-3,1),(0,0)]
            for (idx, d) in delays.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) {
                    withAnimation(.spring(response: 0.08, dampingFraction: 0.5)) {
                        shakeX = vals[idx].0; shakeY = vals[idx].1
                    }
                }
            }
            // Merge orbs
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                orbGoldX = 0; orbLavX = 0
            }
            // Flash
            withAnimation(.easeOut(duration: 0.11)) { flashAlpha = 0.88 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                withAnimation(.easeIn(duration: 0.20)) { flashAlpha = 0 }
            }
            // Shockwave
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                withAnimation(.easeOut(duration: 0.65)) { shockScale = 1.3; shockAlpha = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeOut(duration: 0.25)) { shockAlpha = 0 }
                }
            }
            // Particles
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                particlesLive = true
                withAnimation(.linear(duration: 1.15)) { particleAge = 1 }
            }
            // Fade orbs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeOut(duration: 0.32)) { orbsAlpha = 0; tetherVisible = false }
            }
            // Reveal infinity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                withAnimation(.easeOut(duration: 0.28)) { cardAlpha = 1; infAlpha = 1 }
                withAnimation(.easeInOut(duration: 0.88)) { infTrim = 1; chromaX = 2.5 }
            }
        }

        // Phase 6: Title 4.6–5.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.60) {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.70)) {
                titleAlpha = 1; titleSlide = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeOut(duration: 0.42)) { lineProgress = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
                    subtitleAlpha = 1; subtitleSlide = 0
                }
            }
        }

        // Phase 7: Dissolve 5.4–6.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.40) {
            withAnimation(.easeInOut(duration: 0.60)) { dissolve = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.00) {
            onComplete()
        }
    }
}
