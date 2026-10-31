import SwiftUI

struct BatEmblem: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + width * 0.5, y: rect.minY + height * 0.04))
        path.addCurve(
            to: CGPoint(x: rect.minX + width * 0.98, y: rect.minY + height * 0.35),
            control1: CGPoint(x: rect.minX + width * 0.72, y: rect.minY + height * 0.07),
            control2: CGPoint(x: rect.minX + width * 0.88, y: rect.minY + height * 0.12)
        )
        path.addLine(to: CGPoint(x: rect.minX + width * 0.82, y: rect.minY + height * 0.62))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.68, y: rect.minY + height * 0.44))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.60, y: rect.minY + height * 0.86))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.50, y: rect.minY + height * 0.66))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.40, y: rect.minY + height * 0.86))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.32, y: rect.minY + height * 0.44))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.18, y: rect.minY + height * 0.62))
        path.addLine(to: CGPoint(x: rect.minX + width * 0.02, y: rect.minY + height * 0.35))
        path.addCurve(
            to: CGPoint(x: rect.minX + width * 0.5, y: rect.minY + height * 0.04),
            control1: CGPoint(x: rect.minX + width * 0.12, y: rect.minY + height * 0.12),
            control2: CGPoint(x: rect.minX + width * 0.28, y: rect.minY + height * 0.07)
        )
        path.closeSubpath()
        return path
    }
}

