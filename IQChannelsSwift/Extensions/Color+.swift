import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func paletteColorFromString(string: String?) -> Color {
        guard let string = string, !string.isEmpty else {
            return Color(hex: "78909C") // blue-grey-400
        }
        
        let colors: [Color] = [
            Color(hex: "EF5350"), // red-400
            Color(hex: "EC407A"), // pink-400
            Color(hex: "AB47BC"), // purple-400
            Color(hex: "7E57C2"), // deep-purple-400
            Color(hex: "5C6BC0"), // indigo-400
            Color(hex: "42A5F5"), // blue-400
            Color(hex: "29B6F6"), // light-blue-400
            Color(hex: "26C6DA"), // cyan-400
            Color(hex: "26A69A"), // teal-400
            Color(hex: "66BB6A"), // green-400
            Color(hex: "9CCC65"), // light-green-400
            Color(hex: "D4E157"), // lime-400
            Color(hex: "FFCA28"), // amber-400
            Color(hex: "FFA726"), // orange-400
            Color(hex: "FF7043")  // deep-orange-400
        ]
        
        let ch = String(string[string.startIndex])
        return colors[(Int(ch) ?? 0) % colors.count]
    }
}
