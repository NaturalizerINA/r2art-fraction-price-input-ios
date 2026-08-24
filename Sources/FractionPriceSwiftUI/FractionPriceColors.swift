import SwiftUI

/// 10 Granular Color Tokens for `FractionPriceField` in SwiftUI.
public struct FractionPriceColors: Sendable, Equatable {
    /// Background fill color of the input container card.
    public var containerColor: Color
    
    /// Color of the numeric price text.
    public var textColor: Color
    
    /// Color of the label text placed above the input field.
    public var labelColor: Color
    
    /// Color of the active tick helper info / unit prefix-suffix text.
    public var helperColor: Color
    
    /// Color of the error text message displayed below the input.
    public var errorColor: Color
    
    /// Background color of the `+` and `-` stepper buttons.
    public var buttonContainerColor: Color
    
    /// Icon color of the `+` and `-` stepper buttons.
    public var buttonIconColor: Color
    
    /// Border stroke color when the field is idle/unfocused.
    public var unfocusedBorderColor: Color
    
    /// Border stroke color when the field is actively focused.
    public var focusedBorderColor: Color
    
    /// Border stroke color when the field has an invalid validation status.
    public var errorBorderColor: Color
    
    public init(
        containerColor: Color,
        textColor: Color,
        labelColor: Color,
        helperColor: Color,
        errorColor: Color,
        buttonContainerColor: Color,
        buttonIconColor: Color,
        unfocusedBorderColor: Color,
        focusedBorderColor: Color,
        errorBorderColor: Color
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
    public static var `default`: FractionPriceColors {
        #if canImport(UIKit)
        return FractionPriceColors(
            containerColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.12, green: 0.16, blue: 0.23, alpha: 1.0)
                    : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
            }),
            textColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
            }),
            labelColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.58, green: 0.64, blue: 0.72, alpha: 1.0)
                    : UIColor(red: 0.39, green: 0.45, blue: 0.55, alpha: 1.0)
            }),
            helperColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.45, green: 0.52, blue: 0.62, alpha: 1.0)
                    : UIColor(red: 0.52, green: 0.59, blue: 0.67, alpha: 1.0)
            }),
            errorColor: Color(red: 0.94, green: 0.27, blue: 0.27),
            buttonContainerColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.20, green: 0.25, blue: 0.33, alpha: 1.0)
                    : UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
            }),
            buttonIconColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
                    : UIColor(red: 0.01, green: 0.47, blue: 0.98, alpha: 1.0)
            }),
            unfocusedBorderColor: Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.28, green: 0.33, blue: 0.41, alpha: 1.0)
                    : UIColor(red: 0.82, green: 0.85, blue: 0.89, alpha: 1.0)
            }),
            focusedBorderColor: Color(red: 0.22, green: 0.74, blue: 0.97),
            errorBorderColor: Color(red: 0.94, green: 0.27, blue: 0.27)
        )
        #else
        return FractionPriceColors(
            containerColor: Color(red: 0.12, green: 0.16, blue: 0.23),
            textColor: .white,
            labelColor: Color(red: 0.58, green: 0.64, blue: 0.72),
            helperColor: Color(red: 0.45, green: 0.52, blue: 0.62),
            errorColor: Color(red: 0.94, green: 0.27, blue: 0.27),
            buttonContainerColor: Color(red: 0.20, green: 0.25, blue: 0.33),
            buttonIconColor: Color(red: 0.22, green: 0.74, blue: 0.97),
            unfocusedBorderColor: Color(red: 0.28, green: 0.33, blue: 0.41),
            focusedBorderColor: Color(red: 0.22, green: 0.74, blue: 0.97),
            errorBorderColor: Color(red: 0.94, green: 0.27, blue: 0.27)
        )
        #endif
    }
}

public extension Color {
    /// Helper to initialize SwiftUI `Color` from 6-character or 8-character hex string.
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
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
