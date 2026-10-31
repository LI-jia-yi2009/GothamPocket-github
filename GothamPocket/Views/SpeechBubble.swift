import SwiftUI

struct SpeechBubble: View {
    let text: String
    let label: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .tracking(1.4)
                .foregroundStyle(GothamTheme.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(accent))

            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(GothamTheme.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            BubbleShape()
                .fill(GothamTheme.paper)
                .overlay(
                    BubbleShape()
                        .stroke(GothamTheme.ink, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                )
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.45), radius: 0, x: 4, y: 5)
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
        .rotationEffect(.degrees(-0.7))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)，\(text)")
    }
}

private struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailHeight: CGFloat = 12
        let bottom = rect.maxY - tailHeight
        let tailLeft = rect.width * 0.20
        let tailRight = rect.width * 0.44
        let apex = rect.width * 0.27

        var path = Path()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: radius),
            control: CGPoint(x: rect.maxX, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: bottom - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: bottom),
            control: CGPoint(x: rect.maxX, y: bottom)
        )
        path.addLine(to: CGPoint(x: tailRight, y: bottom))
        path.addLine(to: CGPoint(x: apex, y: rect.maxY))
        path.addLine(to: CGPoint(x: tailLeft, y: bottom))
        path.addLine(to: CGPoint(x: radius, y: bottom))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: bottom - radius),
            control: CGPoint(x: 0, y: bottom)
        )
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.closeSubpath()
        return path
    }
}
