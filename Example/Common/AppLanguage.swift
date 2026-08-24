import Foundation
import FractionPriceCore

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case indonesian = "id"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .indonesian: return "🇮🇩 Indonesian (ID)"
        case .english: return "🇬🇧 English (EN)"
        }
    }
    
    public var localization: FractionPriceLocalization {
        switch self {
        case .indonesian: return .id
        case .english: return .en
        }
    }
    
    // Default Field Texts
    public var defaultLabelText: String {
        switch self {
        case .indonesian: return "Harga Beli Saham"
        case .english: return "Stock Buy Price"
        }
    }
    
    public var defaultPrefixText: String {
        switch self {
        case .indonesian: return "Rp"
        case .english: return "$"
        }
    }
    
    public var defaultSuffixText: String {
        switch self {
        case .indonesian: return "IDR"
        case .english: return "USD"
        }
    }
    
    public var defaultHelperText: String {
        ""
    }
    
    // Default Error Templates
    public var defaultEmptyError: String {
        switch self {
        case .indonesian: return "Wajib diisi: Masukkan harga beli!"
        case .english: return "Required: Please enter a price!"
        }
    }
    
    public var defaultBelowMinError: String {
        switch self {
        case .indonesian: return "Harga minimal pasar adalah {min}!"
        case .english: return "Price cannot be below minimum {min}!"
        }
    }
    
    public var defaultAboveMaxError: String {
        switch self {
        case .indonesian: return "Harga melebihi ARA pasar ({max})!"
        case .english: return "Price exceeds maximum limit ({max})!"
        }
    }
    
    public var defaultInvalidTickError: String {
        switch self {
        case .indonesian: return "Fraksi {step} salah. Saran: {nearest}"
        case .english: return "Fraction {step} invalid. Nearest: {nearest}"
        }
    }
    
    // UI Strings
    public var previewTitleSwiftUI: String {
        switch self {
        case .indonesian: return "Preview Komponen SwiftUI"
        case .english: return "SwiftUI Component Preview"
        }
    }
    
    public var previewTitleUIKit: String {
        switch self {
        case .indonesian: return "Preview Komponen UIKit"
        case .english: return "UIKit Component Preview"
        }
    }
    
    public var liveStateInspectorTitle: String {
        switch self {
        case .indonesian: return "Live State Inspector"
        case .english: return "Live State Inspector"
        }
    }
    
    public var section1Title: String {
        switch self {
        case .indonesian: return "Pengaturan Fungsional"
        case .english: return "Functional Settings"
        }
    }
    
    public var section1Subtitle: String {
        switch self {
        case .indonesian: return "Interaktivitas, snapping & dimensi"
        case .english: return "Interactivity, snapping & dimensions"
        }
    }
    
    public var section2Title: String {
        switch self {
        case .indonesian: return "Warna Komponen (10 Token)"
        case .english: return "Component Colors (10 Tokens)"
        }
    }
    
    public var section2Subtitle: String {
        switch self {
        case .indonesian: return "Token kustomisasi tampilan visual"
        case .english: return "Granular UI styling tokens"
        }
    }
    
    public var section3Title: String {
        switch self {
        case .indonesian: return "Label & Perataan"
        case .english: return "Labels & Alignment"
        }
    }
    
    public var section3Subtitle: String {
        switch self {
        case .indonesian: return "Header, prefix, suffix & alignment"
        case .english: return "Header, prefix, suffix & alignment"
        }
    }
    
    public var section4Title: String {
        switch self {
        case .indonesian: return "Lokalisasi & Pesan Error"
        case .english: return "Localization & Error Handlers"
        }
    }
    
    public var section4Subtitle: String {
        switch self {
        case .indonesian: return "i18n & 4 custom error closures"
        case .english: return "i18n & 4 custom error closures"
        }
    }
    
    public var toggleEnabled: String {
        switch self {
        case .indonesian: return "Aktif (Enabled)"
        case .english: return "Enabled"
        }
    }
    
    public var toggleReadOnly: String {
        switch self {
        case .indonesian: return "Hanya Baca (Read Only)"
        case .english: return "Read Only"
        }
    }
    
    public var toggleAutoCorrection: String {
        switch self {
        case .indonesian: return "Koreksi Otomatis (Debounced)"
        case .english: return "Auto-Correction (Debounced)"
        }
    }
    
    public var toggleSnapOnBlur: String {
        switch self {
        case .indonesian: return "Snap saat Blur (Kehilangan Fokus)"
        case .english: return "Snap on Blur (Focus Lost)"
        }
    }
    
    public var labelDebounceDelay: String {
        switch self {
        case .indonesian: return "Jeda Debounce"
        case .english: return "Debounce Delay"
        }
    }
    
    public var labelCardCornerRadius: String {
        switch self {
        case .indonesian: return "Radius Sudut Card"
        case .english: return "Card Corner Radius"
        }
    }
    
    public var labelButtonCornerRadius: String {
        switch self {
        case .indonesian: return "Radius Sudut Tombol"
        case .english: return "Button Corner Radius"
        }
    }
    
    public var toggleCustomErrors: String {
        switch self {
        case .indonesian: return "Gunakan Custom Error Closures"
        case .english: return "Use Custom Error Closures"
        }
    }
}
