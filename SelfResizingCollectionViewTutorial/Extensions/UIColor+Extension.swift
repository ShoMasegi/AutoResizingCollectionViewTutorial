import UIKit

extension UIColor {
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        let value = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let red = CGFloat(Int(value[0] + value[1], radix: 16) ?? 0) / 255.0
        let green = CGFloat(Int(value[2] + value[3], radix: 16) ?? 0) / 255.0
        let blue = CGFloat(Int(value[4] + value[5], radix: 16) ?? 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}