import SwiftUI

struct EffectBurst: View {
    let effect: PetEffect
    let companion: Companion

    @State private var animate = false

    private var particles: [BurstParticle] {
        (0..<11).map { index in
            let angle = Double(index) / 11.0 * .pi * 2 - .pi / 2
            let distance = 74.0 + Double(index % 4) * 17.0
            return BurstParticle(
                id: index,
                symbol: effect.symbols[index % effect.symbols.count],
                x: CGFloat(cos(angle)) * CGFloat(distance),
                y: CGFloat(sin(angle)) * CGFloat(distance) - 24,
                size: CGFloat(13 + (index % 3) * 4),
                delay: Double(index) * 0.018
            )
        }
    }

    var body: some View {
        ZStack {
            Starburst(points: 12, innerRatio: 0.70)
                .fill(companion.accent)
                .overlay(
                    Starburst(points: 12, innerRatio: 0.70)
                        .stroke(GothamTheme.ink, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                )
                .overlay(
                    Text(effect.headline)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(GothamTheme.ink)
                        .rotationEffect(.degrees(-4))
                )
                .frame(width: 104, height: 84)
                .rotationEffect(.degrees(animate ? 7 : -12))
                .scaleEffect(animate ? 1 : 0.15)
                .opacity(animate ? 1 : 0)
                .offset(y: -46)
                .shadow(color: .black.opacity(0.4), radius: 0, x: 3, y: 4)

            ForEach(particles) { particle in
                Image(systemName: particle.symbol)
                    .font(.system(size: particle.size, weight: .black))
                    .foregroundStyle(
                        particle.id.isMultiple(of: 2)
                            ? companion.accent
                            : companion.secondaryAccent
                    )
                    .shadow(color: .black.opacity(0.35), radius: 2, x: 1, y: 2)
                    .offset(
                        x: animate ? particle.x : 0,
                        y: animate ? particle.y : -18
                    )
                    .scaleEffect(animate ? 1.15 : 0.2)
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 0.85).delay(particle.delay),
                        value: animate
                    )
            }
        }
        .frame(width: 230, height: 220)
        .onAppear {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.56)) {
                animate = true
            }
        }
        .accessibilityHidden(true)
    }
}

private struct BurstParticle: Identifiable {
    let id: Int
    let symbol: String
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
}

struct Starburst: Shape {
    var points: Int = 12
    var innerRatio: CGFloat = 0.68

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        let count = max(3, points)

        var path = Path()
        for index in 0..<(count * 2) {
            let radius = index.isMultiple(of: 2) ? outer : inner
            let angle = -Double.pi / 2 + Double(index) * .pi / Double(count)
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
