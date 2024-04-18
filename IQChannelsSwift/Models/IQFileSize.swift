import Foundation

class IQFileSize {
    
    static func unit(with size: Int) -> String {
        let units = ["байт", "KБ", "MБ", "ГБ", "TБ", "ПБ"]
        var sizef = Double(size)
        var unit = 0

        while sizef >= 1024 && unit < (units.count - 1) {
            unit += 1
            sizef /= 1024
        }

        return String(format: "%.01f %@", sizef, units[unit])
    }
}
