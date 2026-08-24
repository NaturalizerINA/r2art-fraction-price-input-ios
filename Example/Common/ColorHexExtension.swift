import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    /// Converts a SwiftUI `Color` to a 6-character hex string (`#RRGGBB`).
    func toHex() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let r = Int((red * 255.0).rounded())
            let g = Int((green * 255.0).rounded())
            let b = Int((blue * 255.0).rounded())
            return String(format: "#%02X%02X%02X", max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
        } else if let components = uiColor.cgColor.components, components.count >= 3 {
            let r = Int((components[0] * 255.0).rounded())
            let g = Int((components[1] * 255.0).rounded())
            let b = Int((components[2] * 255.0).rounded())
            return String(format: "#%02X%02X%02X", max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
        }
        return "#000000"
        #else
        return "#000000"
        #endif
    }
}
