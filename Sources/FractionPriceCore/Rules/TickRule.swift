import Foundation

/// Protocol defining operations for fractional tick price calculations and validations.
public protocol TickRule: Sendable {
    /// Overall minimum allowable price.
    var minPrice: Double? { get }
    
    /// Overall maximum allowable price.
    var maxPrice: Double? { get }
    
    /// Returns the tick size (fraksi) for a given price.
    func getTickSize(for price: Double) -> Double
    
    /// Returns the tick size when stepping down from the given price (handles lower boundary crossing).
    func getPrevTickSize(for price: Double) -> Double
    
    /// Advances the price upwards by a specified number of ticks.
    func nextTick(price: Double, ticks: Int) -> Double
    
    /// Decrements the price downwards by a specified number of ticks.
    func prevTick(price: Double, ticks: Int) -> Double
    
    /// Snaps a price to the nearest/floor/ceil valid tick.
    func snapToTick(price: Double, mode: RoundingMode) -> Double
    
    /// Checks whether the given price is aligned with a valid tick step.
    func isValidTick(price: Double) -> Bool
    
    /// Calculates the number of ticks between two prices.
    func getTickDifference(basePrice: Double, targetPrice: Double) -> Int
    
    /// Formats a price number into a localized string.
    func formatPrice(_ price: Double, locale: Locale, currencySymbol: String?) -> String
    
    /// Parses a user-inputted string into a numeric price.
    func parsePrice(_ text: String, locale: Locale) -> Double?
    
    /// Validates a price value and returns a detailed `PriceValidationResult`.
    func validatePrice(_ price: Double?, localization: FractionPriceLocalization?) -> PriceValidationResult
}

public extension TickRule {
    /// Overload with default parameters.
    func nextTick(price: Double) -> Double {
        nextTick(price: price, ticks: 1)
    }
    
    /// Overload with default parameters.
    func prevTick(price: Double) -> Double {
        prevTick(price: price, ticks: 1)
    }
    
    /// Overload with default parameters.
    func snapToTick(price: Double) -> Double {
        snapToTick(price: price, mode: .nearest)
    }
    
    /// Overload with default parameters.
    func formatPrice(_ price: Double, locale: Locale = .current) -> String {
        formatPrice(price, locale: locale, currencySymbol: nil)
    }
    
    /// Overload with default parameters.
    func parsePrice(_ text: String) -> Double? {
        parsePrice(text, locale: .current)
    }
    
    /// Overload with default parameters.
    func validatePrice(_ price: Double?) -> PriceValidationResult {
        validatePrice(price, localization: nil)
    }
}
