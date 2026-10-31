import SwiftUI

enum GothamTheme {
    static let ink = Color(hex: 0x06080F)
    static let night = Color(hex: 0x0B1220)
    static let panel = Color(hex: 0x111A2C)
    static let paper = Color(hex: 0xF6EEDC)
    static let batYellow = Color(hex: 0xF4C84B)
    static let jokerGreen = Color(hex: 0x8BE05A)
    static let jokerPurple = Color(hex: 0x4A2068)
    static let jokerRed = Color(hex: 0xD94B59)
    static let smoke = Color(hex: 0x8FA0B8)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
