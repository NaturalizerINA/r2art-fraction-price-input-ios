#if canImport(UIKit)
import UIKit

/// 10 Granular Color Tokens for `FractionPriceView` in UIKit.
public struct FractionPriceViewColors {
    public var containerColor: UIColor
    public var textColor: UIColor
    public var labelColor: UIColor
    public var helperColor: UIColor
    public var errorColor: UIColor
    public var buttonContainerColor: UIColor
    public var buttonIconColor: UIColor
    public var unfocusedBorderColor: UIColor
    public var focusedBorderColor: UIColor
    public var errorBorderColor: UIColor
    
    public init(
        containerColor: UIColor,
        textColor: UIColor,
        labelColor: UIColor,
        helperColor: UIColor,
        errorColor: UIColor,
        buttonContainerColor: UIColor,
        buttonIconColor: UIColor,
        unfocusedBorderColor: UIColor,
        focusedBorderColor: UIColor,
        errorBorderColor: UIColor
    ) {
        self.containerColor = containerColor
        self.textColor = textColor
        self.labelColor = labelColor
        self.helperColor = helperColor
        self.errorColor = errorColor
        self.buttonContainerColor = buttonContainerColor
        self.buttonIconColor = buttonIconColor
        self.unfocusedBorderColor = unfocusedBorderColor
        self.focusedBorderColor = focusedBorderColor
        self.errorBorderColor = errorBorderColor
    }
    
    /// Default adaptive theme colors supporting Light & Dark mode.
    public static var `default`: FractionPriceViewColors {
        FractionPriceViewColors(
            containerColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.12, green: 0.16, blue: 0.23, alpha: 1.0)
                    : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
            },
            textColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
            },
            labelColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.58, green: 0.64, blue: 0.72, alpha: 1.0)
                    : UIColor(red: 0.39, green: 0.45, blue: 0.55, alpha: 1.0)
            },
            helperColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.45, green: 0.52, blue: 0.62, alpha: 1.0)
                    : UIColor(red: 0.52, green: 0.59, blue: 0.67, alpha: 1.0)
            },
            errorColor: UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0),
            buttonContainerColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.20, green: 0.25, blue: 0.33, alpha: 1.0)
                    : UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
            },
            buttonIconColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
                    : UIColor(red: 0.01, green: 0.47, blue: 0.98, alpha: 1.0)
            },
            unfocusedBorderColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.28, green: 0.33, blue: 0.41, alpha: 1.0)
                    : UIColor(red: 0.82, green: 0.85, blue: 0.89, alpha: 1.0)
            },
            focusedBorderColor: UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0),
            errorBorderColor: UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0)
        )
    }
}

public extension UIColor {
    /// Helper to initialize UIKit `UIColor` from hex string.
    convenience init(hex: String) {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
#endif
