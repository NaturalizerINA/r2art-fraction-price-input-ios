import Foundation

/// Possible status states for price validation.
public enum PriceValidationStatus: String, CaseIterable, Sendable {
    /// Price is valid and complies with all tick rules.
    case valid
    /// Price is missing or empty.
    case empty
    /// Price is below the minimum allowed price.
    case belowMin
    /// Price exceeds the maximum allowed price.
    case aboveMax
    /// Price is not aligned with the valid tick size of its tier.
    case invalidTick
}
