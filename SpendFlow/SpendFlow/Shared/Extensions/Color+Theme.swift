import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let expenseRed = Color(hex: "FF3B30")
    static let incomeGreen = Color(hex: "34C759")
    static let warningOrange = Color(hex: "FF9500")
    static let accentBlue = Color(hex: "007AFF")
    static let accentPurple = Color(hex: "5856D6")
}

extension ShapeStyle where Self == Color {
    static var expenseRed: Color { Color.expenseRed }
    static var incomeGreen: Color { Color.incomeGreen }
    static var warningOrange: Color { Color.warningOrange }
    static var accentBlue: Color { Color.accentBlue }
    static var accentPurple: Color { Color.accentPurple }
}
