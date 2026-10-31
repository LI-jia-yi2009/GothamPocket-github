import SwiftUI

struct CharacterArt: View {
    let companion: Companion
    let mood: Double
    let time: TimeInterval

    private let outline = Color(hex: 0x05070C)

    var body: some View {
        Canvas { context, _ in
            let blink = Int(time * 8) % 41 < 2
            let wave = CGFloat(sin(time * 1.9) * 2.6)

            if companion == .batman {
                drawBatman(&context, blink: blink, wave: wave)
            } else {
                drawJoker(&context, blink: blink, wave: wave)
            }
        }
        .frame(width: 240, height: 300)
        .accessibilityHidden(true)
    }

    // MARK: - Batman

    private func drawBatman(_ context: inout GraphicsContext, blink: Bool, wave: CGFloat) {
        let cowl = Color(hex: 0x1A2232)
        let suit = Color(hex: 0x242C3B)
        let glove = Color(hex: 0x10151F)
        let yellow = Color(hex: 0xF4C84B)
        let skinTop = Color(hex: 0xF3CDB0)
        let skinBottom = Color(hex: 0xDCA07F)

        // Cape, scalloped and waving a little.
        var cape = Path()
        cape.move(to: CGPoint(x: 86, y: 148))
        cape.addCurve(
            to: CGPoint(x: 44 + wave, y: 258),
            control1: CGPoint(x: 48, y: 190),
            control2: CGPoint(x: 30, y: 228)
        )
        cape.addLine(to: CGPoint(x: 62, y: 246))
        cape.addLine(to: CGPoint(x: 78, y: 264))
        cape.addLine(to: CGPoint(x: 94, y: 246))
        cape.addLine(to: CGPoint(x: 110, y: 264))
        cape.addLine(to: CGPoint(x: 126, y: 246))
        cape.addLine(to: CGPoint(x: 142, y: 264))
        cape.addLine(to: CGPoint(x: 158, y: 246))
        cape.addLine(to: CGPoint(x: 178, y: 264))
        cape.addLine(to: CGPoint(x: 196 - wave, y: 258))
        cape.addCurve(
            to: CGPoint(x: 154, y: 148),
            control1: CGPoint(x: 210, y: 228),
            control2: CGPoint(x: 192, y: 190)
        )
        cape.closeSubpath()
        context.fill(
            cape,
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0x2D3546), Color(hex: 0x10141D)]),
                startPoint: CGPoint(x: 120, y: 150),
                endPoint: CGPoint(x: 120, y: 264)
            )
        )
        context.stroke(cape, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))
        context.stroke(cape, with: .color(Color.white.opacity(0.06)), lineWidth: 1.5)

        // Legs and boots.
        context.fill(rounded(94, 226, 21, 40, 10), with: .color(suit))
        context.stroke(rounded(94, 226, 21, 40, 10), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(125, 226, 21, 40, 10), with: .color(suit))
        context.stroke(rounded(125, 226, 21, 40, 10), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(84, 254, 40, 22, 11), with: .color(glove))
        context.stroke(rounded(84, 254, 40, 22, 11), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(116, 254, 40, 22, 11), with: .color(glove))
        context.stroke(rounded(116, 254, 40, 22, 11), with: .color(outline), lineWidth: 3.5)

        // Body.
        let body = rounded(70, 162, 100, 84, 32)
        context.fill(
            body,
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0x303A4B), Color(hex: 0x171D29)]),
                startPoint: CGPoint(x: 120, y: 164),
                endPoint: CGPoint(x: 120, y: 246)
            )
        )
        context.stroke(body, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))

        // Arms.
        drawArm(
            &context,
            from: CGPoint(x: 80, y: 184),
            to: CGPoint(x: 52, y: 222),
            width: 19,
            color: suit,
            gloveColor: glove
        )
        drawArm(
            &context,
            from: CGPoint(x: 160, y: 184),
            to: CGPoint(x: 187, y: 218),
            width: 19,
            color: suit,
            gloveColor: glove
        )

        // Utility belt.
        context.fill(rounded(77, 215, 86, 15, 5), with: .color(yellow))
        context.stroke(rounded(77, 215, 86, 15, 5), with: .color(outline), lineWidth: 2.5)
        for index in 0..<4 {
            let x = 84 + CGFloat(index) * 21
            context.fill(rounded(x, 218, 12, 9, 3), with: .color(Color(hex: 0xC79B2E)))
        }
        context.fill(rounded(108, 212, 24, 21, 5), with: .color(yellow))
        context.stroke(rounded(108, 212, 24, 21, 5), with: .color(outline), lineWidth: 2.5)

        // Chest emblem.
        let badge = CGRect(x: 99, y: 177, width: 42, height: 27)
        context.fill(Path(ellipseIn: badge), with: .color(yellow))
        context.stroke(Path(ellipseIn: badge), with: .color(outline), lineWidth: 2.5)
        context.fill(
            batSymbol(in: CGRect(x: 105, y: 181, width: 30, height: 18)),
            with: .color(Color(hex: 0x111722))
        )

        // Ears.
        var leftEar = Path()
        leftEar.move(to: CGPoint(x: 84, y: 92))
        leftEar.addCurve(
            to: CGPoint(x: 67, y: 24),
            control1: CGPoint(x: 78, y: 62),
            control2: CGPoint(x: 70, y: 38)
        )
        leftEar.addCurve(
            to: CGPoint(x: 111, y: 77),
            control1: CGPoint(x: 86, y: 52),
            control2: CGPoint(x: 100, y: 67)
        )
        leftEar.closeSubpath()
        context.fill(leftEar, with: .color(cowl))
        context.stroke(leftEar, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))

        var rightEar = Path()
        rightEar.move(to: CGPoint(x: 156, y: 92))
        rightEar.addCurve(
            to: CGPoint(x: 173, y: 24),
            control1: CGPoint(x: 162, y: 62),
            control2: CGPoint(x: 170, y: 38)
        )
        rightEar.addCurve(
            to: CGPoint(x: 129, y: 77),
            control1: CGPoint(x: 154, y: 52),
            control2: CGPoint(x: 140, y: 67)
        )
        rightEar.closeSubpath()
        context.fill(rightEar, with: .color(cowl))
        context.stroke(rightEar, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))

        // Head / cowl.
        let headRect = CGRect(x: 64, y: 64, width: 112, height: 112)
        context.fill(
            Path(ellipseIn: headRect),
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0x2A3447), Color(hex: 0x131924)]),
                startPoint: CGPoint(x: 120, y: 66),
                endPoint: CGPoint(x: 120, y: 174)
            )
        )
        context.stroke(Path(ellipseIn: headRect), with: .color(outline), lineWidth: 4)

        // Exposed lower face.
        var face = Path()
        face.move(to: CGPoint(x: 84, y: 105))
        face.addCurve(
            to: CGPoint(x: 156, y: 105),
            control1: CGPoint(x: 101, y: 96),
            control2: CGPoint(x: 139, y: 96)
        )
        face.addCurve(
            to: CGPoint(x: 146, y: 148),
            control1: CGPoint(x: 158, y: 127),
            control2: CGPoint(x: 154, y: 141)
        )
        face.addCurve(
            to: CGPoint(x: 94, y: 148),
            control1: CGPoint(x: 137, y: 165),
            control2: CGPoint(x: 103, y: 165)
        )
        face.addCurve(
            to: CGPoint(x: 84, y: 105),
            control1: CGPoint(x: 86, y: 141),
            control2: CGPoint(x: 82, y: 126)
        )
        face.closeSubpath()
        context.fill(
            face,
            with: .linearGradient(
                Gradient(colors: [skinTop, skinBottom]),
                startPoint: CGPoint(x: 120, y: 106),
                endPoint: CGPoint(x: 120, y: 155)
            )
        )
        context.stroke(face, with: .color(Color(hex: 0x6D4B39).opacity(0.55)), lineWidth: 1.5)

        // Cowl brow.
        var brow = Path()
        brow.move(to: CGPoint(x: 84, y: 105))
        brow.addQuadCurve(
            to: CGPoint(x: 156, y: 105),
            control: CGPoint(x: 120, y: 96)
        )
        context.stroke(brow, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineCap: .round))

        // Eyes.
        if blink {
            var leftBlink = Path()
            leftBlink.move(to: CGPoint(x: 92, y: 95))
            leftBlink.addQuadCurve(
                to: CGPoint(x: 110, y: 94),
                control: CGPoint(x: 101, y: 99)
            )
            var rightBlink = Path()
            rightBlink.move(to: CGPoint(x: 130, y: 94))
            rightBlink.addQuadCurve(
                to: CGPoint(x: 148, y: 95),
                control: CGPoint(x: 139, y: 99)
            )
            context.stroke(leftBlink, with: .color(Color(hex: 0xCFE7FF)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            context.stroke(rightBlink, with: .color(Color(hex: 0xCFE7FF)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        } else {
            let glow = Color(hex: 0xBFE6FF)
            context.fill(
                Path(ellipseIn: CGRect(x: 86, y: 86, width: 32, height: 22)),
                with: .color(glow.opacity(0.13))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 122, y: 86, width: 32, height: 22)),
                with: .color(glow.opacity(0.13))
            )

            var leftEye = Path()
            leftEye.move(to: CGPoint(x: 90, y: 91))
            leftEye.addLine(to: CGPoint(x: 110, y: 87))
            leftEye.addLine(to: CGPoint(x: 107, y: 102))
            leftEye.addLine(to: CGPoint(x: 91, y: 100))
            leftEye.closeSubpath()

            var rightEye = Path()
            rightEye.move(to: CGPoint(x: 150, y: 91))
            rightEye.addLine(to: CGPoint(x: 130, y: 87))
            rightEye.addLine(to: CGPoint(x: 133, y: 102))
            rightEye.addLine(to: CGPoint(x: 149, y: 100))
            rightEye.closeSubpath()

            context.fill(leftEye, with: .color(glow))
            context.fill(rightEye, with: .color(glow))
            context.stroke(leftEye, with: .color(outline), lineWidth: 1.8)
            context.stroke(rightEye, with: .color(outline), lineWidth: 1.8)
        }

        // Nose and mouth.
        var nose = Path()
        nose.move(to: CGPoint(x: 120, y: 124))
        nose.addQuadCurve(
            to: CGPoint(x: 124, y: 134),
            control: CGPoint(x: 123, y: 130)
        )
        context.stroke(nose, with: .color(Color(hex: 0x8C5C46).opacity(0.7)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        let moodFactor = max(0, min(1, mood / 100))
        let smile = CGFloat(moodFactor - 0.48) * 11
        var mouth = Path()
        mouth.move(to: CGPoint(x: 108, y: 143))
        mouth.addQuadCurve(
            to: CGPoint(x: 132, y: 143),
            control: CGPoint(x: 120, y: 143 + smile)
        )
        context.stroke(mouth, with: .color(Color(hex: 0x6D4034)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        if mood < 25 {
            var worry = Path()
            worry.move(to: CGPoint(x: 108, y: 136))
            worry.addQuadCurve(to: CGPoint(x: 118, y: 135), control: CGPoint(x: 113, y: 133))
            worry.move(to: CGPoint(x: 122, y: 135))
            worry.addQuadCurve(to: CGPoint(x: 132, y: 136), control: CGPoint(x: 127, y: 133))
            context.stroke(worry, with: .color(Color(hex: 0x6D4034).opacity(0.55)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }

        // Chin highlight.
        context.fill(
            Path(ellipseIn: CGRect(x: 103, y: 150, width: 34, height: 8)),
            with: .color(Color.white.opacity(0.08))
        )

        // Cape collar.
        var collar = Path()
        collar.move(to: CGPoint(x: 84, y: 157))
        collar.addQuadCurve(to: CGPoint(x: 120, y: 178), control: CGPoint(x: 101, y: 174))
        collar.addQuadCurve(to: CGPoint(x: 156, y: 157), control: CGPoint(x: 139, y: 174))
        context.stroke(collar, with: .color(outline), style: StrokeStyle(lineWidth: 5, lineCap: .round))
    }

    // MARK: - Joker

    private func drawJoker(_ context: inout GraphicsContext, blink: Bool, wave: CGFloat) {
        let outline = self.outline
        let purple = Color(hex: 0x6A3A8E)
        let purpleDark = Color(hex: 0x3E1E58)
        let green = Color(hex: 0x76D943)
        let greenDark = Color(hex: 0x2C6F2B)
        let skin = Color(hex: 0xF6EDDD)
        let ink = Color(hex: 0x221B24)
        let red = Color(hex: 0xC9314B)

        // Hair, spiking out behind the head.
        var hair = Path()
        hair.move(to: CGPoint(x: 58, y: 136))
        hair.addLine(to: CGPoint(x: 46 + wave, y: 54))
        hair.addLine(to: CGPoint(x: 70, y: 76))
        hair.addLine(to: CGPoint(x: 64, y: 30))
        hair.addLine(to: CGPoint(x: 88, y: 68))
        hair.addLine(to: CGPoint(x: 96, y: 20))
        hair.addLine(to: CGPoint(x: 113, y: 64))
        hair.addLine(to: CGPoint(x: 130, y: 24))
        hair.addLine(to: CGPoint(x: 142, y: 66))
        hair.addLine(to: CGPoint(x: 162, y: 34))
        hair.addLine(to: CGPoint(x: 165, y: 76))
        hair.addLine(to: CGPoint(x: 190 - wave, y: 56))
        hair.addLine(to: CGPoint(x: 176, y: 136))
        hair.closeSubpath()
        context.fill(
            hair,
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0xA6F06A), green, Color(hex: 0x3A8C2E)]),
                startPoint: CGPoint(x: 120, y: 24),
                endPoint: CGPoint(x: 120, y: 150)
            )
        )
        context.stroke(hair, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))

        // Legs and shoes.
        context.fill(rounded(94, 226, 21, 40, 10), with: .color(purpleDark))
        context.stroke(rounded(94, 226, 21, 40, 10), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(125, 226, 21, 40, 10), with: .color(purpleDark))
        context.stroke(rounded(125, 226, 21, 40, 10), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(82, 254, 42, 22, 11), with: .color(Color(hex: 0x1D3323)))
        context.stroke(rounded(82, 254, 42, 22, 11), with: .color(outline), lineWidth: 3.5)
        context.fill(rounded(116, 254, 42, 22, 11), with: .color(Color(hex: 0x1D3323)))
        context.stroke(rounded(116, 254, 42, 22, 11), with: .color(outline), lineWidth: 3.5)

        // Suit.
        let body = rounded(70, 162, 100, 84, 32)
        context.fill(
            body,
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0x8B54B0), purple, purpleDark]),
                startPoint: CGPoint(x: 120, y: 162),
                endPoint: CGPoint(x: 120, y: 246)
            )
        )
        context.stroke(body, with: .color(outline), style: StrokeStyle(lineWidth: 4, lineJoin: .round))

        // Shirt and vest.
        var shirt = Path()
        shirt.move(to: CGPoint(x: 98, y: 163))
        shirt.addLine(to: CGPoint(x: 120, y: 200))
        shirt.addLine(to: CGPoint(x: 142, y: 163))
        shirt.closeSubpath()
        context.fill(shirt, with: .color(Color(hex: 0xEFE2C9)))

        var leftVest = Path()
        leftVest.move(to: CGPoint(x: 84, y: 165))
        leftVest.addLine(to: CGPoint(x: 108, y: 165))
        leftVest.addLine(to: CGPoint(x: 120, y: 197))
        leftVest.addLine(to: CGPoint(x: 120, y: 238))
        leftVest.addLine(to: CGPoint(x: 82, y: 238))
        leftVest.addLine(to: CGPoint(x: 78, y: 184))
        leftVest.closeSubpath()
        context.fill(leftVest, with: .color(Color(hex: 0x3E8A3A)))
        context.stroke(leftVest, with: .color(outline), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))

        var rightVest = Path()
        rightVest.move(to: CGPoint(x: 156, y: 165))
        rightVest.addLine(to: CGPoint(x: 132, y: 165))
        rightVest.addLine(to: CGPoint(x: 120, y: 197))
        rightVest.addLine(to: CGPoint(x: 120, y: 238))
        rightVest.addLine(to: CGPoint(x: 158, y: 238))
        rightVest.addLine(to: CGPoint(x: 162, y: 184))
        rightVest.closeSubpath()
        context.fill(rightVest, with: .color(Color(hex: 0x337733)))
        context.stroke(rightVest, with: .color(outline), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))

        // Bow tie.
        var bowLeft = Path()
        bowLeft.move(to: CGPoint(x: 120, y: 169))
        bowLeft.addLine(to: CGPoint(x: 105, y: 160))
        bowLeft.addLine(to: CGPoint(x: 105, y: 178))
        bowLeft.closeSubpath()
        var bowRight = Path()
        bowRight.move(to: CGPoint(x: 120, y: 169))
        bowRight.addLine(to: CGPoint(x: 135, y: 160))
        bowRight.addLine(to: CGPoint(x: 135, y: 178))
        bowRight.closeSubpath()
        context.fill(bowLeft, with: .color(green))
        context.fill(bowRight, with: .color(green))
        context.stroke(bowLeft, with: .color(outline), lineWidth: 2)
        context.stroke(bowRight, with: .color(outline), lineWidth: 2)
        context.fill(Path(ellipseIn: CGRect(x: 116, y: 164, width: 8, height: 9)), with: .color(greenDark))

        // Boutonniere.
        for angle in stride(from: 0.0, to: 360.0, by: 72.0) {
            let radians = angle * .pi / 180
            let x = 83 + CGFloat(cos(radians)) * 6
            let y = 187 + CGFloat(sin(radians)) * 6
            context.fill(
                Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10)),
                with: .color(Color(hex: 0xF07A2A))
            )
        }
        context.fill(Path(ellipseIn: CGRect(x: 79, y: 183, width: 8, height: 8)), with: .color(Color(hex: 0xF4C84B)))

        // Arms and gloves.
        drawArm(
            &context,
            from: CGPoint(x: 80, y: 184),
            to: CGPoint(x: 56, y: 236),
            width: 18,
            color: purple,
            gloveColor: Color(hex: 0xEDE6D6)
        )
        drawArm(
            &context,
            from: CGPoint(x: 160, y: 184),
            to: CGPoint(x: 188, y: 210),
            width: 18,
            color: purple,
            gloveColor: Color(hex: 0xEDE6D6)
        )

        // Playing card.
        var card = Path()
        card.move(to: CGPoint(x: 42, y: 239))
        card.addLine(to: CGPoint(x: 63, y: 231))
        card.addLine(to: CGPoint(x: 72, y: 257))
        card.addLine(to: CGPoint(x: 51, y: 266))
        card.closeSubpath()
        context.fill(card, with: .color(Color(hex: 0xF8F1DD)))
        context.stroke(card, with: .color(outline), lineWidth: 2)
        var heart = Path()
        heart.move(to: CGPoint(x: 57, y: 248))
        heart.addCurve(
            to: CGPoint(x: 49, y: 243),
            control1: CGPoint(x: 55, y: 243),
            control2: CGPoint(x: 50, y: 241)
        )
        heart.addCurve(
            to: CGPoint(x: 57, y: 248),
            control1: CGPoint(x: 48, y: 246),
            control2: CGPoint(x: 54, y: 248)
        )
        heart.addCurve(
            to: CGPoint(x: 65, y: 243),
            control1: CGPoint(x: 60, y: 248),
            control2: CGPoint(x: 66, y: 246)
        )
        heart.addCurve(
            to: CGPoint(x: 57, y: 248),
            control1: CGPoint(x: 64, y: 241),
            control2: CGPoint(x: 59, y: 243)
        )
        context.fill(heart, with: .color(red))

        // Head.
        let headRect = CGRect(x: 64, y: 64, width: 112, height: 112)
        context.fill(
            Path(ellipseIn: headRect),
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0xFFFAEE), skin, Color(hex: 0xE2D3BE)]),
                startPoint: CGPoint(x: 120, y: 64),
                endPoint: CGPoint(x: 120, y: 176)
            )
        )
        context.stroke(Path(ellipseIn: headRect), with: .color(outline), lineWidth: 4)

        // Swept fringe.
        var fringe = Path()
        fringe.move(to: CGPoint(x: 65, y: 112))
        fringe.addCurve(
            to: CGPoint(x: 175, y: 112),
            control1: CGPoint(x: 64, y: 34),
            control2: CGPoint(x: 176, y: 34)
        )
        fringe.addLine(to: CGPoint(x: 169, y: 103))
        fringe.addLine(to: CGPoint(x: 157, y: 92))
        fringe.addLine(to: CGPoint(x: 150, y: 108))
        fringe.addLine(to: CGPoint(x: 138, y: 91))
        fringe.addLine(to: CGPoint(x: 128, y: 109))
        fringe.addLine(to: CGPoint(x: 116, y: 92))
        fringe.addLine(to: CGPoint(x: 106, y: 110))
        fringe.addLine(to: CGPoint(x: 94, y: 92))
        fringe.addLine(to: CGPoint(x: 86, y: 108))
        fringe.addLine(to: CGPoint(x: 76, y: 94))
        fringe.closeSubpath()
        context.fill(
            fringe,
            with: .linearGradient(
                Gradient(colors: [Color(hex: 0xA8F06E), green, greenDark]),
                startPoint: CGPoint(x: 120, y: 44),
                endPoint: CGPoint(x: 120, y: 110)
            )
        )
        context.stroke(fringe, with: .color(outline), style: StrokeStyle(lineWidth: 3, lineJoin: .round))

        // Cheeks.
        context.fill(Path(ellipseIn: CGRect(x: 74, y: 124, width: 27, height: 15)), with: .color(red.opacity(0.09)))
        context.fill(Path(ellipseIn: CGRect(x: 139, y: 124, width: 27, height: 15)), with: .color(red.opacity(0.09)))

        // Brows.
        var leftBrow = Path()
        leftBrow.move(to: CGPoint(x: 86, y: 100))
        leftBrow.addQuadCurve(to: CGPoint(x: 111, y: 95), control: CGPoint(x: 99, y: 93))
        var rightBrow = Path()
        rightBrow.move(to: CGPoint(x: 129, y: 94))
        rightBrow.addQuadCurve(to: CGPoint(x: 155, y: 99), control: CGPoint(x: 141, y: 89))
        context.stroke(leftBrow, with: .color(greenDark), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        context.stroke(rightBrow, with: .color(greenDark), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        // Eyes.
        if blink {
            var leftBlink = Path()
            leftBlink.move(to: CGPoint(x: 89, y: 110))
            leftBlink.addQuadCurve(to: CGPoint(x: 109, y: 110), control: CGPoint(x: 99, y: 115))
            var rightBlink = Path()
            rightBlink.move(to: CGPoint(x: 131, y: 110))
            rightBlink.addQuadCurve(to: CGPoint(x: 151, y: 110), control: CGPoint(x: 141, y: 115))
            context.stroke(leftBlink, with: .color(ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            context.stroke(rightBlink, with: .color(ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        } else {
            for x in [CGFloat(86), CGFloat(128)] {
                let eyeRect = CGRect(x: x, y: 101, width: 26, height: 19)
                context.fill(Path(ellipseIn: eyeRect), with: .color(Color(hex: 0xF7F0C9)))
                context.stroke(Path(ellipseIn: eyeRect), with: .color(ink), lineWidth: 2.2)
                context.fill(
                    Path(ellipseIn: CGRect(x: x + 9, y: 105, width: 9, height: 9)),
                    with: .color(Color(hex: 0x62C13C))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: x + 12, y: 107, width: 4, height: 4)),
                    with: .color(ink)
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: x + 10, y: 105, width: 2.5, height: 2.5)),
                    with: .color(Color.white.opacity(0.9))
                )
            }
        }

        // Nose.
        var nose = Path()
        nose.move(to: CGPoint(x: 120, y: 118))
        nose.addLine(to: CGPoint(x: 116, y: 129))
        nose.addQuadCurve(to: CGPoint(x: 123, y: 130), control: CGPoint(x: 120, y: 132))
        context.stroke(nose, with: .color(Color(hex: 0x9A8068)), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

        // The grin.
        var mouth = Path()
        mouth.move(to: CGPoint(x: 79, y: 136))
        mouth.addCurve(
            to: CGPoint(x: 161, y: 136),
            control1: CGPoint(x: 98, y: 174),
            control2: CGPoint(x: 142, y: 174)
        )
        mouth.addCurve(
            to: CGPoint(x: 79, y: 136),
            control1: CGPoint(x: 144, y: 151),
            control2: CGPoint(x: 96, y: 151)
        )
        mouth.closeSubpath()
        context.fill(mouth, with: .color(Color(hex: 0x651324)))

        var teeth = Path()
        teeth.move(to: CGPoint(x: 91, y: 140))
        teeth.addQuadCurve(to: CGPoint(x: 149, y: 140), control: CGPoint(x: 120, y: 156))
        teeth.addQuadCurve(to: CGPoint(x: 91, y: 140), control: CGPoint(x: 120, y: 146))
        teeth.closeSubpath()
        context.fill(teeth, with: .color(Color(hex: 0xF3E8D2)))

        var toothGaps = Path()
        for x in [CGFloat(105), CGFloat(120), CGFloat(135)] {
            toothGaps.move(to: CGPoint(x: x, y: 142))
            toothGaps.addLine(to: CGPoint(x: x + 1, y: 148))
        }
        context.stroke(toothGaps, with: .color(Color(hex: 0x9B7A64).opacity(0.5)), lineWidth: 1)

        var lips = Path()
        lips.move(to: CGPoint(x: 78, y: 135))
        lips.addCurve(
            to: CGPoint(x: 162, y: 135),
            control1: CGPoint(x: 98, y: 172),
            control2: CGPoint(x: 142, y: 172)
        )
        context.stroke(lips, with: .color(red), style: StrokeStyle(lineWidth: 4, lineCap: .round))

        // Smile stitches.
        var stitches = Path()
        stitches.move(to: CGPoint(x: 78, y: 133))
        stitches.addLine(to: CGPoint(x: 68, y: 128))
        stitches.move(to: CGPoint(x: 78, y: 139))
        stitches.addLine(to: CGPoint(x: 67, y: 139))
        stitches.move(to: CGPoint(x: 162, y: 133))
        stitches.addLine(to: CGPoint(x: 172, y: 128))
        stitches.move(to: CGPoint(x: 162, y: 139))
        stitches.addLine(to: CGPoint(x: 173, y: 139))
        context.stroke(stitches, with: .color(red.opacity(0.8)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        // A little face shine.
        context.fill(
            Path(ellipseIn: CGRect(x: 84, y: 78, width: 18, height: 9)),
            with: .color(Color.white.opacity(0.3))
        )
    }

    // MARK: - Shared parts

    private func drawArm(
        _ context: inout GraphicsContext,
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat,
        color: Color,
        gloveColor: Color
    ) {
        var arm = Path()
        arm.move(to: start)
        arm.addQuadCurve(
            to: end,
            control: CGPoint(x: (start.x + end.x) / 2 - 4, y: (start.y + end.y) / 2)
        )
        context.stroke(
            arm,
            with: .color(outline),
            style: StrokeStyle(lineWidth: width + 5, lineCap: .round)
        )
        context.stroke(
            arm,
            with: .color(color),
            style: StrokeStyle(lineWidth: width, lineCap: .round)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: end.x - 12, y: end.y - 12, width: 24, height: 24)),
            with: .color(gloveColor)
        )
        context.stroke(
            Path(ellipseIn: CGRect(x: end.x - 12, y: end.y - 12, width: 24, height: 24)),
            with: .color(outline),
            lineWidth: 2.8
        )
    }

    private func rounded(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ radius: CGFloat) -> Path {
        Path(
            roundedRect: CGRect(x: x, y: y, width: width, height: height),
            cornerRadius: radius
        )
    }

    private func batSymbol(in rect: CGRect) -> Path {
        let x = rect.minX
        let y = rect.minY
        let width = rect.width
        let height = rect.height

        var path = Path()
        path.move(to: CGPoint(x: x + width * 0.5, y: y + height * 0.06))
        path.addCurve(
            to: CGPoint(x: x + width * 0.97, y: y + height * 0.34),
            control1: CGPoint(x: x + width * 0.72, y: y + height * 0.08),
            control2: CGPoint(x: x + width * 0.88, y: y + height * 0.13)
        )
        path.addLine(to: CGPoint(x: x + width * 0.82, y: y + height * 0.62))
        path.addLine(to: CGPoint(x: x + width * 0.68, y: y + height * 0.44))
        path.addLine(to: CGPoint(x: x + width * 0.60, y: y + height * 0.84))
        path.addLine(to: CGPoint(x: x + width * 0.50, y: y + height * 0.65))
        path.addLine(to: CGPoint(x: x + width * 0.40, y: y + height * 0.84))
        path.addLine(to: CGPoint(x: x + width * 0.32, y: y + height * 0.44))
        path.addLine(to: CGPoint(x: x + width * 0.18, y: y + height * 0.62))
        path.addLine(to: CGPoint(x: x + width * 0.03, y: y + height * 0.34))
        path.addCurve(
            to: CGPoint(x: x + width * 0.5, y: y + height * 0.06),
            control1: CGPoint(x: x + width * 0.12, y: y + height * 0.13),
            control2: CGPoint(x: x + width * 0.28, y: y + height * 0.08)
        )
        path.closeSubpath()
        return path
    }
}
