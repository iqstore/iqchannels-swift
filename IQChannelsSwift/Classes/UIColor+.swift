import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static func paletteColorFromString(string: String?) -> UIColor {
        guard let string = string, !string.isEmpty else {
            return UIColor(hex: 0x78909c) // blue-grey-400
        }
        
        let colors: [UIColor] = [
            UIColor(hex: 0xef5350), // red-400
            UIColor(hex: 0xec407a), // pink-400
            UIColor(hex: 0xab47bc), // purple-400
            UIColor(hex: 0x7e57c2), // deep-purple-400
            UIColor(hex: 0x5c6bc0), // indigo-400
            UIColor(hex: 0x42a5f5), // blue-400
            UIColor(hex: 0x29b6f6), // light-blue-400
            UIColor(hex: 0x26c6da), // cyan-400
            UIColor(hex: 0x26a69a), // teal-400
            UIColor(hex: 0x66bb6a), // green-400
            UIColor(hex: 0x9ccc65), // light-green-400
            UIColor(hex: 0xd4e157), // lime-400
            UIColor(hex: 0xffca28), // amber-400
            UIColor(hex: 0xffa726), // orange-400
            UIColor(hex: 0xff7043)  // deep-orange-400
        ]
        
        let ch = String(string[string.startIndex])
        return colors[(Int(ch) ?? 0) % colors.count]
    }
    
    // MARK: - Message bubble colors
    class func jsq_messageBubbleGreen() -> UIColor {
        return UIColor(hue: 130.0 / 360.0, saturation: 0.68, brightness: 0.84, alpha: 1.0)
    }

    class func jsq_messageBubbleBlue() -> UIColor {
        return UIColor(hue: 210.0 / 360.0, saturation: 0.94, brightness: 1.0, alpha: 1.0)
    }

    class func jsq_messageBubbleRed() -> UIColor {
        return UIColor(hue: 0.0, saturation: 0.79, brightness: 1.0, alpha: 1.0)
    }

    class func jsq_messageBubbleLightGray() -> UIColor {
        return UIColor(hue: 240.0 / 360.0, saturation: 0.02, brightness: 0.92, alpha: 1.0)
    }

    // MARK: - Utilities
    func jsq_colorByDarkeningColorWithValue(value: CGFloat) -> UIColor {
        let totalComponents = self.cgColor.numberOfComponents
        let isGreyscale = totalComponents == 2

        let oldComponents = self.cgColor.components
        var newComponents: [CGFloat] = .init(repeating: 0.0, count: 4)

        if isGreyscale {
            newComponents[0] = max((oldComponents?[0] ?? 0.0) - value, 0.0)
            newComponents[1] = max((oldComponents?[0] ?? 0.0) - value, 0.0)
            newComponents[2] = max((oldComponents?[0] ?? 0.0) - value, 0.0)
            newComponents[3] = oldComponents?[1] ?? 0.0
        } else {
            newComponents[0] = max((oldComponents?[0] ?? 0.0) - value, 0.0)
            newComponents[1] = max((oldComponents?[1] ?? 0.0) - value, 0.0)
            newComponents[2] = max((oldComponents?[2] ?? 0.0) - value, 0.0)
            newComponents[3] = oldComponents?[3] ?? 0.0
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newColor = CGColor(colorSpace: colorSpace, components: newComponents)
        let retColor = UIColor(cgColor: newColor!)

        return retColor
    }
}
