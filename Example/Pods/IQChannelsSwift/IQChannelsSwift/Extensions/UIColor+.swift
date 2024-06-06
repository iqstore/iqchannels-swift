import UIKit

extension UIColor {
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
    
    static func paletteColorFromString(string: String?) -> UIColor {
        guard let string = string, !string.isEmpty else {
            return UIColor(hex: "78909C") // blue-grey-400
        }
        
        let colors: [UIColor] = [
            UIColor(hex: "EF5350"), // red-400
            UIColor(hex: "EC407A"), // pink-400
            UIColor(hex: "AB47BC"), // purple-400
            UIColor(hex: "7E57C2"), // deep-purple-400
            UIColor(hex: "5C6BC0"), // indigo-400
            UIColor(hex: "42A5F5"), // blue-400
            UIColor(hex: "29B6F6"), // light-blue-400
            UIColor(hex: "26C6DA"), // cyan-400
            UIColor(hex: "26A69A"), // teal-400
            UIColor(hex: "66BB6A"), // green-400
            UIColor(hex: "9CCC65"), // light-green-400
            UIColor(hex: "D4E157"), // lime-400
            UIColor(hex: "FFCA28"), // amber-400
            UIColor(hex: "FFA726"), // orange-400
            UIColor(hex: "FF7043")  // deep-orange-400
        ]
        
        let ch = String(string[string.startIndex])
        return colors[(Int(ch) ?? 0) % colors.count]
    }
}
