import Foundation

/// Localization and error message provider for fraction price inputs.
public struct FractionPriceLocalization: Sendable {
    /// Target locale for formatting numbers.
    public let locale: Locale
    
    /// Default currency symbol (e.g. "Rp").
    public let currencySymbol: String
    
    /// Default label text for the field (e.g. "Fraksi Harga").
    public let labelText: String
    
    /// Supplier for empty price error message.
    public let emptyPriceError: @Sendable () -> String
    
    /// Supplier for below min price error message.
    public let belowMinError: @Sendable (_ minFormatted: String) -> String
    
    /// Supplier for above max price error message.
    public let aboveMaxError: @Sendable (_ maxFormatted: String) -> String
    
    /// Supplier for invalid tick step error message.
    public let invalidTickError: @Sendable (_ step: String, _ nearestFormatted: String) -> String
    
    public init(
        locale: Locale,
        currencySymbol: String = "",
        labelText: String = "Price",
        emptyPriceError: @escaping @Sendable () -> String,
        belowMinError: @escaping @Sendable (_ minFormatted: String) -> String,
        aboveMaxError: @escaping @Sendable (_ maxFormatted: String) -> String,
        invalidTickError: @escaping @Sendable (_ step: String, _ nearestFormatted: String) -> String
    ) {
        self.locale = locale
        self.currencySymbol = currencySymbol
        self.labelText = labelText
        self.emptyPriceError = emptyPriceError
        self.belowMinError = belowMinError
        self.aboveMaxError = aboveMaxError
        self.invalidTickError = invalidTickError
    }
    
    /// Official Indonesian preset (Bahasa Indonesia).
    public static var id: FractionPriceLocalization {
        FractionPriceLocalization(
            locale: Locale(identifier: "id_ID"),
            currencySymbol: "Rp",
            labelText: "Fraksi Harga",
            emptyPriceError: { "Harga tidak boleh kosong" },
            belowMinError: { min in "Harga tidak boleh kurang dari \(min)" },
            aboveMaxError: { max in "Harga tidak boleh melebihi \(max)" },
            invalidTickError: { step, nearest in
                "Harga tidak sesuai dengan fraksi (\(step)). Terdekat: \(nearest)"
            }
        )
    }
    
    /// Official English preset.
    public static var en: FractionPriceLocalization {
        FractionPriceLocalization(
            locale: Locale(identifier: "en_US"),
            currencySymbol: "",
            labelText: "Tick Size",
            emptyPriceError: { "Price cannot be empty" },
            belowMinError: { min in "Price cannot be below \(min)" },
            aboveMaxError: { max in "Price cannot exceed \(max)" },
            invalidTickError: { step, nearest in
                "Price is not aligned to tick step (\(step)). Nearest: \(nearest)"
            }
        )
    }
    
    /// Returns a copy with custom error overrides.
    public func copyWith(
        locale: Locale? = nil,
        currencySymbol: String? = nil,
        labelText: String? = nil,
        emptyPriceError: (@Sendable () -> String)? = nil,
        belowMinError: (@Sendable (_ minFormatted: String) -> String)? = nil,
        aboveMaxError: (@Sendable (_ maxFormatted: String) -> String)? = nil,
        invalidTickError: (@Sendable (_ step: String, _ nearestFormatted: String) -> String)? = nil
    ) -> FractionPriceLocalization {
        FractionPriceLocalization(
            locale: locale ?? self.locale,
            currencySymbol: currencySymbol ?? self.currencySymbol,
            labelText: labelText ?? self.labelText,
            emptyPriceError: emptyPriceError ?? self.emptyPriceError,
            belowMinError: belowMinError ?? self.belowMinError,
            aboveMaxError: aboveMaxError ?? self.aboveMaxError,
            invalidTickError: invalidTickError ?? self.invalidTickError
        )
    }
}

extension FractionPriceLocalization: Equatable {
    public static func == (lhs: FractionPriceLocalization, rhs: FractionPriceLocalization) -> Bool {
        lhs.locale.identifier == rhs.locale.identifier &&
        lhs.currencySymbol == rhs.currencySymbol &&
        lhs.labelText == rhs.labelText
    }
}