struct GothamSky: View {
    let companion: Companion
    let rainEnabled: Bool

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [companion.skyTop, companion.skyMiddle, companion.skyBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            TimelineView(.animation(
                minimumInterval: 1.0 / 24.0,
                paused: scenePhase != .active || reduceMotion
            )) { timeline in
                Canvas { context, size in
                    render(
                        &context,
                        size: size,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            }

            if companion == .joker {
                JokerGraffiti()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: companion)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func render(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let width = size.width
        let height = size.height
        let accent = companion.accent

        // Stars.
        for index in 0..<38 {
            let x = CGFloat((index * 73) % 100) / 100.0 * width
            let y = CGFloat((index * 37) % 58) / 100.0 * height
            let twinkle = 0.18 + 0.20 * (0.5 + 0.5 * sin(time * 0.8 + Double(index)))
            let diameter = CGFloat(1.2 + Double(index % 3) * 0.8)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter)),
                with: .color(Color.white.opacity(twinkle))
            )
        }

        // Moon.
        let moonCenter = CGPoint(x: width * 0.79, y: height * 0.14)
        let moonRadius = min(width * 0.085, 38)
        context.fill(
            Path(ellipseIn: CGRect(
                x: moonCenter.x - moonRadius * 2.1,
                y: moonCenter.y - moonRadius * 2.1,
                width: moonRadius * 4.2,
                height: moonRadius * 4.2
            )),
            with: .radialGradient(
                Gradient(colors: [Color(hex: 0xE8E0C4).opacity(0.22), .clear]),
                center: moonCenter,
                startRadius: moonRadius * 0.5,
                endRadius: moonRadius * 2.1
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: moonCenter.x - moonRadius,
                y: moonCenter.y - moonRadius,
                width: moonRadius * 2,
                height: moonRadius * 2
            )),
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0xFFF8DF), Color(hex: 0xD8CFB4)]),
                startPoint: CGPoint(x: moonCenter.x - moonRadius, y: moonCenter.y - moonRadius),
                endPoint: CGPoint(x: moonCenter.x + moonRadius, y: moonCenter.y + moonRadius)
            )
        )
        for crater in 0..<4 {
            let cx = moonCenter.x - moonRadius * 0.35 + CGFloat(crater) * moonRadius * 0.3
            let cy = moonCenter.y - moonRadius * 0.2 + CGFloat(crater % 2) * moonRadius * 0.42
            context.fill(
                Path(ellipseIn: CGRect(
                    x: cx,
                    y: cy,
                    width: moonRadius * 0.22,
                    height: moonRadius * 0.18
                )),
                with: .color(Color(hex: 0xB8AE96).opacity(0.35))
            )
        }

        if companion == .batman {
            drawSignal(&context, size: size, time: time)
            drawBats(&context, size: size, time: time)
        } else {
            drawJokerGlow(&context, size: size, time: time)
        }

        drawSkyline(&context, size: size, time: time, accent: accent)

        if rainEnabled {
            drawRain(&context, size: size, time: time)
        }

        // Fog / vignette.
        context.fill(
            Path(CGRect(x: 0, y: height * 0.55, width: width, height: height * 0.45)),
            with: .linearGradient(
                Gradient(colors: [.clear, GothamTheme.ink.opacity(0.55), GothamTheme.ink.opacity(0.92)]),
                startPoint: CGPoint(x: width * 0.5, y: height * 0.55),
                endPoint: CGPoint(x: width * 0.5, y: height)
            )
        )
    }

    private func drawSignal(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let center = CGPoint(x: size.width * 0.70, y: size.height * 0.21)
        let radius = min(size.width * 0.115, 48)
        let pulse = CGFloat(1.0 + 0.025 * sin(time * 0.9))
        let yellow = GothamTheme.batYellow

        // Soft cone of light falling from the signal.
        var beam = Path()
        beam.move(to: CGPoint(x: center.x - radius * 0.55, y: center.y + radius * 0.15))
        beam.addLine(to: CGPoint(x: center.x + radius * 0.55, y: center.y + radius * 0.05))
        beam.addLine(to: CGPoint(x: size.width * 0.58, y: size.height * 0.86))
        beam.addLine(to: CGPoint(x: size.width * 0.40, y: size.height * 0.86))
        beam.closeSubpath()
        context.fill(
            beam,
            with: .linearGradient(
                Gradient(colors: [yellow.opacity(0.10), yellow.opacity(0.015), .clear]),
                startPoint: CGPoint(x: center.x, y: center.y),
                endPoint: CGPoint(x: size.width * 0.5, y: size.height * 0.9)
            )
        )

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 2.5,
                y: center.y - radius * 2.5,
                width: radius * 5,
                height: radius * 5
            )),
            with: .radialGradient(
                Gradient(colors: [yellow.opacity(0.30), yellow.opacity(0.10), .clear]),
                center: center,
                startRadius: 0,
                endRadius: radius * 2.5
            )
        )

        let discRect = CGRect(
            x: center.x - radius * pulse,
            y: center.y - radius * pulse,
            width: radius * 2 * pulse,
            height: radius * 2 * pulse
        )
        context.fill(
            Path(ellipseIn: discRect),
            with: .radialGradient(
                Gradient(colors: [Color(hex: 0xFFF4BF), yellow]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
        context.stroke(
            Path(ellipseIn: discRect),
            with: .color(yellow.opacity(0.7)),
            lineWidth: 1.5
        )

        let emblemRect = CGRect(
            x: center.x - radius * 0.66,
            y: center.y - radius * 0.34,
            width: radius * 1.32,
            height: radius * 0.68
        )
        context.fill(BatEmblem().path(in: emblemRect), with: .color(Color(hex: 0x0A0E16)))
    }

    private func drawJokerGlow(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let center = CGPoint(x: size.width * 0.76, y: size.height * 0.17)
        let radius = min(size.width * 0.34, 150)
        let breathe = CGFloat(1.0 + 0.05 * sin(time * 0.7))
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius * breathe,
                y: center.y - radius * breathe,
                width: radius * 2 * breathe,
                height: radius * 2 * breathe
            )),
            with: .radialGradient(
                Gradient(colors: [
                    GothamTheme.jokerGreen.opacity(0.14),
                    GothamTheme.jokerPurple.opacity(0.22),
                    .clear
                ]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )

        for ring in 0..<3 {
            let ringRadius = radius * (0.32 + CGFloat(ring) * 0.15)
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - ringRadius,
                    y: center.y - ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                )),
                with: .color(GothamTheme.jokerGreen.opacity(0.06)),
                lineWidth: 1
            )
        }
    }

    private func drawBats(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let bats: [(CGFloat, CGFloat, CGFloat)] = [
            (0.16, 0.17, 22),
            (0.27, 0.27, 13),
            (0.88, 0.34, 16),
            (0.61, 0.11, 10)
        ]
        for (index, bat) in bats.enumerated() {
            let flap = CGFloat(sin(time * 3.0 + Double(index) * 1.7) * 2.5)
            let rect = CGRect(
                x: size.width * bat.0,
                y: size.height * bat.1 + flap,
                width: bat.2,
                height: bat.2 * 0.56
            )
            context.fill(BatEmblem().path(in: rect), with: .color(Color(hex: 0x05070C).opacity(0.8)))
        }
    }

    private func drawSkyline(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval, accent: Color) {
        let width = size.width
        let height = size.height
        let baseY = height * 0.925

        let far: [(x: CGFloat, width: CGFloat, height: CGFloat)] = [
            (0.00, 0.09, 0.20), (0.07, 0.07, 0.30), (0.15, 0.09, 0.23),
            (0.23, 0.06, 0.35), (0.30, 0.08, 0.26), (0.38, 0.07, 0.38),
            (0.46, 0.09, 0.28), (0.55, 0.06, 0.33), (0.62, 0.08, 0.24),
            (0.70, 0.07, 0.31), (0.78, 0.09, 0.22), (0.87, 0.08, 0.29),
            (0.95, 0.09, 0.24)
        ]

        for (index, building) in far.enumerated() {
            let buildingWidth = width * building.width
            let buildingHeight = height * building.height
            let rect = CGRect(
                x: width * building.x,
                y: baseY - buildingHeight,
                width: buildingWidth,
                height: buildingHeight
            )
            context.fill(
                Path(rect),
                with: .color(Color(hex: 0x0C1522).opacity(0.62))
            )

            if index % 3 == 0 {
                var antenna = Path()
                antenna.move(to: CGPoint(x: rect.midX, y: rect.minY))
                antenna.addLine(to: CGPoint(x: rect.midX, y: rect.minY - 14))
                context.stroke(
                    antenna,
                    with: .color(Color(hex: 0x0C1522).opacity(0.7)),
                    lineWidth: 1.5
                )
            }
        }

        let near: [(x: CGFloat, width: CGFloat, height: CGFloat)] = [
            (-0.02, 0.12, 0.14), (0.08, 0.09, 0.20), (0.16, 0.11, 0.13),
            (0.25, 0.08, 0.24), (0.32, 0.10, 0.16), (0.41, 0.09, 0.21),
            (0.49, 0.12, 0.15), (0.60, 0.08, 0.25), (0.67, 0.10, 0.18),
            (0.76, 0.09, 0.22), (0.84, 0.10, 0.15), (0.93, 0.11, 0.20)
        ]

        for (index, building) in near.enumerated() {
            let buildingWidth = width * building.width
            let buildingHeight = height * building.height
            let rect = CGRect(
                x: width * building.x,
                y: baseY - buildingHeight,
                width: buildingWidth,
                height: buildingHeight
            )
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [Color(hex: 0x080D16), Color(hex: 0x02040A)]),
                    startPoint: CGPoint(x: rect.midX, y: rect.minY),
                    endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                )
            )
            context.stroke(
                Path(rect),
                with: .color(Color(hex: 0x263349).opacity(0.32)),
                lineWidth: 1
            )

            // Rooftop trim.
            context.fill(
                Path(CGRect(x: rect.minX - 2, y: rect.minY, width: rect.width + 4, height: 2.5)),
                with: .color(Color(hex: 0x34445E).opacity(0.35))
            )

            let columns = max(1, Int(buildingWidth / 13))
            let rows = max(1, Int(buildingHeight / 22))
            for column in 0..<columns {
                for row in 0..<rows {
                    guard (column * 5 + row * 3 + index) % 4 != 0 else { continue }
                    let flicker = 0.7 + 0.3 * sin(time * 0.2 + Double(index + row))
                    let windowRect = CGRect(
                        x: rect.minX + 5 + CGFloat(column) * 12,
                        y: rect.minY + 9 + CGFloat(row) * 20,
                        width: 4,
                        height: 6
                    )
                    guard windowRect.maxX < rect.maxX - 3, windowRect.maxY < rect.maxY - 4 else { continue }
                    context.fill(
                        Path(windowRect),
                        with: .color(accent.opacity(0.22 * flicker))
                    )
                }
            }
        }

        // A gargoyle-ish ledge on the right.
        var gargoyle = Path()
        gargoyle.move(to: CGPoint(x: width * 0.92, y: baseY - height * 0.11))
        gargoyle.addLine(to: CGPoint(x: width * 0.97, y: baseY - height * 0.13))
        gargoyle.addLine(to: CGPoint(x: width, y: baseY - height * 0.09))
        gargoyle.addLine(to: CGPoint(x: width, y: baseY))
        gargoyle.addLine(to: CGPoint(x: width * 0.92, y: baseY))
        gargoyle.closeSubpath()
        context.fill(gargoyle, with: .color(Color(hex: 0x02040A)))
    }

    private func drawRain(_ context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        var rain = Path()
        for index in 0..<56 {
            let x = CGFloat((index * 47) % 100) / 100.0 * size.width
            let speed = 250.0 + Double(index % 7) * 45.0
            let rawY = (Double(index * 31) + time * speed)
                .truncatingRemainder(dividingBy: Double(size.height + 140))
            let y = CGFloat(rawY) - 70
            let length = CGFloat(10 + (index % 4) * 3)
            rain.move(to: CGPoint(x: x, y: y))
            rain.addLine(to: CGPoint(x: x - 3, y: y + length))
        }
        context.stroke(
            rain,
            with: .color(Color(hex: 0xBFD8F2).opacity(0.15)),
            lineWidth: 1
        )
    }
}

private struct JokerGraffiti: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                graffiti("HA", size: 58, rotation: -12)
                    .position(x: geo.size.width * 0.18, y: geo.size.height * 0.16)
                graffiti("HA", size: 34, rotation: 9)
                    .position(x: geo.size.width * 0.38, y: geo.size.height * 0.26)
                graffiti("HA", size: 22, rotation: -6)
                    .position(x: geo.size.width * 0.58, y: geo.size.height * 0.12)
                Text("WHY SO SERIOUS?")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .tracking(2.2)
                    .foregroundStyle(GothamTheme.jokerGreen.opacity(0.18))
                    .rotationEffect(.degrees(6))
                    .position(x: geo.size.width * 0.82, y: geo.size.height * 0.33)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func graffiti(_ text: String, size: CGFloat, rotation: Double) -> some View {
        Text(text)
            .font(.system(size: size, weight: .black, design: .rounded))
            .foregroundStyle(GothamTheme.jokerGreen.opacity(0.16))
            .rotationEffect(.degrees(rotation))
            .shadow(color: GothamTheme.jokerGreen.opacity(0.2), radius: 10)
    }
}
