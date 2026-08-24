import Foundation

/// Result of evaluating a price against a `TickRule`.
public struct PriceValidationResult: Equatable, Sendable {
    /// Whether the price is completely valid.
    public let isValid: Bool
    
    /// The validation status outcome.
    public let status: PriceValidationStatus
    
    /// Optional human-readable error message.
    public let errorMessage: String?
    
    /// The nearest valid price if invalidTick or boundary issue.
    public let nearestPrice: Double?
    
    /// The active tick step for the current price tier.
    public let currentStep: Double?
    
    /// Minimum allowable price for the rule.
    public let minPrice: Double?
    
    /// Maximum allowable price for the rule.
    public let maxPrice: Double?
    
    public init(
        isValid: Bool,
        status: PriceValidationStatus,
        errorMessage: String? = nil,
        nearestPrice: Double? = nil,
        currentStep: Double? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil
    ) {
        self.isValid = isValid
        self.status = status
        self.errorMessage = errorMessage
        self.nearestPrice = nearestPrice
        self.currentStep = currentStep
        self.minPrice = minPrice
        self.maxPrice = maxPrice
    }
    
    /// Static factory for a valid result.
    public static func valid(currentStep: Double? = nil) -> PriceValidationResult {
        PriceValidationResult(isValid: true, status: .valid, currentStep: currentStep)
    }
    
    /// Static factory for an empty result.
    public static func empty(errorMessage: String? = nil) -> PriceValidationResult {
        PriceValidationResult(isValid: false, status: .empty, errorMessage: errorMessage)
    }
    
    /// Static factory for below min result.
    public static func belowMin(minPrice: Double, errorMessage: String? = nil) -> PriceValidationResult {
        PriceValidationResult(
            isValid: false,
            status: .belowMin,
            errorMessage: errorMessage,
            minPrice: minPrice
        )
    }
    
    /// Static factory for above max result.
    public static func aboveMax(maxPrice: Double, errorMessage: String? = nil) -> PriceValidationResult {
        PriceValidationResult(
            isValid: false,
            status: .aboveMax,
            errorMessage: errorMessage,
            maxPrice: maxPrice
        )
    }
    
    /// Static factory for invalid tick result.
    public static func invalidTick(
        step: Double,
        nearest: Double,
        errorMessage: String? = nil
    ) -> PriceValidationResult {
        PriceValidationResult(
            isValid: false,
            status: .invalidTick,
            errorMessage: errorMessage,
            nearestPrice: nearest,
            currentStep: step
        )
    }
}
